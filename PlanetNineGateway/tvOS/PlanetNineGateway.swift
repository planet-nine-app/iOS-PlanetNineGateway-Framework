//
//  PlanetNineGateway.swift
//  Pods
//
//  Created by Zach Babb on 6/28/20.
//

import Foundation

public class PlanetNineGateway {
    
    var mpcAdvertiser: MPCAdvertiser?
    
    public init() {
        
    }
    
    public func startAdvertising(peerID: String) {
        mpcAdvertiser = MPCAdvertiser(peerID: peerID)
    }
}
