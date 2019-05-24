//
//  GatewayModel.swift
//  PlanetNineGateway
//
//  Created by Zach Babb on 2/6/19.
//  Copyright © 2019 Planet Nine. All rights reserved.
//

import Foundation

struct Gateway: Codable {
    var totalPower: Int
    var partnerName: String
    var gatewayName: String
    var gatewayURL: String
    var partnerDisplayName: String
    var description: String
    func toString() -> String {
        return "{\"totalPower\":\(totalPower),\"gatewayName\":\"\(gatewayName)\",\"partnerName\":\"\(partnerName)\",\"gatewayURL\":\"\(gatewayURL)\",\"partnerDisplayName\":\"\(partnerDisplayName)\",\"description\":\"\(description)\"}"
    }
}

struct GatewayResponse: Codable {
    var userId: Int
    var username: String
    var signature: String
}

struct GatewayUsePower: Codable {
    var totalPower: Int
    var partnerName: String
    var userId: Int
    var signature: String
    var gatewayName: String
    var partnerDisplayName: String
    var description: String
}

public struct GatewayKey: Codable {
    public var gatewayName: String
    public var publicKey: String
    let timestamp = "".getTime()
    public init(gatewayName: String, publicKey: String) {
        self.gatewayName = gatewayName
        self.publicKey = publicKey
    }
    func toString() -> String {
        return "{\"gatewayName\":\"\(gatewayName)\",\"publicKey\":\"\(publicKey)\"}"
    }
}

struct GatewayKeyWithSignature: Codable {
    var gatewayName: String
    var publicKey: String
    let timestamp: String
    var signature: String
}

public struct GatewayTimestampTuple {
    public let gatewayName: String
    let timestamp = "".getTime()
    public init(gatewayName: String) {
        self.gatewayName = gatewayName
    }
    func toString() -> String {
        return "{\"gatewayName\":\"\(gatewayName)\",\"timestamp\":\"\(timestamp)\"}"
    }
}

class GatewayModel {
    func getGatewayResponseFromJSON(jsonString: String) -> GatewayResponse? {
        let jsonData = jsonString.data(using: .utf8)
        var decodedGatewayResponse = GatewayResponse(userId: 0, username: "", signature: "")
        do {
            decodedGatewayResponse = try JSONDecoder().decode(GatewayResponse.self, from: jsonData!)
        } catch {
            print("Error getting gateway")
            print(error)
            return nil
        }
        if decodedGatewayResponse.userId == 0 {
            return nil
        }
        return decodedGatewayResponse
    }
    
    func addSignatureToGatewayKey(gatewayKeyObject: GatewayKey, signature: String) -> GatewayKeyWithSignature {
        let gatewayKeyObjectWithSignature = GatewayKeyWithSignature(gatewayName: gatewayKeyObject.gatewayName, publicKey: gatewayKeyObject.publicKey, timestamp: gatewayKeyObject.timestamp, signature: signature)
        return gatewayKeyObjectWithSignature
    }
}
