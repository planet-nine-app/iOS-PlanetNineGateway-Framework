//
//  MintNineumModel.swift
//  Braintree
//
//  Created by Zach Babb on 3/18/20.
//

import Foundation

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
