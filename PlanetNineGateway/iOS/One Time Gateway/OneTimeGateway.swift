//
//  OneTimeGateway.swift
//  PlanetNineGateway
//
//  Created by Zach Babb on 1/29/19.
//  Copyright © 2019 Planet Nine. All rights reserved.
//

import Foundation

struct PowerUsage: Codable {
    let totalPower: Int
    let partnerName: String
    let userUUID: String
    let ordinal: Int
    let signature: String
    let partnerDisplayName: String
    let description: String
    let timestamp: String
}

class OneTimeGateway {
    
    class func askForPowerUsage(totalPower: Int, partnerName: String, gatewayURL: String, partnerDisplayName: String, description: String, cantOpen: (() -> Void)?) {
        guard let partnerDisplayName = partnerDisplayName.urlEncoded(),
              let description = description.urlEncoded() else {
            print("Cannot encode partnerDisplayName and/or description")
            return
        }
        let urlString = "https://www.plnet9.com/spend?partnerName=\(partnerName)&totalPower=\(totalPower)&partnerDisplayName=\(partnerDisplayName)&description=\(description)&gatewayurl=\(gatewayURL)&handoff=true"
        if let link = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(link) {
                 UIApplication.shared.open(link)
            } else {
                /*if let appStoreLink = URL(string: "https://apps.apple.com/us/app/planet-nine/id1445951763") {
                    UIApplication.shared.open(appStoreLink)
                }*/
                cantOpen?()
            }
        } else {
            print("Could not construct URL string")
            cantOpen?()
        }
    }
    
    class func submitPowerUsage(totalPower: Int, partnerName: String, userUUID: String, ordinal: Int, timestamp: String, signature: String, partnerDisplayName: String, description: String, callback: @escaping (Error?, Data?) -> Void) {
        let powerUsage = PowerUsage(totalPower: totalPower, partnerName: partnerName, userUUID: userUUID, ordinal: ordinal, signature: signature, partnerDisplayName: partnerDisplayName, description: description, timestamp: timestamp)
        Network().usePowerAtOneTimeGateway(powerUsageObject: powerUsage, callback: callback)
    }
}
