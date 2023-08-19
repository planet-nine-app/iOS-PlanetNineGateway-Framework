//
//  MAGICDevice.swift
//  PlanetNineGateway-framework
//
//  Created by Zach Babb on 8/5/23.
//

import Foundation
import CoreBluetooth

class MAGICDevice {
    var twoWayPeripheral: BLETwoWayPeripheral!
    let networkCallback: (Error?, PNUser?) -> Void
    let bleCharacteristics = BLECharacteristics()
    let gatewayAccessToken: String
    let publicKey: String
    let gatewayKeyWithSignature: GatewayKeyWithSignature
    
    init(gatewayAccessToken: String, publicKey: String, networkCallback: @escaping (Error?, PNUser?) -> Void) {
        self.gatewayAccessToken = gatewayAccessToken
        self.publicKey = publicKey
        self.networkCallback = networkCallback
        let gatewayKey = GatewayKey(gatewayAccessToken: gatewayAccessToken, publicKey: publicKey)
        gatewayKeyWithSignature = GatewayKeyWithSignature(gatewayAccessToken: gatewayAccessToken, publicKey: publicKey, timestamp: gatewayKey.timestamp, signature: Crypto().signMessage(message: gatewayKey.toString())!)
        
        twoWayPeripheral = BLETwoWayPeripheral(readCallback: readCallback, writeCallback: writeCallback, notifyCallback: notifyCallback)
    }
    
    func readCallback(characteristic: CBCharacteristic) -> String {
        if characteristic.uuid == bleCharacteristics.readMagicDevice {
            return gatewayKeyWithSignature.toBLEString()
        }
        return ""
    }
    
    func writeCallback(value: String, central: CBCentral) {
        print("Got write value: \(value)")
        guard let gatewayResponse = GatewayModel().getDeviceResponseFromJSON(jsonString: value) else {
            return
        }
        let gatewayTimestampTuple = GatewayTimestampTuple(gatewayAccessToken: gatewayAccessToken)
        let gatewayTimestampTupleWithSignature = GatewayTimestampTupleWithSignature(gatewayAccessToken: gatewayAccessToken, timestamp: gatewayTimestampTuple.timestamp, signature: Crypto().signMessage(message: gatewayTimestampTuple.toString())!)
        PlanetNineUser.getUser(userUUID: gatewayResponse.userUUID, gatewayTimestampTupleWithSignature: gatewayTimestampTupleWithSignature) { error, user in
            if error != nil {
                let userUpdate = UserUpdate(success: false, ordinal: 0, currentPower: 0)
                self.twoWayPeripheral.notifySubscribedCentral(update: userUpdate.toString(), central: central)
                self.networkCallback(error, nil)
            }
            if let user = user {
                let userUpdate = UserUpdate(success: true, ordinal: user.powerOrdinal, currentPower: user.currentPower)
                self.twoWayPeripheral.notifySubscribedCentral(update: userUpdate.toString(), central: central)
                self.networkCallback(nil, user)
            }
        }
    }
    
    func notifyCallback(characteristic: CBCharacteristic) -> String {
        // Resend here if fails?
        return ""
    }
}
