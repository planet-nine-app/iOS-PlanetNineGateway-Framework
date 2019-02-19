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
    
    init(gatewayName: String, publicKey: String, gatewayURL: String, signature: String) {
        gatewayKeyWithSignature = GatewayKeyWithSignature(gatewayName: gatewayName, publicKey: publicKey, signature: signature)
        self.gatewayURL = gatewayURL
    }
    
    func askForOngoingGatewayUsage() {
        print("Asking for ongoing Gateway usage")
        guard let urlEncodedGatewayName = gatewayKeyWithSignature.gatewayName.urlEncoded() else {
            print("Gateway names must be url encodable")
            return
        }
        let urlString = "planetnine://ongoing/details?gatewayname=\(urlEncodedGatewayName)&publicKey=\(gatewayKeyWithSignature.publicKey)&gatewayURL=\(gatewayURL)&signature=\(gatewayKeyWithSignature.signature)"
        if let link = URL(string: urlString) {
            UIApplication.shared.open(link)
        }
    }
    
}
