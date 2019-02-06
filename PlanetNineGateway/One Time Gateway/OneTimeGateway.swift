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
    let userId: Int
    let signature: String
    let partnerDisplayName: String
    let description: String
}

public class OneTimeGateway {
    
    var gateway: Gateway
    let partnerDisplayName: String
    let description: String
    
    public init(totalPower: Int, partnerName: String, gatewayName: String, gatewayURL: String, partnerDisplayName: String, description: String) {
        gateway = Gateway(totalPower: totalPower, partnerName: partnerName, gatewayName: gatewayName, gatewayURL: gatewayURL)
        self.partnerDisplayName = partnerDisplayName
        self.description = description
    }
    
    public func askForPowerUsage() {
        print("asking for power usage")
        let urlString = "planetnine://gateway/details?gatewayname=\(gateway.gatewayName)&partnerName=\(gateway.partnerName)&gatewayurl=\(gateway.gatewayURL)&totalPower=\(gateway.totalPower)"
        if let link = URL(string: urlString) {
            UIApplication.shared.open(link)
        }
    }
    
    public func submitPowerUsage(userId: Int, signature: String, callback: @escaping (Error?, Data?) -> Void) {
        let powerUsage = PowerUsage(totalPower: gateway.totalPower, partnerName: gateway.partnerName, gatewayName: gateway.gatewayName, userId: userId, signature: signature, partnerDisplayName: self.partnerDisplayName, description: self.description)
        Network().usePowerAtOneTimeGateway(powerUsageObject: powerUsage, callback: callback)
    }
}
