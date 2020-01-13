//
//  OneTimeBLEUserGateway.swift
//  PlanetNineGateway
//
//  Created by Zach Babb on 1/12/20.
//  Copyright © 2020 Planet Nine. All rights reserved.
//

import Foundation
import CoreBluetooth

class OneTimeBLEUserGateway: BLEGateway {
    
    let userGateway: UserGateway
    var twoWayPeripheral: BLETwoWayPeripheral?
    
    init(gatewayName: String, gatewayURL: String, callback: @escaping (Error?, Data?) -> Void) {
        userGateway = UserGateway(gatewayName: gatewayName, gatewayURL: gatewayURL)
    }
    
    func createTwoWayPeripheral() {
        twoWayPeripheral = BLETwoWayPeripheral(readCallback: readCallback(characteristic:), writeCallback: writeCallback(value:central:), notifyCallback: notifyCallback(characteristic:))
    }
    
    func readCallback(characteristic: CBCharacteristic) -> String {
        if characteristic.uuid == bleCharacteristics().read {
            print(userGateway.toString())
            return userGateway.toString()
        }
        return ""
    }
    
    func writeCallback(value: String, central: CBCentral) {
        guard let gatewayResponse = GatewayModel().getGatewayResponseFromJSON(jsonString: value) else {
            return
        }
        
        // Use response to create the new payload
        
        // Send the payload to the server
        
        // Result is the user
        
    }
    
    func notifyCallback(characteristic: CBCharacteristic) -> String {
        return ""
    }
    
    
}
