//
//  MintNineumModel.swift
//
//  Created by Zach Babb on 3/18/20.
//

import Foundation

public struct MintNineumRequest: Codable {
    let partnerUUID: String
    let flavors: [String]
    let ordinal: Int
    let timestamp = "".getTime()
    func toString() -> String {
        var flavorString = ""
        flavors.forEach { flavor in
            flavorString += "\""
            flavorString += flavor
            flavorString += "\""
            flavorString += ","
        }
        flavorString.popLast()
        
        return """
        {"partnerUUID":"\(partnerUUID)","flavors":[\(flavorString)],"ordinal":\(ordinal),"timestamp":"\(timestamp)"}
        """
    }
}

internal struct MintNineumRequestWithSignature: Codable {
    let partnerUUID: String
    let flavors: [String]
    let ordinal: Int
    let timestamp: String
    let signature: String
}

public struct ApproveTransfer: Codable {
    let userId: Int
    let nineumTransactionId: Int
    let ordinal: Int
    let timestamp = "".getTime()
    func toString() -> String {
        return "{\"userId\":\(userId),\"nineumTransactionId\":\(nineumTransactionId),\"ordinal\":\(ordinal),\"timestamp\":\"\(timestamp)\"}"
    }
}

public struct ApproveTransferWithSignature: Codable {
    let userId: Int
    let nineumTransactionId: Int
    let ordinal: Int
    let timestamp: String
    let signature: String
}

public struct NineumTransferId: Codable {
    public var nineumTransactionId: Int = 0
    
    public init() {
        
    }
}
