//
//  Crypto.swift
//  Planet Nine
//
//  Created by Zach Babb on 11/8/18.
//  Copyright © 2018 Planet Nine. All rights reserved.
//

import Foundation
import JavaScriptCore
import Security
import Valet

struct Keys: Codable {
    var privateKey = ""
    var publicKey = ""
}

class Crypto {
    
    let publicKeyKey = "publicKey"
    let privateKeyKey = "privateKey"
    
    func getJSContext() -> JSContext? {
        var jsSourceContents: String = ""
        if let jsSourcePath = Bundle.main.path(forResource: "crypto", ofType: "js") {
            do {
                jsSourceContents = try String(contentsOfFile: jsSourcePath)
            } catch {
                print(error.localizedDescription)
            }
        }
        let context = JSContext()
        context?.evaluateScript(jsSourceContents)
        
        return context
    }
    
    func signMessage(message: String) -> String? {
        
        print(message)
        
        let privateKey = Crypto().getKeys()?.privateKey
        
        let context = getJSContext()
        
        let window = context?.objectForKeyedSubscript("window")
        let signMessage = window?.objectForKeyedSubscript("signMessage")
        let signature = signMessage?.call(withArguments: [message, privateKey!])!.toString()
        
        return signature
    }
    
    func signMessageWithTempKey(message: String, tempKey: String) -> String {
        
        let context = getJSContext()
        
        let window = context?.objectForKeyedSubscript("window")
        let signMessage = window?.objectForKeyedSubscript("signMessage")
        let signature = signMessage?.call(withArguments: [message, tempKey])!.toString()
        
        return signature!
    }
    
    func generateKeys(seed: String) -> Keys {
        
        let context = getJSContext()
        
        let window = context?.objectForKeyedSubscript("window")
        let keyGenerator = window?.objectForKeyedSubscript("keyGenerator")
        let generateKeysFunction = keyGenerator?.objectForKeyedSubscript("generateKeys")
        let result = generateKeysFunction?.call(withArguments: [seed])
        let newKeys = Keys(privateKey: ((result?.objectForKeyedSubscript("private")!.toString())!), publicKey: (result?.objectForKeyedSubscript("public")!.toString())!)
        
        //Utils().saveEncodableToDefaults(newKeys, key: "keys")

        /*let keychainItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: newKeys.publicKey)
        do {
            try keychainItem.saveKeys(keys: newKeys)
        } catch {
            print("ERROR ERROR")
            print(error.localizedDescription)
        }*/
        
        let valet = Valet.valet(with: Identifier(nonEmpty: "Planet-Nine-dev")!, accessibility: .whenUnlocked)
        valet.set(string: newKeys.publicKey, forKey: publicKeyKey)
        valet.set(string: newKeys.privateKey, forKey: privateKeyKey)
        
        
        return newKeys
    }
    
    func tempKeys(seed: String) -> Keys {
        let context = getJSContext()
        
        let window = context?.objectForKeyedSubscript("window")
        let keyGenerator = window?.objectForKeyedSubscript("keyGenerator")
        let generateKeysFunction = keyGenerator?.objectForKeyedSubscript("generateKeys")
        let result = generateKeysFunction?.call(withArguments: [seed])
        let newKeys = Keys(privateKey: ((result?.objectForKeyedSubscript("private")!.toString())!), publicKey: (result?.objectForKeyedSubscript("public")!.toString())!)
        
        //Utils().saveEncodableToDefaults(newKeys, key: "tempKeys")
        
        let valet = Valet.valet(with: Identifier(nonEmpty: "Planet-Nine-dev")!, accessibility: .whenUnlocked)
        valet.set(string: newKeys.publicKey, forKey: "tempPublicKey")
        valet.set(string: newKeys.privateKey, forKey: "tempPrivateKey")
        
        return newKeys
    }
    
    func getTempKeys() -> Keys? {
        /*let defaults = UserDefaults.standard
        guard let jsonString = defaults.string(forKey: "tempKeys") else { return nil }
        let jsonData = jsonString.data(using: String.Encoding.utf8)
        var decodedKeys = Keys()
        do {
            decodedKeys = try JSONDecoder().decode(Keys.self, from: jsonData!)
        } catch {
            print("Error getting keys")
            print(error)
        }*/
        
        let valet = Valet.valet(with: Identifier(nonEmpty: "Planet-Nine-dev")!, accessibility: .whenUnlocked)
        let publicKey = valet.string(forKey: "tempPublicKey")
        let privateKey = valet.string(forKey: "tempPrivateKey")
        
        if publicKey == nil {
            //valet.set(string: decodedKeys.publicKey, forKey: "tempPublicKey")
            //valet.set(string: decodedKeys.privateKey, forKey: "tempPrivateKey")
            return nil
        }
        
        let decodedKeys = Keys(privateKey: privateKey!, publicKey: publicKey!)
        
        return decodedKeys
    }
    
    func commitKeys(newKeys: Keys) {
        //Utils().saveEncodableToDefaults(newKeys, key: "keys")
        
        let valet = Valet.valet(with: Identifier(nonEmpty: "Planet-Nine-dev")!, accessibility: .whenUnlocked)
        valet.set(string: newKeys.publicKey, forKey: publicKeyKey)
        valet.set(string: newKeys.privateKey, forKey: privateKeyKey)
    }
    
    func getKeys() -> Keys? {
        /*let defaults = UserDefaults.standard
        guard let jsonString = defaults.string(forKey: "keys") else { return nil }
        let jsonData = jsonString.data(using: String.Encoding.utf8)
        var decodedKeys = Keys()
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData!, options: .allowFragments)
            decodedKeys = try JSONDecoder().decode(Keys.self, from: jsonData!)
        } catch {
            print("Error getting keys")
            print(error)
        }*/
        
        /*let keychainItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: decodedKeys.publicKey)
        
        do {
            
            let keys = try keychainItem.readKeys()
            
            print("keychain keys: \(keys)")
        } catch {
            print("ERROR ERROR ERROR")
            print(error.localizedDescription)
        }*/
        
        let valet = Valet.valet(with: Identifier(nonEmpty: "Planet-Nine-dev")!, accessibility: .whenUnlocked)
        let publicKey = valet.string(forKey: publicKeyKey)
        let privateKey = valet.string(forKey: privateKeyKey)
        
        print("Your public key is: \(publicKey)")
        
        if publicKey == nil {
            //valet.set(string: decodedKeys.publicKey, forKey: publicKeyKey)
            //valet.set(string: decodedKeys.privateKey, forKey: privateKeyKey)
            return nil
        }
        
        let decodedKeys = Keys(privateKey: privateKey!, publicKey: publicKey!)
        
        return decodedKeys
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
}
