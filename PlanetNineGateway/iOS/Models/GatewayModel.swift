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
    var partnerDisplayName: String
    var description: String
    func toString() -> String {
        return "{\"totalPower\":\(totalPower),\"partnerName\":\"\(partnerName)\",\"partnerDisplayName\":\"\(partnerDisplayName)\",\"description\":\"\(description)\"}"
    }
    func toBLEString() -> String {
        return "{\"t\":\(totalPower),\"p\":\"\(partnerName)\",\"n\":\"\(partnerDisplayName)\",\"d\":\"\(description)\"}"
    }
}

struct GatewayResponse: Codable {
    var userUUID: String
    var ordinal: Int
    var signature: String
    var timestamp: String
    var ongoing: Bool
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

struct GatewayKey: Codable {
    var gatewayAccessToken: String
    var publicKey: String
    let timestamp = "".getTime()
    func toString() -> String {
        return "{\"gatewayAccessToken\":\"\(gatewayAccessToken)\",\"publicKey\":\"\(publicKey)\",\"timestamp\":\"\(timestamp)\"}"
    }
}

struct GatewayKeyWithSignature: Codable {
    var gatewayAccessToken: String
    var publicKey: String
    let timestamp: String
    var signature: String
}

struct GatewayTimestampTuple {
    let gatewayAccessToken: String
    let timestamp = "".getTime()
    func toString() -> String {
        return "{\"gatewayAccessToken\":\"\(gatewayAccessToken)\",\"timestamp\":\"\(timestamp)\"}"
    }
}

struct GatewayTimestampTupleWithSignature {
    let gatewayAccessToken: String
    let timestamp: String
    let signature: String
}

struct UserGatewayTimestampTriple {
    let userUUID: String
    let gatewayName: String
    let timestamp = "".getTime()
    func toString() -> String {
        return "{\"userUUID\":\(userUUID),\"gatewayName\":\"\(gatewayName)\",\"timestamp\":\"\(timestamp)\"}"
    }
}

struct UserGatewayTimestampTripleWithSignature {
    let userUUID: String
    let gatewayName: String
    let timestamp: String
    let signature: String
}

class GatewayModel {
    func getGatewayResponseFromJSON(jsonString: String) -> GatewayResponse? {
        let jsonData = jsonString.data(using: .utf8)
        var decodedGatewayResponse = GatewayResponse(userUUID: "", ordinal: 0, signature: "", timestamp: "", ongoing: false)
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
        let gatewayKeyObjectWithSignature = GatewayKeyWithSignature(gatewayAccessToken: gatewayKeyObject.gatewayAccessToken, publicKey: gatewayKeyObject.publicKey, timestamp: gatewayKeyObject.timestamp, signature: signature)
        return gatewayKeyObjectWithSignature
    }
}
