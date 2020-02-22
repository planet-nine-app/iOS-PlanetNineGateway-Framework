//
//  GatewayModel.swift
//  PlanetNineGateway
//
//  Created by Zach Babb on 2/6/19.
//  Copyright © 2019 Planet Nine. All rights reserved.
//

import Foundation

struct UserGateway: Codable {
    var gatewayName: String
    var gatewayURL: String
    func toString() -> String {
        return "{\"gatewayName\":\"\(gatewayName)\",\"gatewayURL\":\"\(gatewayURL)\"}"
    }
}

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
    var userUUID: String
    var username: String
    var signature: String
    var timestamp: String
}

struct GatewayUsePower: Codable {
    var totalPower: Int
    var partnerName: String
    var userUUID: String
    var signature: String
    var gatewayName: String
    var partnerDisplayName: String
    var description: String
    var timestamp: String
}

public struct GatewayKey: Codable {
    public var gatewayName: String
    public var publicKey: String
    public let timestamp = "".getTime()
    public init(gatewayName: String, publicKey: String) {
        self.gatewayName = gatewayName
        self.publicKey = publicKey
    }
    public func toString() -> String {
        return "{\"gatewayName\":\"\(gatewayName)\",\"publicKey\":\"\(publicKey)\",\"timestamp\":\"\(timestamp)\"}"
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
    public let timestamp = "".getTime()
    public init(gatewayName: String) {
        self.gatewayName = gatewayName
    }
    public func toString() -> String {
        return "{\"gatewayName\":\"\(gatewayName)\",\"timestamp\":\"\(timestamp)\"}"
    }
}

public struct UserGatewayTimestampTriple {
    public let userUUID: String
    public let gatewayName: String
    public let timestamp = "".getTime()
    public init(userUUID: String, gatewayName: String) {
        self.userUUID = userUUID
        self.gatewayName = gatewayName
    }
    public func toString() -> String {
        return "{\"userUUID\":\(userUUID),\"gatewayName\":\"\(gatewayName)\",\"timestamp\":\"\(timestamp)\"}"
    }
}

public struct UserGatewayTimestampTripleWithSignature {
    public let userUUID: String
    public let gatewayName: String
    public let timestamp: String
    public let signature: String
}

class GatewayModel {
    func getGatewayResponseFromJSON(jsonString: String) -> GatewayResponse? {
        let jsonData = jsonString.data(using: .utf8)
        var decodedGatewayResponse = GatewayResponse(userUUID: "", username: "", signature: "", timestamp: "")
        do {
            decodedGatewayResponse = try JSONDecoder().decode(GatewayResponse.self, from: jsonData!)
        } catch {
            print("Error getting gateway")
            print(error)
            return nil
        }
        if decodedGatewayResponse.userUUID == "" {
            return nil
        }
        return decodedGatewayResponse
    }
        
    func addSignatureToGatewayKey(gatewayKeyObject: GatewayKey, signature: String) -> GatewayKeyWithSignature {
        let gatewayKeyObjectWithSignature = GatewayKeyWithSignature(gatewayName: gatewayKeyObject.gatewayName, publicKey: gatewayKeyObject.publicKey, timestamp: gatewayKeyObject.timestamp, signature: signature)
        return gatewayKeyObjectWithSignature
    }
}
