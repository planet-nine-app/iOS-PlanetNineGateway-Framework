//
//  OneTimeGateway.swift
//  PlanetNineGateway
//
//  Created by Zach Babb on 1/29/19.
//  Copyright © 2019 Planet Nine. All rights reserved.
//

import Foundation

struct Gateway: Codable {
    let totalPower: Int
    let partnerName: String
    let gatewayName: String
    let gatewayURL: String
}

struct PowerUsage: Codable {
    let totalPower: Int
    let partnerName: String
    let gatewayName: String
    let userId: Int
    let signature: String
    let description: String
}

public class OneTimeGateway {
    
    var gateway: Gateway
    
    public init(totalPower: Int, partnerName: String, gatewayName: String, gatewayURL: String) {
        gateway = Gateway(totalPower: totalPower, partnerName: partnerName, gatewayName: gatewayName, gatewayURL: gatewayURL)
    }
    
    public func askForPowerUsage() {
        print("asking for power usage")
        let urlString = "planetnine://gateway/details?gatewayname=\(gateway.gatewayName)&partnerName=\(gateway.partnerName)&gatewayurl=\(gateway.gatewayURL)&totalPower=\(gateway.totalPower)"
        if let link = URL(string: urlString) {
            UIApplication.shared.open(link)
        }
    }
    
    public func submitPowerUsage(userId: Int, signature: String, description: String, callback: @escaping (Error?, Data?) -> Void) {
        let powerUsage = PowerUsage(totalPower: gateway.totalPower, partnerName: gateway.partnerName, gatewayName: gateway.gatewayName, userId: userId, signature: signature, description: description)
        Network().usePowerAtOneTimeGateway(powerUsageObject: powerUsage, callback: callback)
    }
}
