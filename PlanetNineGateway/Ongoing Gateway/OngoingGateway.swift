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

class OngoingGateway: NSObject {
    
    var gatewayKeyWithSignature: GatewayKeyWithSignature
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
        print(gatewayKeyWithSignature)
        let urlString = "planetnine://ongoing/details?gatewayname=\(urlEncodedGatewayName)&publicKey=\(gatewayKeyWithSignature.publicKey)&gatewayURL=\(gatewayURL)&signature=\(gatewayKeyWithSignature.signature)&timestamp=\(gatewayKeyWithSignature.timestamp)"
        print(urlString)
        if let link = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(link) {
                UIApplication.shared.open(link)
            } else {
                guard let topViewController = PlanetNineGateway.topViewController() else { return }
                let button = ASAuthorizationAppleIDButton()
                button.addTarget(self, action: #selector(handleAuthorization), for: .touchUpInside)
                topViewController.view.addSubview(button)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.centerXAnchor.constraint(equalTo: topViewController.view.centerXAnchor).isActive = true
                button.centerYAnchor.constraint(equalTo: topViewController.view.centerYAnchor).isActive = true
            }
        }
    }
    
    @objc func handleAuthorization() {
        let requestID = ASAuthorizationAppleIDProvider().createRequest()
        // here request user name and email
        requestID.requestedScopes = [.email]
                
        let controller = ASAuthorizationController(authorizationRequests: [requestID])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

extension OngoingGateway: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        print("There are \(UIApplication.shared.windows.count)")
        return UIApplication.shared.windows[0]
    }
    
    
}

extension OngoingGateway: ASAuthorizationControllerDelegate
{
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // error
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization)
    {
        // success
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential
        {
            // after get user credential, you can check with your stored data for verification.
            //let detailVC = DetailVC(cred: credential)
            //self.present(detailVC, animated: true, completion: nil)
            print("credential: \(credential)")
        }
    }
}
