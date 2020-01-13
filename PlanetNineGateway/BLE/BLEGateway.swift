//
//  BLEGateway.swift
//  PlanetNineGateway
//
//  Created by Zach Babb on 1/12/20.
//  Copyright © 2020 Planet Nine. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BLEGateway {
    func createTwoWayPeripheral()
    func readCallback(characteristic: CBCharacteristic) -> String
    func writeCallback(value: String, central: CBCentral)
    func notifyCallback(characteristic: CBCharacteristic) -> String
}
