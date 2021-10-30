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
    var ongoing: OngoingGateway?
    let network = Network()
    let crypto = Crypto()
    
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
    
    public init() {
        
    }
    
    public func usePowerAtOngoingGateway(user: PNUser, gatewayName: String, totalPower: Int, partnerName: String, description: String, callback: @escaping (Error?, PNUser?) -> Void) {
        let usePowerModel = UsePowerModel()
        let usePowerAtOngoingGateway = UsePowerAtOngoingGateway(totalPower: totalPower, partnerName: partnerName, gatewayName: gatewayName, userUUID: user.userUUID, ordinal: (user.powerOrdinal + 1), description: description)
        
        usePowerModel.usePowerAtOngoingGateway(gatewayObject: usePowerAtOngoingGateway) { error, user in
            
            if error != nil || user == nil {
                print("There was an error in the call. Error: \(error)")
                callback(error, nil)
                return
            }
            
            guard let user = user else { return }
            
            let pnUser = PlanetNineUser.getPNUserFromJSONData(jsonData: user)
            //let userString = String(data: user, encoding: .utf8)
            //print(userString)
            callback(nil, pnUser)
        }
    }
    
    public func getUser(userUUID: String, gatewayName: String, callback: @escaping (PNUser) -> Void) {
        let gatewayTimestampTuple = GatewayTimestampTuple(gatewayName: gatewayName)
        let signature = Crypto().signMessage(message: gatewayTimestampTuple.toString())
        guard let signature = signature else { return }
        _ = PlanetNineUser(userUUID: userUUID, gatewayName: gatewayName, timestamp: gatewayTimestampTuple.timestamp, signature: signature) { pnUser in
            callback(pnUser)
        }
    }
    
    public func oneTimeGateway(totalPower: Int, partnerName: String, gatewayName: String, gatewayURL: String, partnerDisplayName: String, description: String) {
        oneTime = OneTimeGateway(totalPower: totalPower, partnerName: partnerName, gatewayName: gatewayName, gatewayURL: gatewayURL, partnerDisplayName: partnerDisplayName, description: description)
    }
    
    public func askForPowerUsage() {
        guard let gateway = oneTime else {
            print("Must initialize oneTimeGateway before asking for power usage")
            return
        }
        gateway.askForPowerUsage()
    }
    
    public func submitPowerUsage(userUUID: String, timestamp: String, signature: String, callback: @escaping (Error?, Data?) -> Void) {
        guard let gateway = oneTime else {
            print("Must initialize oneTimeGateway before submitting power usage")
            return
        }
        gateway.submitPowerUsage(userUUID: userUUID, signature: signature, timestamp: timestamp, callback: callback)
    }
    
    public func oneTimeBLEUserGateway(gatewayName: String, gatewayURL: String, callback: @escaping (Error?, Data?) -> Void) {
        bleOneTime = OneTimeBLEUserGateway(gatewayName: gatewayName, gatewayURL: gatewayURL, callback: callback)
    }
    
    public func oneTimeBLEGateway(totalPower: Int, partnerName: String, gatewayName: String, gatewayURL: String, partnerDisplayName: String, description: String, callback: @escaping (Error?, Data?) -> Void) {
        bleOneTime = OneTimeBLEGateway(totalPower: totalPower, partnerName: partnerName, gatewayName: gatewayName, gatewayURL: gatewayURL, partnerDisplayName: partnerDisplayName, description: description, networkCallback: callback)
    }
    
    public func broadcastBLEGateway() {
        guard let gateway = bleOneTime else {
            print("Must initialize oneTimeBLEGateway before broadcasting")
            return
        }
        gateway.createTwoWayPeripheral()
    }
    
    public func ongoingGateway(gatewayName: String, gatewayURL: String) {
        
        guard let keys = Crypto().getKeys() else { return }
        
        let gatewayKey = GatewayKey(gatewayName: gatewayName, publicKey: keys.publicKey)
        
        guard let signature = crypto.signMessage(message: gatewayKey.toString()) else { return }
        
        ongoing = OngoingGateway(gatewayName: gatewayName, publicKey: keys.publicKey, gatewayURL: gatewayURL, timestamp: gatewayKey.timestamp, signature: signature)
    }
    
    public func askForOngoingGatewayUsage(presentingViewController: UIViewController) {
        guard let gateway = ongoing else {
            print("Must initialize ongoingGateway before asking for usage")
            return
        }
        gateway.askForOngoingGatewayUsage(presentingViewController: presentingViewController)
    }
    
    public func signinWithApple(gatewayName: String, appleId: String, publicKey: String, callback: @escaping (Error?, PNUser?) -> Void) {
        
        let appleSigninGatewayKey = AppleSignInGatewayKey(appleId: appleId, appPublicKey: publicKey)
        
        guard let signature = crypto.signMessage(message: appleSigninGatewayKey.toString()) else { return }
        
        let signinWithAppleGatewayKeyWithSignature = AppleSignInGatewayKeyWithSignature(appName: gatewayName, appleId: appleId, appPublicKey: publicKey, timestamp: appleSigninGatewayKey.timestamp, signature: signature)
        Network().signinWithApple(gatewayKey: signinWithAppleGatewayKeyWithSignature, callback: callback)
    }
    
    public func getUserUUIDForUsername(username: String, callback: @escaping (Error?, Data?) -> Void) {
        Network().getUserUUIDForUsername(username: username, callback: callback)
    }
    
    public func requestTransfer(gatewayName: String, transferRequest: TransferRequest, callback: @escaping (Error?, Data?) -> Void) {
        // TODO: Update this to be better
        
        /*let transferRequestWithSignature = TransferModel().addSignatureToTransferRequest(transferRequest: transferRequest, signature: signature)
        Network().requestTransfer(transferRequestWithSignature: transferRequestWithSignature, gatewayName: gatewayName, callback: callback)*/
        
        
    }
    
    public func mintNineum(partnerUUID: String, flavors: [String], ordinal: Int, callback: @escaping (Error?, [String]?) -> Void) {
        let mintNineumRequest = MintNineumRequest(partnerUUID: partnerUUID, flavors: flavors, ordinal: ordinal)
        
        guard let signature = crypto.signMessage(message: mintNineumRequest.toString()) else { return }
        
        let mintNineumRequestWithSignature =  MintNineumRequestWithSignature(partnerUUID: partnerUUID, flavors: flavors, ordinal: ordinal, timestamp: mintNineumRequest.timestamp, signature: signature)
        Network().mintNineum(mintNineumRequestWithSignature: mintNineumRequestWithSignature, callback: callback)
    }
    
    public func approveTransfer(userId: Int, transferId: Int, ordinal: Int, callback: @escaping (Error?, Data?) -> Void) {
        
        let approveTransfer = ApproveTransfer(userId: userId, nineumTransactionId: transferId, ordinal: ordinal)
        
        guard let signature = crypto.signMessage(message: approveTransfer.toString()) else { return }
        
        let approveTransferWithSignature = ApproveTransferWithSignature(userId: userId, nineumTransactionId: transferId, ordinal: ordinal, timestamp: approveTransfer.timestamp, signature: signature)
        Network().approveTransfer(approveTransferWithSignature: approveTransferWithSignature, callback: callback)
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
    
    var mpcBrowser: MPCBrowser?
    
    public func startBrowsing(peerID: String) {
        mpcBrowser = MPCBrowser(peerID: peerID)
    }
}
