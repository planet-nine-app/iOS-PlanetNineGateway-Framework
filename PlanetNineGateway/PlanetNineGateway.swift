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
    
    public func submitPowerUsage(userId: Int, signature: String, callback: @escaping (Error?, Data?) -> Void) {
        guard let gateway = oneTime else {
            print("Must initialize oneTimeGateway before submitting power usage")
            return
        }
        gateway.submitPowerUsage(userId: userId, signature: signature, callback: callback)
    }
    
    public func oneTimeBLEGateway(totalPower: Int, partnerName: String, gatewayName: String, gatewayURL: String, partnerDisplayName: String, description: String, successCallback: @escaping (String) -> Void) {
        bleOneTime = OneTimeBLEGateway(totalPower: totalPower, partnerName: partnerName, gatewayName: gatewayName, gatewayURL: gatewayURL, partnerDisplayName: partnerDisplayName, description: description, successCallback: successCallback)
    }
    
    public func broadcastBLEGateway() {
        guard let gateway = bleOneTime else {
            print("Must initialize oneTimeBLEGateway before broadcasting")
            return
        }
        gateway.createTwoWayPeripheral()
    }
    
    public func ongoingGateway(gatewayName: String, publicKey: String, gatewayURL: String, signature: String) {
        ongoing = OngoingGateway(gatewayName: gatewayName, publicKey: publicKey, gatewayURL: gatewayURL, signature: signature)
    }
    
    public func askForOngoingGatewayUsage() {
        guard let gateway = ongoing else {
            print("Must initialize ongoingGateway before asking for usage")
            return
        }
        gateway.askForOngoingGatewayUsage()
    }
}
