//
//  PlanetNineUser.swift
//  PlanetNineGateway
//
//  Created by Zach Babb on 2/9/19.
//  Copyright © 2019 Planet Nine. All rights reserved.
//

import Foundation

public struct PNUser: Codable {
    let userId: Int
    let name: String
    let powerOrdinal: Int
    let lastPowerUsed: String
    let powerRegenerationRate: Double
    let globalRegenerationRate: Double
    let publicKey: String
    let nineum: [String]
    let currentPower: Int
}

public class PlanetNineUser {
    
    var user: User?
    
    public init(userId: Int, gatewayName: String) {
        Network().getUserById(userId: userId) { error, resp in
            if error != nil {
                return
            }
            guard let jsonData = resp else {
                return
            }
            self.user = UserModel().getUserFromJSONData(userData: jsonData)
        }
    }
    
    public func getUser() -> PNUser? {
        guard let currentUser = user else {
            return nil
        }
        let pnUser = PNUser(userId: currentUser.userId, name: currentUser.name, powerOrdinal: currentUser.powerOrdinal, lastPowerUsed: currentUser.lastPowerUsed, powerRegenerationRate: currentUser.powerRegenerationRate, globalRegenerationRate: currentUser.globalRegenerationRate, publicKey: currentUser.publicKey, nineum: currentUser.nineum, currentPower: currentUser.currentPower)
        return pnUser
    }
}
