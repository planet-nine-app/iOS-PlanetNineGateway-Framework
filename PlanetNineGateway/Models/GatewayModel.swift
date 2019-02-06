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
    func toString() -> String {
        return "{\"totalPower\":\(totalPower),\"gatewayName\":\"\(gatewayName)\",\"partnerName\":\"\(partnerName)\",\"gatewayURL\":\"\(gatewayURL)\"}"
    }
}

struct GatewayResponse: Codable {
    var userId: Int
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

class GatewayModel {
    func getGatewayResponseFromJSON(jsonString: String) -> GatewayResponse? {
        let jsonData = jsonString.data(using: .utf8)
        var decodedGatewayResponse = GatewayResponse(userId: 0, signature: "")
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
}
