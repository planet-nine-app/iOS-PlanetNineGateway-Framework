# Planet Nine Gateway

Planet Nine Gateway lets you interact with the Planet Nine ecosystem on iOS. 

## Getting Started

### Cocoapods

Install with [CocoaPods](http://cocoapods.org) by adding the following to your `Podfile`:

```
pod 'PlanetNineGateway'
```

## Usage

### One-Time Gateways
A one-time gateway is the most basic way of interacting with the Planet Nine app. One-time gateways let users spend Power one time when prompted from your app. To start a one-time gateway import PlanetNineGateway and simply use:

```let oneTimeGateway = OneTimeGateway(totalPower: 200, partnerName: partnerName, gatewayName: gatewayName, gatewayURL: "ongoingtest://gateway", partnerDisplayName: "Gateway Tester", description: "This is the test app for Planet Nine Gateway Framework")
oneTimeGateway.askForPowerUsage()```

`totalPower`: can be any value over 200
`partnerName`: is the username of the partner to receive Nineum from the transaction
`gatewayName`: is the display name of the Gateway when prompting a user to spend Power
`gatewayURL`: is the URL that will be used to call back into your app
`partnerDisplayName`: is the friendly name displayed to the user 
`description`: is a description of what the transaction is for

Calling `askForPowerUsage` will open the Planet Nine app and display an alert of the user to accept or decline the Power usage.

Once the user accepts the Power usage, the Planet Nine app will open the URL specified in gatewayURL with its response. To handle this in `AppDelegate.swift` in the `func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool` function you'll want to catch the URL response and then create the gateway again:

```let oneTimeGateway = OneTimeGateway(totalPower: 200, partnerName: partnerName, gatewayName: gatewayName, gatewayURL: "ongoing://gateway", partnerDisplayName: "Gateway Tester", description: "For testing the Planet Nine Gateway Framework")```

Get the userId and signature from the queryItems of the URL:

```let userId = Int(components.queryItems![0].value!)
let signature = components.queryItems![1].value```

And finally call `submitPowerUsage` on the gateway object with a callback that will handle errors and responses. 

``` oneTimeGateway.submitPowerUsage(userId: userId!, signature: signature!) { (error, resp) in
                guard let resp = resp else {
                    print("You got an error bro")
                    print(error)
                    return
                }
                if error != nil {
                    print("You got an error bro")
                    print(error)
                    return
                }
                let responseString = String(data: resp, encoding: .utf8)
                print(responseString)
                DispatchQueue.main.async {
                    let viewController = UIApplication.topViewController() as! ViewController
                    let alert = UIAlertController(title: "Heyoo", message: "You spent the power", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    viewController.present(alert, animated: true, completion: nil)
                }
                
            }```

### One-Time BLE Gateways

A One-Time BLE Gateway is for usage when you want to interact with the Planet Nine app via Bluetooth Low Energy (BLE). This is great for POS implementations. You start a BLE gateway much in the same way that you start a One-Time Gateway. 

```let bleOneTimeGateway = OneTimeBLEGateway(totalPower: 300, partnerName: "test50603336", gatewayName: "Planet Nine Point of Sale", gatewayURL: "pnpos://gateway", partnerDisplayName: "A Test User", description: "This is a test of the BLE gateway") { username in
            print("User: \(username) used 300 Power")
        }
bleOneTimeGateway.createTwoWayPeripheral()```

`totalPower`: can be any value over 200
`partnerName`: is the username of the partner to receive Nineum from the transaction
`gatewayName`: is the display name of the Gateway when prompting a user to spend Power
`gatewayURL`: is the URL that will be used to call back into your app
`partnerDisplayName`: is the friendly name displayed to the user 
`description`: is a description of what the transaction is for

Once you've started the gateway, it handles all spending with it automatically so there is no additional code required. 

### Ongoing Gateways

An ongoing gateway is used when you want to utilize a user's information, typically their Nineum, and/or you want to make Power expenditures on their behalf. Once a user has connected their account to their app you'll see their user information and be able to perform Power transactions. A user can revoke this connection at any time so be sure to handle that situation in your app. 

In order to handle ongoing gateways, your app will have to implement cryptographic functions. This has repurcusions for storing information in your app and doing so is outside of scope for the Planet Nine Gateway framework. To learn more about the cryptography necessary for Planet Nine please check out here (TODO: provide link to cryptographic information). This README assumes that you've already implemented cryptography and that you have a `Crypto` class with a `signMessage` method which will provide the require cryptographic signatures, as well as a `getKeys` method which will supply you with your publicKey.

Once you have your cryptography set up, to prompt the user for an ongoing gateway just:

```let keys = Crypto().getKeys()!
        let gatewayKey = GatewayKey(gatewayName: gatewayName, publicKey: keys.publicKey)
        let signature = Crypto().signMessage(message: gatewayKey.toString())
        
        let ongoingGateway = OngoingGateway(gatewayName: gatewayName, publicKey: keys.publicKey, gatewayURL: "ongoingtest://ongoing", signature: signature)
        ongoingGateway.askForOngoingGatewayUsage()```

Invoking `askForOngoingGatewayUsage` will open the Planet Nine app and prompt the user for their permission. Just like with the one-time gateway, we need to capture the response from the Planet Nine app. Again in `AppDelegate.swift` in the `func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool` function you'll want to handle the queryItems again:

```guard let success = components.queryItems![0].value else {
            print("Unsuccessful")
            return
        }
        guard let userId = components.queryItems![1].value else {
            print("No userId")
            return
        }```

Once you check if success is true you can then get the Planet Nine user object by signing your gateway name:

```let signature = Crypto().signMessage(message: gatewayName)
        let planetNineUser = PlanetNineUser(userId: Int(userId)!, gatewayName: gatewayName, signature: signature) { pnUser in
            UserModel().saveUser(user: pnUser)
        }```

This user object will have all the relevant user information including the user's Nineum. For an example of working with a user's Nineum check out this blogpost about making an inventory system (TODO: Link to inventory system blog post). 

You can also make Power expenditures on the behalf of the user. To do this you will need to create a `UsePowerAtOngoingGateway` struct, sign it, and submit it to the server. This would look like:

```let user = UserModel().getUser()!
        let usePowerModel = UsePowerModel()
        let usePowerAtOngoingGateway = UsePowerAtOngoingGateway(totalPower: 300, partnerName: "whirl-five-cool", gatewayName: gatewayName, userId: user.userId, publicKey: Crypto().getKeys()!.publicKey, ordinal: user.powerOrdinal + 1)
        let usePowerAtOngoingGatewayWithSignature = usePowerModel.addSignatureToUsePowerAtOngoingGatewayObject(object: usePowerAtOngoingGateway, signature: Crypto().signMessage(message: usePowerAtOngoingGateway.toString()))
        usePowerModel.usePowerAtOngoingGateway(gatewayObjectWithSignature: usePowerAtOngoingGatewayWithSignature) { error, resp in
            if error != nil {
                print("You got an error")
                return
            }
            print(String(data: resp!, encoding: .utf8))
        }```

Remember to be responsible with other users' Power, if you spend it when you shouldn't they'll revoke their connection and your reputation will suffer. 

## Conclusion

Thank you for checking out the Planet Nine Gateway framework. Hopefully this README has been helpful. We look forward to seeing what you create!
