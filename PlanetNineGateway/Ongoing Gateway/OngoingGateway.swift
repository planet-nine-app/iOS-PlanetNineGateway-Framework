//
//  OngoingGateway.swift
//  PlanetNineGateway
//
//  Created by Zach Babb on 2/9/19.
//  Copyright © 2019 Planet Nine. All rights reserved.
//

import Foundation

class OngoingGateway {
    
    let gatewayKeyWithSignature: GatewayKeyWithSignature
    let gatewayURL: String
    
    init(gatewayName: String, publicKey: String, gatewayURL: String, timestamp: String, signature: String) {
        gatewayKeyWithSignature = GatewayKeyWithSignature(gatewayName: gatewayName, publicKey: publicKey, timestamp: timestamp, signature: signature)
        self.gatewayURL = gatewayURL
    }
    
    func askForOngoingGatewayUsage() {
        print("Asking for ongoing Gateway usage")
        guard let urlEncodedGatewayName = gatewayKeyWithSignature.gatewayName.urlEncoded() else {
            print("Gateway names must be url encodable")
            return
        }
        let urlString = "planetnine://ongoing/details?gatewayname=\(urlEncodedGatewayName)&publicKey=\(gatewayKeyWithSignature.publicKey)&gatewayURL=\(gatewayURL)&signature=\(gatewayKeyWithSignature.signature)&timestamp=\(gatewayKeyWithSignature.timestamp)"
        print(urlString)
        if let link = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(link) {
                UIApplication.shared.open(link)
            } else {
                //TODO: Add link to app store
                print("Could not open Planet Nine app here is where you would put link to app store")
            }
        }
    }
    
}
