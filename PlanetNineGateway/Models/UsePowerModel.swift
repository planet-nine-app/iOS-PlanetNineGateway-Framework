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

public struct UsePowerAtOngoingGateway: Codable {
    var totalPower: Int
    var partnerName: String
    var gatewayName: String
    var userUUID: String
    var publicKey: String
    var ordinal: Int
    var description: String
    let timestamp = "".getTime()
    public init(totalPower: Int, partnerName: String, gatewayName: String, userUUID: String, publicKey: String, ordinal: Int, description: String) {
        self.totalPower = totalPower
        self.partnerName = partnerName
        self.gatewayName = gatewayName
        self.userUUID = userUUID
        self.publicKey = publicKey
        self.ordinal = ordinal
        self.description = description
    }
    public func toString() -> String {
        return "{\"totalPower\":\(totalPower),\"partnerName\":\"\(partnerName)\",\"gatewayName\":\"\(gatewayName)\",\"userUUID\":\(userUUID),\"publicKey\":\"\(publicKey)\",\"ordinal\":\(ordinal),\"timestamp\":\"\(timestamp)\"}"
    }
}

public struct UsePowerAtOngoingGatewayWithSignature: Codable {
    let totalPower: Int
    let partnerName: String
    let gatewayName: String
    let userUUID: String
    let publicKey: String
    let ordinal: Int
    let description: String
    let timestamp: String
    let signature: String
}

public class UsePowerModel {
    
    public init() {
        
    }
    
    func addSignatureToUsePowerObject(object: UsePowerObject, signature: String) -> UsePowerObjectWithSignature {
        let objectWithSignature = UsePowerObjectWithSignature(totalPower: object.totalPower, partnerName: object.partnerName, ordinal: object.ordinal, timestamp: object.timestamp, signature: signature)
        return objectWithSignature
    }
    
    public func addSignatureToUsePowerAtOngoingGatewayObject(object: UsePowerAtOngoingGateway, signature: String) -> UsePowerAtOngoingGatewayWithSignature {
        let objectWithSignature = UsePowerAtOngoingGatewayWithSignature(totalPower: object.totalPower, partnerName: object.partnerName, gatewayName: object.gatewayName, userUUID: object.userUUID, publicKey: object.publicKey, ordinal: object.ordinal, description: object.description, timestamp: object.timestamp, signature: signature)
        return objectWithSignature
    }
    
    public func usePowerAtOngoingGateway(gatewayObjectWithSignature: UsePowerAtOngoingGatewayWithSignature, callback: ((Error?, Data?) -> Void)?) {
        var callbackToUse: ((Error?, Data?) -> Void) = { error, resp in }
        if callback != nil {
            callbackToUse = callback!
        }
        Network().usePowerAtOngoingGateway(usePowerAtOngoingGatewayWithSignature: gatewayObjectWithSignature, callback: callbackToUse)
    }
}
