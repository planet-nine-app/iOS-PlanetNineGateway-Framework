//
//  OneTimeBLEGateway.swift
//  PlanetNineGateway
//
//  Created by Zach Babb on 2/6/19.
//  Copyright © 2019 Planet Nine. All rights reserved.
//

import Foundation
import CoreBluetooth

public class OneTimeBLEGateway: OneTimeGateway {
    var twoWayPeripheral: BLETwoWayPeripheral?
    let successCallback: (String) -> Void
    
    public init(totalPower: Int, partnerName: String, gatewayName: String, gatewayURL: String, partnerDisplayName: String, description: String, successCallback: @escaping (String) -> Void) {
        self.successCallback = successCallback
        super.init(totalPower: totalPower, partnerName: partnerName, gatewayName: gatewayName, gatewayURL: gatewayURL, partnerDisplayName: partnerDisplayName, description: description)
    }
    
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
            if error != nil {
                //TODO: What happens here?
                print("You got an error on your put")
                print(error)
                return
            }
            print("Calling successCallback")
            self.successCallback(gatewayResponse.username)
            self.twoWayPeripheral!.notifySubscribedCentral(update: "power use success!", central: central)
        }
    }
    
    func notifyCallback(characteristic: CBCharacteristic) -> String {
        return ""
    }
}
