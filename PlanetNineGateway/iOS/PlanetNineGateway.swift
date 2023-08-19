//
//  PlanetNineGateway.swift
//  PlanetNineGateway
//
//  Created by Zach Babb on 2/19/19.
//  Copyright © 2019 Planet Nine. All rights reserved.
//

import Foundation

public class PlanetNineGateway {
    
    var oneTime: OneTimeGateway?
    var bleOneTime: BLEGateway?
    var magicCaster: MAGICCaster?
    var magicDevice: MAGICDevice?
    var ongoing: OngoingGateway?
    let network = Network()
    let crypto = Crypto()
    let gatewayAccessToken: String
    
    public static func initialize() {
        let crypto = Crypto()
        if crypto.getKeys() == nil {
            DispatchQueue.global(qos: .background).async {
                print("Generating keys \("".getTime())")
                crypto.generateKeys(seed: crypto.generateSeedPhrase())
                print("Generated keys \("".getTime())")
            }
        } else {
            print("Key s have been generated")
        }
    }
    
    public init(gatewayAccessToken: String) {
        self.gatewayAccessToken = gatewayAccessToken
    }
    
    public func askForOngoingGatewayUsage(returnURL: String) {
        guard let keys = Crypto().getKeys() else { return }
        
        OngoingGateway.askForOngoingGatewayUsage(gatewayAccessToken: gatewayAccessToken, publicKey: keys.publicKey, returnURL: returnURL)
    }
    
    public func usePowerAtOngoingGateway(user: PNUser, totalPower: Int, partnerName: String, description: String, callback: @escaping (Error?, PNUser?) -> Void) {
        OngoingGateway.usePowerAtOngoingGateway(user: user, totalPower: totalPower, partnerName: partnerName, description: description, callback: callback, gatewayAccessToken: gatewayAccessToken)
    }
    
    public func getUser(userUUID: String, callback: @escaping (Error?, PNUser?) -> Void) {
        let gatewayTimestampTuple = GatewayTimestampTuple(gatewayAccessToken: gatewayAccessToken)
        let gatewayTimestampTupleWithSignature = GatewayTimestampTupleWithSignature(gatewayAccessToken: gatewayAccessToken, timestamp: gatewayTimestampTuple.timestamp, signature: crypto.signMessage(message: gatewayTimestampTuple.toString())!)
        PlanetNineUser.getUser(userUUID: userUUID, gatewayTimestampTupleWithSignature: gatewayTimestampTupleWithSignature, callback: callback)
    }
    
    public func askForPowerUsage(totalPower: Int, partnerName: String, gatewayURL: String, partnerDisplayName: String, description: String, cantOpen: (() -> Void)?) {
        OneTimeGateway.askForPowerUsage(totalPower: totalPower, partnerName: partnerName, gatewayURL: gatewayURL, partnerDisplayName: partnerDisplayName, description: description, cantOpen: cantOpen)
    }
    
    public func submitPowerUsage(totalPower: Int, partnerName: String, userUUID: String, ordinal: Int, timestamp: String, signature: String, partnerDisplayName: String, description: String, callback: @escaping (Error?, Data?) -> Void) {
        
        OneTimeGateway.submitPowerUsage(totalPower: totalPower, partnerName: partnerName, userUUID: userUUID, ordinal: ordinal, timestamp: timestamp, signature: signature, partnerDisplayName: partnerDisplayName, description: description, callback: callback)
    }
    
    public func becomeMAGICTarget(totalPower: Int, partnerName: String, partnerDisplayName: String, description: String, spellReceivedCallback: @escaping () -> Void, networkCallback: @escaping (Error?, PNUser?) -> Void) {
       bleOneTime = MAGICGateway(totalPower: totalPower, partnerName: partnerName, partnerDisplayName: partnerDisplayName, description: description, gatewayAccessToken: gatewayAccessToken, spellReceivedCallback: spellReceivedCallback, networkCallback: networkCallback)
    }
    
    public func askToBecomeMagicDevice(networkCallback: @escaping (Error?, PNUser?) -> Void) {
        guard let publicKey = crypto.getKeys()?.publicKey else { return }
        magicDevice = MAGICDevice(gatewayAccessToken: gatewayAccessToken, publicKey: publicKey, networkCallback: networkCallback)
    }
    
    public func becomeMagicCaster(gatewayCallback: @escaping (Gateway) -> Void) {
        magicCaster = MAGICCaster(gatewayAccessToken: gatewayAccessToken, gatewayCallback: gatewayCallback)
    }
    
    public func castSpell(user: PNUser, gateway: Gateway) {
        guard let magicCaster = magicCaster else {
            print("Must call becomeMagicCaster before casting spells")
            return
        }
        magicCaster.castSpell(user: user, gateway: gateway)
    }
    
    internal class func topViewController(controller: UIViewController?) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
