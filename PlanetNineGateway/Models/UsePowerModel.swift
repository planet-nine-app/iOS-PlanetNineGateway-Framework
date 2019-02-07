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
    func toString() -> String {
        return "{\"totalPower\":\(totalPower),\"partnerName\":\"\(partnerName)\",\"ordinal\":\(ordinal)}"
    }
}

struct UsePowerObjectWithSignature: Codable {
    var totalPower: Int
    var partnerName: String
    var ordinal: Int
    var signature: String
    let description = "Exploring Planet Nine"
}

struct UsePowerAtOngoingGateway: Codable {
    let totalPower: Int
    let partnerName: String
    let gatewayName: String
    let userId: Int
    let publicKey: String
    let ordinal: Int
    func toString() -> String {
        return "{\"totalPower\":\(totalPower),\"partnerName\":\"\(partnerName)\",\"gatewayName\":\"\(gatewayName)\",\"userId\":\(userId),\"publicKey\":\"\(publicKey)\",\"ordinal\":\(ordinal)}"
    }
}

struct UsePowerAtOngoingGatewayWithSignature: Codable {
    let totalPower: Int
    let partnerName: String
    let gatewayName: String
    let userId: Int
    let publicKey: String
    let ordinal: Int
    let description = "Using Power in the ongoing test app"
    let signature: String
}

class UsePowerModel {
    
    func addSignatureToUsePowerObject(object: UsePowerObject, signature: String) -> UsePowerObjectWithSignature {
        let objectWithSignature = UsePowerObjectWithSignature(totalPower: object.totalPower, partnerName: object.partnerName, ordinal: object.ordinal, signature: signature)
        return objectWithSignature
    }
    
    func addSignatureToUsePowerAtOngoingGatewayObject(object: UsePowerAtOngoingGateway, signature: String) -> UsePowerAtOngoingGatewayWithSignature {
        let objectWithSignature = UsePowerAtOngoingGatewayWithSignature(totalPower: object.totalPower, partnerName: object.partnerName, gatewayName: object.gatewayName, userId: object.userId, publicKey: object.publicKey, ordinal: object.ordinal, signature: signature)
        return objectWithSignature
    }
}
