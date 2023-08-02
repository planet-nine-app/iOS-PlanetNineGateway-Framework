//
//  PlanetNineUser.swift
//  PlanetNineGateway
//
//  Created by Zach Babb on 2/9/19.
//  Copyright © 2019 Planet Nine. All rights reserved.
//

import Foundation

public struct PNUser: Codable {
    public var userUUID: String
    public var name: String
    public var powerOrdinal: Int
    public var lastPowerUsed: String
    public var powerRegenerationRate: Double
    public var globalRegenerationRate: Double
    public var publicKey: String
    public var nineum: [String]
    public var currentPower: Int
    public init() {
        userUUID = ""
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

class PlanetNineUser {
    
    class func getUser(userUUID: String, gatewayTimestampTupleWithSignature: GatewayTimestampTupleWithSignature, callback: @escaping (Error?, PNUser?) -> Void) {
        Network().getUserByUUID(userUUID: userUUID, gatewayAccessToken: gatewayTimestampTupleWithSignature.gatewayAccessToken, timestamp: gatewayTimestampTupleWithSignature.timestamp, signature: gatewayTimestampTupleWithSignature.signature) { error, data in
            if error != nil {
                callback(error, nil)
                return
            }
            if let data = data,
               let pnUser = UserModel.getUserFromJSONData(userData: data) {
                callback(nil, pnUser)
            } else {
                callback(NSError(domain: "", code: 404, userInfo: nil), nil)
            }
        }
    }
}
