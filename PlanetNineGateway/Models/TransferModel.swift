//
//  TransferModel.swift
//  PlanetNineGateway
//
//  Created by Zach Babb on 5/28/19.
//  Copyright © 2019 Planet Nine. All rights reserved.
//

import Foundation


public struct TransferRequest: Codable {
    public let userUUID: String
    public let sourceUserUUID: String
    public let destinationUserUUID: String
    public let nineumUniqueIds: [String]
    public let price: Int
    public let currencyName: String
    public let ordinal: Int
    public let timestamp = "".getTime()
    public init(userUUID: String, destinationUserUUID: String, nineumUniqueIds: [String], price: Int?, ordinal: Int) {
        self.userUUID = userUUID
        self.sourceUserUUID = userUUID
        self.destinationUserUUID = destinationUserUUID
        self.nineumUniqueIds = nineumUniqueIds
        self.price = price ?? 0
        self.currencyName = "USD"
        self.ordinal = ordinal
    }
    public func toString() -> String {
        return "{\"userUUID\":\(userUUID),\"sourceUserUUID\":\(sourceUserUUID),\"destinationUserUUID\":\(destinationUserUUID),\"nineumUniqueIds\":\(nineumUniqueIds),\"price\":\(price),\"currencyName\":\"\(currencyName)\",\"ordinal\":\(ordinal),\"timestamp\":\"\(timestamp)\"}"
    }
}

struct TransferRequestWithSignature: Codable {
    let userUUID: String
    let sourceUserUUID: String
    let destinationUserUUID: String
    let nineumUniqueIds: [String]
    let price: Int
    let currencyName: String
    let ordinal: Int
    let timestamp: String
    let signature: String
}

class TransferModel {
    func addSignatureToTransferRequest(transferRequest: TransferRequest, signature: String) -> TransferRequestWithSignature {
        let transferRequestWithSignature = TransferRequestWithSignature(userUUID: transferRequest.userUUID, sourceUserUUID: transferRequest.sourceUserUUID, destinationUserUUID: transferRequest.destinationUserUUID, nineumUniqueIds: transferRequest.nineumUniqueIds, price: transferRequest.price, currencyName: transferRequest.currencyName, ordinal: transferRequest.ordinal, timestamp: transferRequest.timestamp, signature: signature)
        return transferRequestWithSignature
    }
}
