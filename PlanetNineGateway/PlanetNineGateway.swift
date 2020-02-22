//
//  PlanetNineGateway.swift
//  PlanetNineGateway
//
//  Created by Zach Babb on 2/19/19.
//  Copyright © 2019 Planet Nine. All rights reserved.
//

import Foundation
import Braintree
import BraintreeDropIn

public class PlanetNineGateway {
    
    var oneTime: OneTimeGateway?
    var bleOneTime: BLEGateway?
    var ongoing: OngoingGateway?
    let network = Network()
    
    public init() {
        
    }
    
    public func oneTimeGateway(totalPower: Int, partnerName: String, gatewayName: String, gatewayURL: String, partnerDisplayName: String, description: String) {
        oneTime = OneTimeGateway(totalPower: totalPower, partnerName: partnerName, gatewayName: gatewayName, gatewayURL: gatewayURL, partnerDisplayName: partnerDisplayName, description: description)
    }
    
    public func askForPowerUsage() {
        guard let gateway = oneTime else {
            print("Must initialize oneTimeGateway before asking for power usage")
            return
        }
        gateway.askForPowerUsage()
    }
    
    public func submitPowerUsage(userUUID: String, signature: String, timestamp: String, callback: @escaping (Error?, Data?) -> Void) {
        guard let gateway = oneTime else {
            print("Must initialize oneTimeGateway before submitting power usage")
            return
        }
        gateway.submitPowerUsage(userUUID: userUUID, signature: signature, timestamp: timestamp, callback: callback)
    }
    
    public func oneTimeBLEUserGateway(gatewayName: String, gatewayURL: String, callback: @escaping (Error?, Data?) -> Void) {
        bleOneTime = OneTimeBLEUserGateway(gatewayName: gatewayName, gatewayURL: gatewayURL, callback: callback)
    }
    
    public func oneTimeBLEGateway(totalPower: Int, partnerName: String, gatewayName: String, gatewayURL: String, partnerDisplayName: String, description: String, callback: @escaping (Error?, Data?) -> Void) {
        bleOneTime = OneTimeBLEGateway(totalPower: totalPower, partnerName: partnerName, gatewayName: gatewayName, gatewayURL: gatewayURL, partnerDisplayName: partnerDisplayName, description: description, networkCallback: callback)
    }
    
    public func broadcastBLEGateway() {
        guard let gateway = bleOneTime else {
            print("Must initialize oneTimeBLEGateway before broadcasting")
            return
        }
        gateway.createTwoWayPeripheral()
    }
    
    public func ongoingGateway(gatewayName: String, publicKey: String, gatewayURL: String, timestamp: String, signature: String) {
        ongoing = OngoingGateway(gatewayName: gatewayName, publicKey: publicKey, gatewayURL: gatewayURL, timestamp: timestamp, signature: signature)
    }
    
    public func askForOngoingGatewayUsage() {
        guard let gateway = ongoing else {
            print("Must initialize ongoingGateway before asking for usage")
            return
        }
        gateway.askForOngoingGatewayUsage()
    }
    
    public func getUserUUIDForUsername(username: String, callback: @escaping (Error?, Data?) -> Void) {
        Network().getUserUUIDForUsername(username: username, callback: callback)
    }
    
    public func requestTransfer(gatewayName: String, transferRequest: TransferRequest, signature: String, callback: @escaping (Error?, Data?) -> Void) {
        let transferRequestWithSignature = TransferModel().addSignatureToTransferRequest(transferRequest: transferRequest, signature: signature)
        Network().requestTransfer(transferRequestWithSignature: transferRequestWithSignature, gatewayName: gatewayName, callback: callback)
    }
    
    internal class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
    public func checkoutWithBraintree(presentingViewController: UIViewController, userUUID: String, gatewayName: String, signature: String, timestamp: String) {
        
        let userGatewayTimestampTripleWithSignature = UserGatewayTimestampTripleWithSignature(userUUID: userUUID, gatewayName: gatewayName, timestamp: timestamp, signature: signature)
        
        Network().clientToken(userGatewayTimestampTripleWithSignature: userGatewayTimestampTripleWithSignature) { error, data in
            if let error = error {
                print("Error!!! \(error.localizedDescription)")
                return
            }
            guard let data = data,
                  let clientToken = String(data: data, encoding: .utf8)
            else { return }
            
            DispatchQueue.main.async {
                let request =  BTDropInRequest()
                let dropIn = BTDropInController(authorization: clientToken, request: request)
                { (controller, result, error) in
                    if (error != nil) {
                        print("ERROR")
                    } else if (result?.isCancelled == true) {
                        print("CANCELLED")
                    } else if let result = result {
                        // Use the BTDropInResult properties to update your UI
                        // result.paymentOptionType
                        // result.paymentMethod
                        // result.paymentIcon
                        // result.paymentDescription
                    }
                    controller.dismiss(animated: true, completion: nil)
                }
                presentingViewController.present(dropIn!, animated: true, completion: nil)
            }
        }
        
        
    }
}
