//
//  BLEUtils.swift
//  BLETester
//
//  Created by Zach Babb on 12/13/18.
//  Copyright © 2018 Planet Nine. All rights reserved.
//

import Foundation
import CoreBluetooth

struct bleServices {
    let twoWay = CBUUID(string: "5995AB90-709A-4735-AAF2-DF2C8B061BB4")
}

struct bleCharacteristics {
    let read = CBUUID(string: "3558E2EC-BF6C-41F0-BC9F-EBB51B8C87CE")
    let write = CBUUID(string: "4D8D84E5-5889-4310-80BF-0D44DCB49762")
    let notify = CBUUID(string: "CD6984D2-5055-4033-A42E-BB039FC6EF6B")
}
