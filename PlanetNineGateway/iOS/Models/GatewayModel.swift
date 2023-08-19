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

public struct Gateway: Codable {
    public var totalPower: Int
    public var partnerName: String
    public var partnerDisplayName: String
    public var description: String
    func toString() -> String {
        return "{\"totalPower\":\(totalPower),\"partnerName\":\"\(partnerName)\",\"partnerDisplayName\":\"\(partnerDisplayName)\",\"description\":\"\(description)\"}"
    }
    func toBLEString() -> String {
        return "{\"t\":\(totalPower),\"p\":\"\(partnerName)\",\"n\":\"\(partnerDisplayName)\",\"d\":\"\(description)\"}"
    }
}

struct BLEJSONGateway: Codable {
    var t = 0
    var p = ""
    var n = ""
    var d = ""
}

struct GatewayResponse: Codable {
    var userUUID: String
    var ordinal: Int
    var signature: String
    var timestamp: String
    var ongoing: Bool
    
    func toString() -> String {
        return "{\"userUUID\":\"\(userUUID)\",\"ordinal\":\(ordinal),\"signature\":\"\(signature)\",\"timestamp\":\"\(timestamp)\",\"ongoing\":\(ongoing)}"
    }
}

struct DeviceResponse: Codable {
    var userUUID: String
    var currentPower: Int
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
    
    func toBLEString() -> String {
        return "{\"g\":\"\(gatewayAccessToken)\",\"p\":\"\(publicKey)\",\"t\":\"\(timestamp)\",\"s\":\"\(signature)\"}"
    }
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
    func getGatewayFromJSONString(jsonString: String) -> Gateway {
        let jsonData = jsonString.data(using: .utf8)
        var decodedGateway = BLEJSONGateway()
        do {
            decodedGateway = try JSONDecoder().decode(BLEJSONGateway.self, from: jsonData!)
        } catch {
            print("Error getting gateway")
            print(error)
        }
        let gateway = Gateway(totalPower: decodedGateway.t, partnerName: decodedGateway.p, partnerDisplayName: decodedGateway.n, description: decodedGateway.d)
        return gateway
    }
    
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
    
    func getDeviceResponseFromJSON(jsonString: String) -> DeviceResponse? {
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        var decodedDeviceResponse = DeviceResponse(userUUID: "", currentPower: 0)
        do {
            decodedDeviceResponse = try JSONDecoder().decode(DeviceResponse.self, from: jsonData)
        } catch {
            print("Error getting device response")
            print(error)
            return nil
        }
        return decodedDeviceResponse
    }
        
    func addSignatureToGatewayKey(gatewayKeyObject: GatewayKey, signature: String) -> GatewayKeyWithSignature {
        let gatewayKeyObjectWithSignature = GatewayKeyWithSignature(gatewayAccessToken: gatewayKeyObject.gatewayAccessToken, publicKey: gatewayKeyObject.publicKey, timestamp: gatewayKeyObject.timestamp, signature: signature)
        return gatewayKeyObjectWithSignature
    }
}
