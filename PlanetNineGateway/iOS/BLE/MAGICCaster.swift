//
//  MAGICCaster.swift
//  PlanetNineGateway-framework
//
//  Created by Zach Babb on 8/14/23.
//

import Foundation
import CoreBluetooth

class MAGICCaster {
    var twoWayCentral: BLETwoWayCentral?
    let gatewayCallback: ((Gateway) -> Void)
    let gatewayAccessToken: String
    let bleCharacteristics = BLECharacteristics()
    
    init(gatewayAccessToken: String, gatewayCallback: @escaping (Gateway) -> Void) {
        self.gatewayCallback = gatewayCallback
        self.gatewayAccessToken = gatewayAccessToken
        self.twoWayCentral = BLETwoWayCentral(readCallback: readCallback, notifyCallback: notifyCallback)
    }
    
    func readCallback(_ value: String) {
        let gateway = GatewayModel().getGatewayFromJSONString(jsonString: value)
        gatewayCallback(gateway)
    }
    
    func castSpell(user: PNUser, gateway: Gateway) {
        let usePowerAtOngoingGateway = UsePowerAtOngoingGateway(totalPower: gateway.totalPower, partnerName: gateway.partnerName, gatewayAccessToken: gatewayAccessToken, userUUID: user.userUUID, ordinal: (user.powerOrdinal + 1), description: gateway.description)
        let usePowerAtOngoingGatewayWithSignature = UsePowerAtOngoingGatewayWithSignature(totalPower: gateway.totalPower, partnerName: gateway.partnerName, gatewayAccessToken: gatewayAccessToken, userUUID: user.userUUID, ordinal: usePowerAtOngoingGateway.ordinal, description: gateway.description, timestamp: usePowerAtOngoingGateway.timestamp, signature: Crypto().signMessage(message: usePowerAtOngoingGateway.toString())!)
        twoWayCentral?.respondToGateway(userUUID: user.userUUID, ordinal: usePowerAtOngoingGateway.ordinal, timestamp: usePowerAtOngoingGateway.timestamp, signature: usePowerAtOngoingGatewayWithSignature.signature)
    }
    
    func notifyCallback(_ value: String) {
        
    }
}
