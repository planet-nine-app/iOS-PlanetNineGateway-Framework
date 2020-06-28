//
//  Crypto.swift
//  Planet Nine
//
//  Created by Zach Babb on 11/8/18.
//  Copyright © 2018 Planet Nine. All rights reserved.
//

import Foundation
import secp256k1
import CryptoSwift
import Security
import Valet

struct Keys: Codable {
    var privateKey = ""
    var publicKey = ""
}

class Crypto {
    
    let publicKeyKey = "publicKey"
    let privateKeyKey = "privateKey"
    
    func signMessage(message: String) -> String? {
        
        if let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN)) {
            let msgArray: [UInt8] = Array(message.utf8)
            var msgSHA = SHA3.init(variant: .sha256)
            var msg32: [UInt8]
            do {
              msg32 = try msgSHA.finish(withBytes: msgArray)
            } catch {
                print(error)
                return nil
            }
            
            guard let privKeyTxt = getKeys()?.privateKey else { return nil }
            let privKey: [CUnsignedChar] = Array(hex: privKeyTxt)
            
            var sig = secp256k1_ecdsa_signature()
            let sigRes = secp256k1_ecdsa_sign(ctx, &sig, msg32, privKey, nil, nil)
            
            var normalizedSig = secp256k1_ecdsa_signature()
            secp256k1_ecdsa_signature_normalize(ctx, &normalizedSig, &sig)
            //var serialized = [UInt8].init(reserveCapacity: 64)
            var serialized = Data(count: 64)
            guard serialized.withUnsafeMutableBytes({secp256k1_ecdsa_signature_serialize_compact(ctx, $0, &sig) }) == 1 else { return nil }
            serialized.count = 64
            print(serialized.count)
            print("serialized \(serialized.toHexString())")
            
            var length: size_t = 128
            //var der = [UInt8].init(reserveCapacity: length)
            var der = Data(count: length)
            guard der.withUnsafeMutableBytes({ secp256k1_ecdsa_signature_serialize_der(ctx, $0, &length, &sig) }) == 1 else { return nil }
            
            der.count = length
            print(der.count)
            print(der.toHexString())
            
            if sigRes == 0 {
                print("Could not make signature")
                return nil
            } else {
                let signature = stringForSignature(collection: sig.data)
                return signature
            }
        }
        return nil
    }
    
    func stringForSignature<T>(collection: T) -> String {
        var signature = ""
        let mirror = Mirror(reflecting: collection)
        let tupleElements = mirror.children.map({ $0.value })
        tupleElements.forEach { element in
            signature = signature + String(format: "%02x", element as! UInt8)
        }
        
        return signature
    }
    
    func generateSeedPhrase() -> String {
        let words = WordBank().words
        
        func generateName() -> String {
            let randomIndex1 = Int(arc4random_uniform(UInt32(words.count)))
            let randomIndex2 = Int(arc4random_uniform(UInt32(words.count)))
            let randomIndex3 = Int(arc4random_uniform(UInt32(words.count)))
            let first = words[randomIndex1]
            let second = words[randomIndex2]
            let third = words[randomIndex3]
            
            return "\(first)-\(second)-\(third)"
        }
        
        let nameSeed = generateName() + generateName() + generateName() + generateName()
        let deviceSeed = "\(UIDevice.current.name)-\(UIDevice.current.model)-\(UIDevice.current.batteryLevel)-\(UIDevice.current.systemVersion)"
        let timeSeed = "".getTime()
        let randomSeed = Int.random(in: 0...1000000000000)
        let newSeed = "\(nameSeed)-\(deviceSeed)-\(timeSeed)-\(randomSeed)"
        
        return newSeed
    }
    
    func generateKeys(seedPhrase: String) -> Bool {
        
        var msgArray: [UInt8] = Array(seedPhrase.utf8)
        
        //var msg32: [UInt8]
        for _ in 0..<32 {
            var msgSHA = SHA3.init(variant: .sha256)
            do {
              msgArray = try msgSHA.finish(withBytes: msgArray)
            } catch {
                print(error)
                return false
            }
        }
        
        
        if let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN)) {
            var publicKey = secp256k1_pubkey()
            let pubKeyRes = secp256k1_ec_pubkey_create(ctx, &publicKey, &msgArray)
            
            var length: size_t = 33
            //var der = [UInt8].init(reserveCapacity: length)
            var serialized = Data(count: length)
            guard serialized.withUnsafeMutableBytes({ secp256k1_ec_pubkey_serialize(ctx, $0, &length, &publicKey,  UInt32(SECP256K1_EC_COMPRESSED)) }) == 1 else { return false }
            
            let valet = Valet.valet(with: Identifier(nonEmpty: "Planet-Nine-dev")!, accessibility: .whenUnlocked)
            valet.set(string: serialized.toHexString(), forKey: publicKeyKey)
            valet.set(string: msgArray.toHexString(), forKey: privateKeyKey)
            
            return true
        }
        return false
    }
    
    func getKeys() -> Keys? {
        
        let valet = Valet.valet(with: Identifier(nonEmpty: "Planet-Nine-dev")!, accessibility: .whenUnlocked)
        let publicKey = valet.string(forKey: publicKeyKey)
        let privateKey = valet.string(forKey: privateKeyKey)
        
        if publicKey == nil {
            return nil
        }
        
        let decodedKeys = Keys(privateKey: privateKey!, publicKey: publicKey!)
        
        return decodedKeys
    }
}
