//
//  MAGICGateway.swift
//  PlanetNineGateway
//
//  Created by Zach Babb on 2/6/19.
//  Copyright © 2019 Planet Nine. All rights reserved.
//

import Foundation
import CoreBluetooth

class MAGICGateway: BLEGateway {
    var twoWayPeripheral: BLETwoWayPeripheral!
    let gateway: Gateway
    let spellReceivedCallback: () -> Void
    let networkCallback: (Error?, PNUser?) -> Void
    let bleCharacteristics = BLECharacteristics()
    let gatewayAccessToken: String
    
    struct UserUpdate: Codable {
        let success: Bool
        let ordinal: Int
        let currentPower: Int
        func toString() -> String {
            return "{\"success\":\(success),\"ordinal\":\(ordinal),\"currentPower\":\(currentPower)}"
        }
    }
    
    init(totalPower: Int, partnerName: String, partnerDisplayName: String, description: String, gatewayAccessToken: String, spellReceivedCallback: @escaping () -> Void, networkCallback: @escaping (Error?, PNUser?) -> Void) {
        self.spellReceivedCallback = spellReceivedCallback
        self.networkCallback = networkCallback
        self.gatewayAccessToken = gatewayAccessToken
        gateway = Gateway(totalPower: totalPower, partnerName: partnerName, partnerDisplayName: partnerDisplayName, description: description)
        twoWayPeripheral = BLETwoWayPeripheral(readCallback: readCallback, writeCallback: writeCallback, notifyCallback: notifyCallback)
    }
    
    func readCallback(characteristic: CBCharacteristic) -> String {
        if characteristic.uuid == bleCharacteristics.read {
            return gateway.toBLEString()
        }
        return ""
    }
    
    func writeCallback(value: String, central: CBCentral) {
        print("Got write value: \(value)")
        spellReceivedCallback()
        guard let gatewayResponse = GatewayModel().getGatewayResponseFromJSON(jsonString: value) else {
            return
        }
        if gatewayResponse.ongoing == true {
            let usePowerAtOngoingGatewayWithSignature = UsePowerAtOngoingGatewayWithSignature(totalPower: gateway.totalPower, partnerName: gateway.partnerName, gatewayAccessToken: gatewayAccessToken, userUUID: gatewayResponse.userUUID, ordinal: gatewayResponse.ordinal, description: gateway.description, timestamp: gatewayResponse.timestamp, signature: gatewayResponse.signature)
            Network().usePowerAtOngoingGateway(usePowerAtOngoingGatewayWithSignature: usePowerAtOngoingGatewayWithSignature) { error, data in
                if let data = data,
                   let pnUser = UserModel.getUserFromJSONData(userData: data) {
                    self.networkCallback(nil, pnUser)
                    let userUpdate = UserUpdate(success: true, ordinal: pnUser.powerOrdinal, currentPower: pnUser.currentPower)
                    self.twoWayPeripheral.notifySubscribedCentral(update: userUpdate.toString(), central: central)
                }
                self.networkCallback(error, nil)
                let userUpdate = UserUpdate(success: false, ordinal: 0, currentPower: 0)
                self.twoWayPeripheral.notifySubscribedCentral(update: userUpdate.toString(), central: central)
            }
        } else {
            let powerUsage = PowerUsage(totalPower: gateway.totalPower, partnerName: gateway.partnerName, userUUID: gatewayResponse.userUUID, ordinal: gatewayResponse.ordinal, signature: gatewayResponse.signature, partnerDisplayName: gateway.partnerDisplayName, description: gateway.description, timestamp: gatewayResponse.timestamp)
            Network().usePowerAtOneTimeGateway(powerUsageObject: powerUsage) { error, data in
                if let data = data,
                   let pnUser = UserModel.getUserFromJSONData(userData: data) {
                    self.networkCallback(nil, pnUser)
                    let userUpdate = UserUpdate(success: true, ordinal: pnUser.powerOrdinal, currentPower: pnUser.currentPower)
                    self.twoWayPeripheral.notifySubscribedCentral(update: userUpdate.toString(), central: central)
                    return
                }
                self.networkCallback(error, nil)
                let userUpdate = UserUpdate(success: false, ordinal: 0, currentPower: 0)
                self.twoWayPeripheral.notifySubscribedCentral(update: userUpdate.toString(), central: central)
            }
        }
    }
    
    func notifyCallback(characteristic: CBCharacteristic) -> String {
        // Resend here if fails?
        return ""
    }
    
}
