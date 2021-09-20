//
//  Network.swift
//  Ongoing-Gateway-Tester
//
//  Created by Zach Babb on 1/21/19.
//  Copyright © 2019 Planet Nine. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

public enum NetworkErrors: Error {
    case couldNotReachNetwork
    case pageNotFound
    case authenticationError
    case noData
    case unknownError
}

struct GetUserByUUID: Codable {
    var userUUID: String
    var timestamp: String
    func toString() -> String {
        return "{\"userUUID\":\(userUUID),\"timestamp\":\"\(timestamp)\"}"
    }
}

class Network: NSObject {
    let baseURL = "https://api.plnet9.com"
    
    func connectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    func put(body: Data, path: String, callback: @escaping (Error?, Data?) -> Void) {
        if !connectedToNetwork() {
            callback(NetworkErrors.couldNotReachNetwork, nil)
            return
        }
        let url = URL(string: "\(baseURL)\(path)")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        request.httpBody = body
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (data, response, error) in
            let httpResponse = response as! HTTPURLResponse
            if httpResponse.statusCode != 200 {
                if httpResponse.statusCode == 401 {
                    callback(NetworkErrors.authenticationError, data)
                    return
                }
                if httpResponse.statusCode == 404 {
                    callback(NetworkErrors.pageNotFound, data)
                    return
                }
                print("Received error with statusCode \(httpResponse.statusCode)")
                print(httpResponse)
                callback(NetworkErrors.couldNotReachNetwork, data)
                return
            }
            guard let data = data else {
                
                callback(NetworkErrors.noData, nil)
                return
                
            }
            callback(nil, data)
        }
        task.resume()
    }
    
    func get(path: String, callback: @escaping (Error?, Data?) -> Void) {
        if !connectedToNetwork() {
            callback(NetworkErrors.couldNotReachNetwork, nil)
            return
        }
        let url = URL(string: "\(baseURL)\(path)")!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            let httpResponse = response as! HTTPURLResponse
            print(httpResponse.statusCode)
            if httpResponse.statusCode != 200 {
                if httpResponse.statusCode == 401 {
                    callback(NetworkErrors.authenticationError, data)
                    return
                }
                if httpResponse.statusCode == 404 {
                    callback(NetworkErrors.pageNotFound, data)
                    return
                }
                callback(NetworkErrors.couldNotReachNetwork, data)
                return
            }
            if error != nil {
                callback(NetworkErrors.couldNotReachNetwork, data)
            }
            guard let data = data else { return }
            callback(nil, data)
        }
        task.resume()
    }
    
    func getUserByUUID(userUUID: String, gatewayName: String, timestamp: String, signature: String, callback: @escaping (Error?, Data?) -> Void) {
        let path = "/gateway/\(gatewayName)/userUUID/\(userUUID)/signature/\(signature)/timestamp/\(timestamp)"
        
        get(path: path, callback: callback)
    }
    
    func usePowerAtOneTimeGateway(powerUsageObject: PowerUsage, callback: @escaping (Error?, Data?) -> Void) {
//        let path = "/user/userUUID/\(powerUsageObject.userUUID)/power/gateway/\(powerUsageObject.gatewayName)"
        let path = "/gateway/\(powerUsageObject.gatewayName)/power"
        let jsonData = Utils().encodableToJSONData(powerUsageObject)
        put(body: jsonData, path: path, callback: callback)
    }
    
    func usePowerAtOngoingGateway(usePowerAtOngoingGatewayWithSignature: UsePowerAtOngoingGatewayWithSignature, callback: @escaping (Error?, Data?) -> Void) {
        let path = "/gateway/\(usePowerAtOngoingGatewayWithSignature.gatewayName)/ongoing/power"
        let jsonData = Utils().encodableToJSONData(usePowerAtOngoingGatewayWithSignature)
        put(body: jsonData, path: path, callback: callback)
    }
    
    func getUserUUIDForUsername(username: String, callback: @escaping (Error?, Data?) -> Void) {
        let path = "/user/name/\(username)/userUUID"
        get(path: path, callback: callback)
    }
    
    func requestTransfer(transferRequestWithSignature: TransferRequestWithSignature, gatewayName: String, callback: @escaping (Error?, Data?) -> Void) {
//        let path = "/user/userUUID/\(transferRequestWithSignature.userUUID)/gateway/\(gatewayName)/transfer/request"
        let path = "/transfer/gateway/request"
        let jsonData = Utils().encodableToJSONData(transferRequestWithSignature)
        put(body: jsonData, path: path, callback: callback)
    }
    
    func clientToken(userGatewayTimestampTripleWithSignature: UserGatewayTimestampTripleWithSignature, callback: @escaping (Error?, Data?) -> Void) {
        let path = "/demo/braintree/userUUID/\(userGatewayTimestampTripleWithSignature.userUUID)/gatewayName/\(userGatewayTimestampTripleWithSignature.gatewayName)/client-token/signature/\(userGatewayTimestampTripleWithSignature.signature)/timestamp/\(userGatewayTimestampTripleWithSignature.timestamp)"
        get(path: path, callback: callback)
    }
    
    func signinWithApple(gatewayKey: AppleSignInGatewayKeyWithSignature, callback: @escaping (Error?, PNUser?) -> Void) {
        let path = "/applesso/signin"
        let jsonData = Utils().encodableToJSONData(gatewayKey)
        put(body: jsonData, path: path) { error, resp in
            if error != nil {
                callback(error, nil)
            }
            guard let jsonData = resp,
                  let user = UserModel().getUserFromJSONData(userData: jsonData)
            else { return }
            
            let pnUser = PlanetNineUser.getPNUserForUser(currentUser: user)
            callback(nil, pnUser)
        }
    }
    
    func mintNineum(mintNineumRequestWithSignature: MintNineumRequestWithSignature, callback: @escaping (Error?, [String]?) -> Void) {
        let path = "/partner/nineum/mint"
        let jsonData = Utils().encodableToJSONData(mintNineumRequestWithSignature)
        put(body: jsonData, path: path) { error, resp in
            if error != nil {
                callback(error, nil)
            }
            guard let jsonData = resp,
                  let nineum = NineumModel().getNineumFromJSONData(jsonData: jsonData)
            else { return }
            
            callback(nil, nineum)
        }
    }
    
    func approveTransfer(approveTransferWithSignature: ApproveTransferWithSignature, callback: @escaping (Error?, Data?) -> Void) {
        ///user/userId/:userId/transfer/nineumTransactionId/:nineumTransactionId/approve'
//        let path = "/user/userId/\(approveTransferWithSignature.userId)/transfer/nineumTransactionId/\(approveTransferWithSignature.nineumTransactionId)/approve"
        let path = "/transfer/approve"
        let jsonData = Utils().encodableToJSONData(approveTransferWithSignature)
        put(body: jsonData, path: path, callback: callback)
    }
}
