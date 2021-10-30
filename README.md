# Notice About planetninekit.com

www.planetninekit.com is currently under construction. Until it is up and running here are some helpful links.

* For the PlanetNineGateway Cocoapod look no further than right here. Just scroll on down.

* [For the game demo The Ballad of Lorbert](https://github.com/planet-nine-app/theballadoflorbert)

* [For the web](https://github.com/planet-nine-app/web-power-gateway) 

* [For Node](https://www.npmjs.com/package/planet-nine-gateway-framework)

# Planet Nine Gateway

Planet Nine Gateway lets you interact with the Planet Nine ecosystem on iOS. 

## Getting Started

### Cocoapods

Install with [CocoaPods](http://cocoapods.org) by adding the following to your `Podfile`:

```
pod 'PlanetNineGateway'
```

## Usage

### Enabling Deeplinking
First to enable deeplinking with the Planet Nine app add the `LSApplicationQueriesSchemes` property to your info.plist and add `planetnine` to the array.

### One-Time Gateways
A one-time gateway is the most basic way of interacting with the Planet Nine app. One-time gateways let users spend Power one time when prompted from your app. To start a one-time gateway import PlanetNineGateway and simply use:

```swift
let planetNineGateway = PlanetNineGateway()
planetNineGateway.oneTimeGateway(totalPower: 200, partnerName: partnerName, gatewayName: gatewayName, gatewayURL: "ongoingtest://gateway", partnerDisplayName: "Gateway Tester", description: "This is the test app for Planet Nine Gateway Framework")
planetNineGateway.askForPowerUsage()
```

`totalPower`: can be any value over 200

`partnerName`: is the username of the partner to receive Nineum from the transaction

`gatewayName`: is the display name of the Gateway when prompting a user to spend Power

`gatewayURL`: is the URL that will be used to call back into your app

`partnerDisplayName`: is the friendly name displayed to the user 

`description`: is a description of what the transaction is for

Calling `askForPowerUsage` will open the Planet Nine app and display an alert of the user to accept or decline the Power usage.

Once the user accepts the Power usage, the Planet Nine app will open the URL specified in gatewayURL with its response. To handle this in `AppDelegate.swift` in the `func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool` function you'll want to catch the URL response and then create the gateway again:

```swift
let planetNineGateway = PlanetNineGateway()
planetNineGateway.oneTimeGateway(totalPower: 200, partnerName: partnerName, gatewayName: gatewayName, gatewayURL: "ongoing://gateway", partnerDisplayName: "Gateway Tester", description: "For testing the Planet Nine Gateway Framework")
```

Get the userUUID and signature from the queryItems of the URL:

```swift
let userUUID = components.queryItems![0].value
let signature = components.queryItems![1].value
```

And finally call `submitPowerUsage` on the gateway object with a callback that will handle errors and responses. 

```swift
let planetNineGateway = PlanetNineGateway()
planetNineGateway.oneTimeGateway(totalPower: 200, partnerName: partnerName, gatewayName: gatewayName, gatewayURL: "ongoing://gateway", partnerDisplayName: "Gateway Tester", description: "For testing the Planet Nine Gateway Framework")
planetNineGateway.submitPowerUsage(userUUID: userUUID, signature: signature!) { (error, resp) in
   guard let resp = resp else {
       print("You got an error")
       print(error)
       return
   }
   if error != nil {
       print("You got an error")
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
   
}
```

### One-Time BLE Gateways

A One-Time BLE Gateway is for usage when you want to interact with the Planet Nine app via Bluetooth Low Energy (BLE). This is great for POS implementations. You start a BLE gateway much in the same way that you start a One-Time Gateway. 

```swift
let planetNineGateway = PlanetNineGateway()
planetNineGateway.oneTimeBLEGateway(totalPower: 300, partnerName: "test50603336", gatewayName: "Planet Nine Point of Sale", gatewayURL: "pnpos://gateway", partnerDisplayName: "A Test User", description: "This is a test of the BLE gateway") { username in
    print("User: \(username) used 300 Power")
}
planetNineGateway.broadcastBLEGateway()
```

`totalPower`: can be any value over 200

`partnerName`: is the username of the partner to receive Nineum from the transaction

`gatewayName`: is the display name of the Gateway when prompting a user to spend Power

`gatewayURL`: is the URL that will be used to call back into your app

`partnerDisplayName`: is the friendly name displayed to the user 

`description`: is a description of what the transaction is for

`successCallback`: this last argument is a callback for the gateway to use upon successful expenditure with a user. The Planet Nine app will provide the username of the user who uses the gateway.

Once you've started the gateway, it handles all spending with it automatically so there is no additional code required. 

### Ongoing Gateways

An ongoing gateway is used when you want to utilize a user's information, typically their Nineum, and/or you want to make Power expenditures on their behalf. Once a user has connected their account to your app you'll see their user information and be able to perform Power transactions. A user can revoke this connection at any time so be sure to handle that situation in your app. 

The PlanetNineGateway cocoapod handles everything you need to authenticate these calls. This means your app will be doing cryptography, but will qualify for an exemption in reporting since the encryption only pertains to authentication.

```swift
        
let planetNineGateway = PlanetNineGateway()
planetNineGateway.ongoingGateway(gatewayName: gatewayName, gatewayURL: "ongoingtest://ongoing")
planetNineGateway.askForOngoingGatewayUsage(presentingViewController: self)
```

Invoking `askForOngoingGatewayUsage` will open the Planet Nine app and prompt the user for their permission. Just like with the one-time gateway, we need to capture the response from the Planet Nine app. Again in `AppDelegate.swift` in the `func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool` function you'll want to handle the queryItems again:

```swift
guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL or path missing")
            return false
        }

guard let success = components.queryItems![0].value else {
    print("Unsuccessful")
    return
}
guard let userUUID = components.queryItems![1].value else {
    print("No userUUID")
    return
}
```

Once you check if success is true you can then get the Planet Nine user object by signing your gateway name. Here we assume you have a UserModel class which can save PNUsers:

```swift
let planetNineGateway = PlanetNineGateway()
planetNineGateway.getUser(userUUID: userUUID, gatewayName: "The-Ballad-of-Sigurd-dev") { pnUser in
	// handle pnUser here
}
```

This user object will have all the relevant user information including the user's Nineum. For an example of working with a user's Nineum check out this blogpost about making an inventory system (TODO: Link to inventory system blog post). 

You can also make Power expenditures on the behalf of the user. To do this you will need to create a `UsePowerAtOngoingGateway` struct, sign it, and submit it to the server. This would look like:

```swift
let planetNineGateway = PlanetNineGateway()
planetNineGateway.usePowerAtOngoingGateway(user: user, gatewayName: "The-Ballad-of-Sigurd-dev", totalPower: 300, partnerName: "team-planet-nine", description: "Used from the Ballad of Lorbert") { error, user in
    if let error = error {
	// handle error
	return
    }
    guard let user = user else { return }
    // handle updated user
}
```

Remember to be responsible with other users' Power, if you spend it when you shouldn't they'll revoke their connection and your reputation will suffer. 

### Nineum
Once a user has connected their account you will be able to see their Nineum and use it in your game. Nineum has a variety of properties that you can make use of to do interesting stuff in your implementation. The Nineum struct has what those properties are:

```swift
public struct Nineum {
    public let universe: Universes
    public let address: Addresses
    public let charge: Charges
    public let direction: Directions
    public let rarity: Rarities
    public let size: Sizes
    public let texture: Textures
    public let shape: Shapes
    public let year: Years
    public let ordinal: Int
    public let hexString: String
}
```

For a breakdown of each property check out the [NineumModel file](https://github.com/planet-nine-app/iOS-PlanetNineGateway-Framework/blob/master/PlanetNineGateway/Models/NineumModel.swift). Nineum is represented by a 128-bit integer represented as a hex string, and a user's Nineum is an array of those hex strings. To get Nineum structs you would call

```swift
let nineumArray = NineumModel().getNineumArrayForNineumHexStrings(hexStrings: nineumHexStrings)
```

This will return an array of Nineum structs, which you can then use to check properties and organize as you see fit. 

### Transferring Nineum

Transferring Nineum is a two-step process. First a request for a transfer is made, then a user must approve the transfer in the Planet Nine app. This is because third-parties are not given permission to exchange a user's Nineum. In order to request a user you will need the receiving user's userUUID. Since most of the time what is known is a user's name, we provide a call to get the userUUID:

```swift
pn.requestTransfer(gatewayName: "trade-your-nineum", transferRequest: transferRequest, signature: signature) { error, data in

// Do work here

}
```

Once you have the userUUID for the receiving user you can construct the transfer request object. 

```swift
let transferRequest = TransferRequest(userUUID: user.userUUID, destinationUserUUID: decodedUser.userUUID, nineumUniqueIds: nineumUniqueIds, price: 0, ordinal: user.powerOrdinal + 1)
```

This object also contains a timestamp for your request. Here userUUID and destinationUserUUID are the userUUIDs of the sender and receiver. nineumUniqueIds is an array of 128-bit integers representing Nineum, price is any price associated with the transfer, and ordinal is the user's powerOrdinal incremented by one. You then sign this message and send it to the server using the `requestTransfer` method. 

## Conclusion

Thank you for checking out the Planet Nine Gateway framework. Hopefully this README has been helpful. We look forward to seeing what you create!
