//
//  PlanetNineUser.swift
//  PlanetNineGateway
//
//  Created by Zach Babb on 2/9/19.
//  Copyright © 2019 Planet Nine. All rights reserved.
//

import Foundation

public struct PNUser: Codable {
    public var userId: Int
    public var name: String
    public var powerOrdinal: Int
    public var lastPowerUsed: String
    public var powerRegenerationRate: Double
    public var globalRegenerationRate: Double
    public var publicKey: String
    public var nineum: [String]
    public var currentPower: Int
    public init() {
        userId = 0
        name = ""
        powerOrdinal = 0
        lastPowerUsed = ""
        powerRegenerationRate = 1.0
        globalRegenerationRate = 1.666667
        publicKey = ""
        nineum = [String]()
        currentPower = 0
    }
}

public class PlanetNineUser {
    
    var user: User?
    let gatewayName: String
    
    public init(userId: Int, gatewayName: String, timestamp: String, signature: String, callback: ((PNUser) -> Void)?) {
        self.gatewayName = gatewayName
        Network().getUserById(userId: userId, gatewayName: gatewayName, timestamp: timestamp, signature: signature) { error, resp in
            if error != nil {
                return
            }
            guard let jsonData = resp else {
                return
            }
            self.user = UserModel().getUserFromJSONData(userData: jsonData)
            if callback != nil {
                guard let pnUser = self.getUser() else {
                    return
                }
                callback!(pnUser)
            }
        }
    }
    
    public func getUser() -> PNUser? {
        guard let currentUser = user else {
            return nil
        }
        var pnUser = PNUser()
        pnUser.userId = currentUser.userId
        pnUser.name = currentUser.name
        pnUser.powerOrdinal = currentUser.powerOrdinal
        pnUser.lastPowerUsed = currentUser.lastPowerUsed
        pnUser.powerRegenerationRate = currentUser.powerRegenerationRate
        pnUser.globalRegenerationRate = currentUser.globalRegenerationRate
        pnUser.publicKey = currentUser.publicKey
        pnUser.nineum = currentUser.nineum
        pnUser.currentPower = currentUser.currentPower
        return pnUser
    }
    
    public func refreshUser(timestamp: String, signature: String) {
        guard let currentUser = user else {
            print("No user retrieved yet")
            return
        }
        Network().getUserById(userId: currentUser.userId, gatewayName: gatewayName, timestamp: timestamp, signature: signature) { error, resp in
            if error != nil {
                return
            }
            guard let jsonData = resp else {
                return
            }
            self.user = UserModel().getUserFromJSONData(userData: jsonData)
        }
    }
    
    class func getPNUserForUser(currentUser: User) -> PNUser {
        var pnUser = PNUser()
        pnUser.userId = currentUser.userId
        pnUser.name = currentUser.name
        pnUser.powerOrdinal = currentUser.powerOrdinal
        pnUser.lastPowerUsed = currentUser.lastPowerUsed
        pnUser.powerRegenerationRate = currentUser.powerRegenerationRate
        pnUser.globalRegenerationRate = currentUser.globalRegenerationRate
        pnUser.publicKey = currentUser.publicKey
        pnUser.nineum = currentUser.nineum
        pnUser.currentPower = currentUser.currentPower
        return pnUser
    }
    
    public class func getPNUserFromJSONData(jsonData: Data) -> PNUser? {
        var decodedPNUser = PNUser()
        do {
            decodedPNUser = try JSONDecoder().decode(PNUser.self, from: jsonData)
        } catch {
            return nil
        }
        if decodedPNUser.userId == 0 {
            return nil
        }
        return decodedPNUser
    }
}
