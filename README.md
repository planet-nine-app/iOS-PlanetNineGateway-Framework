# Notice About planetninekit.com

www.planetnineapp.com/planet-nine-kit is currently under construction. Until it is up and running here are some helpful links.

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

You'll also need a Gateway Access Token. You can get one in the Planet Nine app. Navigate to the account screen (top right astronaut icon on the main screen), and tap the astronaut image four times. You'll be prompted for a gateway name, and then the app will present you with your access token. NOTE this is the only time you'll see your access token. If you lose it, you'll need to create another gateway. 

## Usage

### Universal Links
One Time, and Ongoing gateways require you to deeplink to the Planet Nine app, and give the Planet Nine app a URL that will return to your app. To do this you'll need universal links enabled for your app. Adding those is beyond the scope of this README, but you can find out more at [https://developer.apple.com/documentation/xcode/supporting-universal-links-in-your-app](https://developer.apple.com/documentation/xcode/supporting-universal-links-in-your-app).

### One-Time Gateways
A one-time gateway is the most basic way of interacting with the Planet Nine app. One-time gateways let users spend Power one time when prompted from your app. To start a one-time gateway import PlanetNineGateway and simply use:

```swift
let planetNineGateway = PlanetNineGateway("HERE IS WHERE YOUR ACCESS TOKEN GOES")
planetNineGateway.askForPowerUsage(totalPower: 400, partnerName: "lazer", gatewayURL: "pngtester://return/onetime", partnerDisplayName: "LAZER", description: "For testing the cocoapod") {
          // Do something when your app can't open the Planet Nine app URL (this should rarely happen)
        }
```

`totalPower`: can be any value over 200

`partnerName`: is the username of the partner to receive Nineum from the transaction

`gatewayURL`: is the URL that will be used to call back into your app

`partnerDisplayName`: is the friendly name displayed to the user 

`description`: is a description of what the transaction is for

Calling `askForPowerUsage` will open the Planet Nine app and display an alert to the user to accept or decline the Power usage.

Once the user accepts the Power usage, the Planet Nine app will open the URL specified in gatewayURL with its response. To handle this in `SceneDelegate.swift` in the `func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>)`  function you'll want to catch the URL response and call `submitPowerUsage`. This will pass the authenticated request to the Planet Nine backend, and, if successful, return the user who used power with you:

```swift
guard let urlContext = URLContexts.first else { return }
        
let url = urlContext.url
        
guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true) else {
        print("Invalid URL or path missing")
        return
}
if components.path == "/onetime" {
	guard let queryItems = components.queryItems,
        let userUUID = queryItems[0].value,
        let ordinalString = queryItems[1].value,
        let ordinal = Int(ordinalString),
        let timestamp = queryItems[2].value,
        let signature = queryItems[3].value else {
        	print("Could not parse query items from \(url.absoluteString)")
                return
        }
        PlanetNineGateway(gatewayAccessToken:  "HERE IS WHERE YOUR ACCESS TOKEN GOES").submitPowerUsage(totalPower: 400, partnerName: "lazer", userUUID: userUUID, ordinal: ordinal, timestamp: timestamp, signature: signature, partnerDisplayName: "LAZER", description: "For testing the cocoapod") { error, data in
                if error != nil { 
			// Handle error
		} else {
			print("Success!")
                	// Do cool stuff here
		}
	}
}
```

### Ongoing Gateways

An ongoing gateway is used when you want to utilize a user's information, typically their Nineum, and/or you want to make Power expenditures on their behalf. Once a user has connected their account to your app you'll see their user information and be able to perform Power transactions. A user can revoke this connection at any time so be sure to handle that situation in your app. 

The PlanetNineGateway cocoapod handles everything you need to authenticate these calls. This means your app will be doing cryptography, but will qualify for an exemption in reporting since the encryption only pertains to authentication.

```swift
        
let planetNineGateway = PlanetNineGateway("PUT ACCESS TOKEN HERE")
planetNineGateway.askForOngoingGatewayUsage(returnURL: "pngtester://return/ongoing")
```

Invoking `askForOngoingGatewayUsage` will open the Planet Nine app and prompt the user for their permission. Just like with the one-time gateway, we need to capture the response from the Planet Nine app. Again in `SceneDelegate.swift` in the `func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>)` function you'll want to handle the queryItems again, and once you have success, you can get the user:

```swift
guard let urlContext = URLContexts.first else { return }
        
        let url = urlContext.url
        print(url.absoluteString)
      
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true) else {
		print("Invalid URL or path missing")
		return
        }

	guard let success = components.queryItems![0].value else {
            print("Unsuccessful")
            return
        }
        guard let userUUID = components.queryItems![1].value else {
            print("No userUUID")
            return
        }

	if success == "true" && userUUID != "0" {
            print("Success! Now to get user.")
            PlanetNineGateway(gatewayAccessToken:  "a7445c86-98b6-4a86-96ff-05f345b61ba3").getUser(userUUID: userUUID) { error, user in
                if error != nil {
                    print(error)
                    return
                }
                if let user = user {
                    print("Got user")
                    print(user)
                    UserModel().saveUser(user: user)
                }
            }
        }
```

This user object will have all the relevant user information including the user's Nineum. For an example of working with a user's Nineum check out this blogpost about making an inventory system (TODO: Link to inventory system blog post). 

You can also make Power expenditures on the behalf of the user. Once the user has authorized your app with the above, you just need to call `usePowerAtOngoingGateway`:

```swift
let planetNineGateway = PlanetNineGateway("YOUR ACCESS TOKEN HERE")
let user = UserModel().getUser() // This isn't part of the pod, saving and retrieving the user is up to you
planetNineGateway.usePowerAtOngoingGateway(user: user, totalPower: 300, partnerName: "lazer", description: "Ongoing power usage in PNGTester") { error, user in
            if error != nil {
                print(error)
                return
            }
            
            if let user = user {
                print("User now has \(user.currentPower) power")
                // Do cool stuff here
                UserModel().saveUser(user: user)
            }
        }
```

Remember to be responsible with other users' Power, if you spend it when you shouldn't they'll revoke their connection and your reputation will suffer. 

### MAGIC 

NOTE: This API is experimental, and may break at any time without warning

Multi-device Asynchronous Generic Input/Output Consensus is a backronym for MAGIC. The MAGIC protocol defines roles for casters and targets. Right now, only targets are supported in the cocoapod. A MAGIC target can interact with the Planet Nine app, and eventually with other casters. To become a MAGIC target call `becomeMAGICTarget`: 

```swift
let planetNineGateway = PlanetNineGateway("YOUR ACCESS TOKEN HERE")
planetNineGateway.becomeMAGICTarget(totalPower: 450, partnerName: "lazer", partnerDisplayName: "Developer", description: "Testing the MAGIC", spellReceivedCallback: {
            // Display some notice that the spell has been received
        }, networkCallback: { error, user in
            if let user = user {
                // Do something cool for the user here
            }
        })
```

`totalPower`: can be any value over 200

`partnerName`: is the username of the partner to receive Nineum from the transaction

`partnerDisplayName`: is the friendly name displayed to the user 

`description`: is a description of what the transaction is for

`spellReceivedCallback`: Network calls happen in between receiving the spell from the caster, and receiving the user after the power is spent. Use this callback to display some visual feedback that your app is working on it.

`networkCallback`: This gets called with the result from spending the power. If successful, you'll get a user object to use. You should do something beneficial for the user here.

Once you've started the gateway, it handles all spending with it automatically so there is no additional code required. 

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

## Conclusion

Thank you for checking out the Planet Nine Gateway framework. Hopefully this README has been helpful. We look forward to seeing what you create!
