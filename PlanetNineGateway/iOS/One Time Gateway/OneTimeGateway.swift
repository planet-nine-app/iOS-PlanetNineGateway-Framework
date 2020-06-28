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
    let gatewayName: String
    let userUUID: String
    let signature: String
    let partnerDisplayName: String
    let description: String
    let timestamp: String
}

class OneTimeGateway {
    
    var gateway: Gateway
    let partnerDisplayName: String
    let description: String
    
    init(totalPower: Int, partnerName: String, gatewayName: String, gatewayURL: String, partnerDisplayName: String, description: String) {
        gateway = Gateway(totalPower: totalPower, partnerName: partnerName, gatewayName: gatewayName, gatewayURL: gatewayURL, partnerDisplayName: partnerDisplayName, description: description)
        self.partnerDisplayName = partnerDisplayName
        self.description = description
    }
    
    func askForPowerUsage() {
        print("asking for power usage")
        guard let urlEncodedGatewayName = gateway.gatewayName.urlEncoded() else {
            print("Error: Gateway Name's must be url encodable")
            return
        }
        guard let urlEncodedPartnerDisplayName = partnerDisplayName.urlEncoded() else {
            print("Error: partnerDisplayName must be url encodable")
            return
        }
        guard let urlEncodedDescription = description.urlEncoded() else {
            print("Error: description must be url encodable")
            return
        }
        let urlString = "planetnine://gateway/details?gatewayname=\(urlEncodedGatewayName)&partnerName=\(gateway.partnerName)&gatewayurl=\(gateway.gatewayURL)&totalPower=\(gateway.totalPower)&partnerDisplayName=\(urlEncodedPartnerDisplayName)&description=\(urlEncodedDescription)"
        print("trying to open \(urlString)")
        if let link = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(link) {
                 UIApplication.shared.open(link)
            } else {
                //TODO: Add link to app store
                if let appStoreLink = URL(string: "https://apps.apple.com/us/app/planet-nine/id1445951763") {
                    UIApplication.shared.open(appStoreLink)
                }
                print("Could not open Planet Nine app here is where you would put link to app store")
            }
        } else {
            print("Could not open urlString")
        }
    }
    
    func submitPowerUsage(userUUID: String, signature: String, timestamp: String, callback: @escaping (Error?, Data?) -> Void) {
        let powerUsage = PowerUsage(totalPower: gateway.totalPower, partnerName: gateway.partnerName, gatewayName: gateway.gatewayName, userUUID: userUUID, signature: signature, partnerDisplayName: self.partnerDisplayName, description: self.description, timestamp: timestamp)
        Network().usePowerAtOneTimeGateway(powerUsageObject: powerUsage, callback: callback)
    }
}
