//
//  OneTimeBLEGateway.swift
//  PlanetNineGateway
//
//  Created by Zach Babb on 2/6/19.
//  Copyright © 2019 Planet Nine. All rights reserved.
//

import Foundation
import CoreBluetooth

class OneTimeBLEGateway: OneTimeGateway {
    var twoWayPeripheral: BLETwoWayPeripheral?
    
    
    public func createTwoWayPeripheral() {
        twoWayPeripheral = BLETwoWayPeripheral(readCallback: readCallback(characteristic:), writeCallback: writeCallback(value:central:), notifyCallback: notifyCallback(characteristic:))
    }
    
    func readCallback(characteristic: CBCharacteristic) -> String {
        if characteristic.uuid == bleCharacteristics().read {
            return gateway.toString()
        }
        return ""
    }
    
    func writeCallback(value: String, central: CBCentral) {
        guard let gatewayResponse = GatewayModel().getGatewayResponseFromJSON(jsonString: value) else {
            return
        }
        let gatewayUsePowerObject = GatewayUsePower(totalPower: gateway.totalPower, partnerName: gateway.partnerName, userId: gatewayResponse.userId, signature: gatewayResponse.signature, gatewayName: gateway.gatewayName, partnerDisplayName: self.partnerDisplayName, description: self.description)
        let path = "/user/userId/\(gatewayResponse.userId)/power/gateway/\(gateway.gatewayName)"
        let jsonData = Utils().encodableToJSONData(gatewayUsePowerObject)
        Network().put(body: jsonData, path: path) { error, resp in
            if error == nil {
                //TODO: What happens here?
                return
            }
            self.twoWayPeripheral!.notifySubscribedCentral(update: "power use success!", central: central)
        }
    }
    
    func notifyCallback(characteristic: CBCharacteristic) -> String {
        return ""
    }
}
