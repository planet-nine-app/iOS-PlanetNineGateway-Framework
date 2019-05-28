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
    var bleOneTime: OneTimeBLEGateway?
    var ongoing: OngoingGateway?
    let network = Network()
    
    public init() {
        
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
    
    public func submitPowerUsage(userId: Int, signature: String, timestamp: String, callback: @escaping (Error?, Data?) -> Void) {
        guard let gateway = oneTime else {
            print("Must initialize oneTimeGateway before submitting power usage")
            return
        }
        gateway.submitPowerUsage(userId: userId, signature: signature, timestamp: timestamp, callback: callback)
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
    
    public func ongoingGateway(gatewayName: String, publicKey: String, gatewayURL: String, timestamp: String, signature: String) {
        ongoing = OngoingGateway(gatewayName: gatewayName, publicKey: publicKey, gatewayURL: gatewayURL, timestamp: timestamp, signature: signature)
    }
    
    public func askForOngoingGatewayUsage() {
        guard let gateway = ongoing else {
            print("Must initialize ongoingGateway before asking for usage")
            return
        }
        gateway.askForOngoingGatewayUsage()
    }
    
    public func getUserIdForUsername(username: String, callback: @escaping (Error?, Data?) -> Void) {
        Network().getUserIdForUsername(username: username, callback: callback)
    }
    
    public func requestTransfer(gatewayName: String, transferRequest: TransferRequest, signature: String, callback: @escaping (Error?, Data?) -> Void) {
        let transferRequestWithSignature = TransferModel().addSignatureToTransferRequest(transferRequest: transferRequest, signature: signature)
        Network().requestTransfer(transferRequestWithSignature: transferRequestWithSignature, gatewayName: gatewayName, callback: callback)
    }
    
}
