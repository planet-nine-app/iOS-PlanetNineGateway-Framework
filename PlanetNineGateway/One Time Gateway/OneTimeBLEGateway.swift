//
//  OneTimeBLEGateway.swift
//  PlanetNineGateway
//
//  Created by Zach Babb on 2/6/19.
//  Copyright © 2019 Planet Nine. All rights reserved.
//

import Foundation
import CoreBluetooth

class OneTimeBLEGateway: OneTimeGateway, BLEGateway {
    var twoWayPeripheral: BLETwoWayPeripheral?
    let networkCallback: (Error?, Data?) -> Void
    
    init(totalPower: Int, partnerName: String, gatewayName: String, gatewayURL: String, partnerDisplayName: String, description: String, networkCallback: @escaping (Error?, Data?) -> Void) {
        self.networkCallback = networkCallback
        super.init(totalPower: totalPower, partnerName: partnerName, gatewayName: gatewayName, gatewayURL: gatewayURL, partnerDisplayName: partnerDisplayName, description: description)
        if gateway.toString().count > 182 {
            print("Your gateway is too big and won't work with BLE")
            print("Future versions will slim down the gateway payload")
        }
    }
    
    func createTwoWayPeripheral() {
        twoWayPeripheral = BLETwoWayPeripheral(readCallback: readCallback(characteristic:), writeCallback: writeCallback(value:central:), notifyCallback: notifyCallback(characteristic:))
    }
    
    func readCallback(characteristic: CBCharacteristic) -> String {
        print("Calling read callback")
        if characteristic.uuid == bleCharacteristics().read {
            print(gateway.toString())
            return gateway.toString()
        }
        return ""
    }
    
    func writeCallback(value: String, central: CBCentral) {
        print("Calling write callback")
        guard let gatewayResponse = GatewayModel().getGatewayResponseFromJSON(jsonString: value) else {
            return
        }
        let gatewayUsePowerObject = GatewayUsePower(totalPower: gateway.totalPower, partnerName: gateway.partnerName, userUUID: gatewayResponse.userUUID, signature: gatewayResponse.signature, gatewayName: gateway.gatewayName, partnerDisplayName: self.partnerDisplayName, description: self.description, timestamp: gatewayResponse.timestamp)
        guard let urlEncodedGatewayName = gateway.gatewayName.urlEncoded() else {
            print("Gateway name's must be URL encodable")
            return
        }
        let path = "/user/userUUID/\(gatewayResponse.userUUID)/power/gateway/\(urlEncodedGatewayName)"
        let jsonData = Utils().encodableToJSONData(gatewayUsePowerObject)
        print(path)
        print(gatewayUsePowerObject)
        Network().put(body: jsonData, path: path) { error, resp in
            if error != nil {
                self.networkCallback(error, resp)
                print("You got an error on your put")
                return
            }
            print("Calling successCallback")
            guard let userData = resp else {
                self.networkCallback(error, resp)
                return
            }
            let user = UserModel().getUserFromJSONData(userData: userData)!
            let pnUser = PlanetNineUser.getPNUserForUser(currentUser: user)
            self.networkCallback(error, Utils().encodableToJSONData(pnUser))
            self.twoWayPeripheral!.notifySubscribedCentral(update: "power use success!", central: central)
        }
    }
    
    func notifyCallback(characteristic: CBCharacteristic) -> String {
        return ""
    }
}
