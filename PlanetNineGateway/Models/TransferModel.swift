//
//  TransferModel.swift
//  PlanetNineGateway
//
//  Created by Zach Babb on 5/28/19.
//  Copyright © 2019 Planet Nine. All rights reserved.
//

import Foundation


public struct TransferRequest: Codable {
    public let userId: Int
    public let sourceUserId: Int
    public let destinationUserId: Int
    public let nineumUniqueIds: [String]
    public let price: Int
    public let currencyName: String
    public let ordinal: Int
    public let timestamp = "".getTime()
    public init(userId: Int, destinationUserId: Int, nineumUniqueIds: [String], price: Int?, ordinal: Int) {
        self.userId = userId
        self.sourceUserId = userId
        self.destinationUserId = destinationUserId
        self.nineumUniqueIds = nineumUniqueIds
        self.price = price ?? 0
        self.currencyName = "USD"
        self.ordinal = ordinal
    }
    public func toString() -> String {
        return "{\"userId\":\(userId),\"sourceUserId\":\(sourceUserId),\"destinationUsername\":\(destinationUserId),\"nineumUniqueIds\":\(nineumUniqueIds),\"price\":\(price),\"currencyName\":\"\(currencyName)\",\"ordinal\":\(ordinal),\"timestamp\":\"\(timestamp)\"}"
    }
}

struct TransferRequestWithSignature: Codable {
    let userId: Int
    let sourceUserId: Int
    let destinationUserId: Int
    let nineumUniqueIds: [String]
    let price: Int
    let currencyName: String
    let ordinal: Int
    let timestamp = "".getTime()
    let signature: String
}

class TransferModel {
    func addSignatureToTransferRequest(transferRequest: TransferRequest, signature: String) -> TransferRequestWithSignature {
        let transferRequestWithSignature = TransferRequestWithSignature(userId: transferRequest.userId, sourceUserId: transferRequest.sourceUserId, destinationUserId: transferRequest.destinationUserId, nineumUniqueIds: transferRequest.nineumUniqueIds, price: transferRequest.price, currencyName: transferRequest.currencyName, ordinal: transferRequest.ordinal, signature: signature)
        return transferRequestWithSignature
    }
}
