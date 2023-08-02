//
//  UsePowerModel.swift
//  Planet Nine
//
//  Created by Zach Babb on 11/15/18.
//  Copyright © 2018 Planet Nine. All rights reserved.
//

import Foundation

struct UsePowerObject: Codable {
    var totalPower: Int
    var partnerName: String
    var ordinal: Int
    let timestamp = "".getTime()
    func toString() -> String {
        return "{\"totalPower\":\(totalPower),\"partnerName\":\"\(partnerName)\",\"ordinal\":\(ordinal),\"timestamp\":\"\(timestamp)\"}"
    }
}

struct UsePowerObjectWithSignature: Codable {
    var totalPower: Int
    var partnerName: String
    var ordinal: Int
    let timestamp: String
    var signature: String
    let description = "Exploring Planet Nine"
}

struct UsePowerAtOngoingGateway {
    let totalPower: Int
    let partnerName: String
    let gatewayAccessToken: String
    let userUUID: String
    let ordinal: Int
    let description: String
    let timestamp = "".getTime()
    func toString() -> String {
        return "{\"totalPower\":\(totalPower),\"partnerName\":\"\(partnerName)\",\"gatewayAccessToken\":\"\(gatewayAccessToken)\",\"userUUID\":\"\(userUUID)\",\"ordinal\":\(ordinal),\"timestamp\":\"\(timestamp)\"}"
        
    }
}

struct UsePowerAtOngoingGatewayWithSignature: Codable {
    let totalPower: Int
    let partnerName: String
    let gatewayAccessToken: String
    let userUUID: String
    let ordinal: Int
    let description: String
    let timestamp: String
    let signature: String
}
