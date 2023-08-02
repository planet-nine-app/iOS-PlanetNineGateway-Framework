//
//  OngoingGateway.swift
//  PlanetNineGateway
//
//  Created by Zach Babb on 2/9/19.
//  Copyright © 2019 Planet Nine. All rights reserved.
//

import Foundation
import UIKit
import AuthenticationServices

class OngoingGateway {
    
    class func askForOngoingGatewayUsage(gatewayAccessToken: String, publicKey: String, returnURL: String) {
        let gatewayKey = GatewayKey(gatewayAccessToken: gatewayAccessToken, publicKey: publicKey)
        let gatewayKeyWithSignature = GatewayKeyWithSignature(gatewayAccessToken: gatewayAccessToken, publicKey: publicKey, timestamp: gatewayKey.timestamp, signature: Crypto().signMessage(message: gatewayKey.toString()) ?? "")
        let urlString = "https://www.plnet9.com/ongoing?gatewayAccessToken=\(gatewayAccessToken)&publicKey=\(publicKey)&gatewayurl=\(returnURL)&gatewaySignature=\(gatewayKeyWithSignature.signature)&timestamp=\(gatewayKeyWithSignature.timestamp)"
        print(urlString)
        if let link = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(link) {
                UIApplication.shared.open(link)
            } else {
                return
            }
        }
    }
    
    class func usePowerAtOngoingGateway(user: PNUser, totalPower: Int, partnerName: String, description: String, callback: @escaping (Error?, PNUser?) -> Void, gatewayAccessToken: String) {
        let usePowerAtOngoingGateway = UsePowerAtOngoingGateway(totalPower: totalPower, partnerName: partnerName, gatewayAccessToken: gatewayAccessToken, userUUID: user.userUUID, ordinal: (user.powerOrdinal + 1), description: description)
        let usePowerAtOngoingGatewayWithSignature = UsePowerAtOngoingGatewayWithSignature(totalPower: totalPower, partnerName: partnerName, gatewayAccessToken: gatewayAccessToken, userUUID: user.userUUID, ordinal: usePowerAtOngoingGateway.ordinal, description: description, timestamp: usePowerAtOngoingGateway.timestamp, signature: Crypto().signMessage(message: usePowerAtOngoingGateway.toString())!)
        
        Network().usePowerAtOngoingGateway(usePowerAtOngoingGatewayWithSignature: usePowerAtOngoingGatewayWithSignature) { error, data in
            if error != nil {
                callback(error, nil)
                return
            }
            if let data = data,
               let pnUser = UserModel.getUserFromJSONData(userData: data) {
                
                callback(nil, pnUser)
            } else {
                callback(NSError(domain: "", code: 404), nil)
            }
        }
    }
}

