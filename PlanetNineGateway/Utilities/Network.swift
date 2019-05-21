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

struct GetUserById: Codable {
    var userId: Int
    var timestamp: String
    func toString() -> String {
        return "{\"userId\":\(userId),\"timestamp\":\"\(timestamp)\"}"
    }
}

class Network: NSObject {
    let baseURL = "https://www.plnet9.com"
    
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
    
    func getUserById(userId: Int, gatewayName: String, timestamp: String, signature: String, callback: @escaping (Error?, Data?) -> Void) {
        let path = "/user/userId/\(userId)/gateway/\(gatewayName)/signature/\(signature)/timestamp/\(timestamp)"
        get(path: path, callback: callback)
    }
    
    func usePowerAtOneTimeGateway(powerUsageObject: PowerUsage, callback: @escaping (Error?, Data?) -> Void) {
        let path = "/user/userId/\(powerUsageObject.userId)/power/gateway/\(powerUsageObject.gatewayName)/timestamp/\(powerUsageObject.timestamp)"
        let jsonData = Utils().encodableToJSONData(powerUsageObject)
        put(body: jsonData, path: path, callback: callback)
    }
    
    func usePowerAtOngoingGateway(usePowerAtOngoingGatewayWithSignature: UsePowerAtOngoingGatewayWithSignature, callback: @escaping (Error?, Data?) -> Void) {
        let path = "/user/userId/\(usePowerAtOngoingGatewayWithSignature.userId)/power/gateway/\(usePowerAtOngoingGatewayWithSignature.gatewayName)/ongoing"
        let jsonData = Utils().encodableToJSONData(usePowerAtOngoingGatewayWithSignature)
        put(body: jsonData, path: path, callback: callback)
    }
}
