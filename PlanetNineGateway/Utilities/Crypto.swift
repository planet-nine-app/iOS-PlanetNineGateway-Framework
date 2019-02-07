//
//  Crypto.swift
//  Planet Nine
//
//  Created by Zach Babb on 11/8/18.
//  Copyright © 2018 Planet Nine. All rights reserved.
//

import Foundation
import JavaScriptCore

struct Keys: Codable {
    var privateKey = ""
    var publicKey = ""
}

class Crypto {
    
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
    
    func signMessage(message: String) -> String {
        
        print(message)
        
        let privateKey = Crypto().getKeys()?.privateKey
        
        let context = getJSContext()
        
        let window = context?.objectForKeyedSubscript("window")
        let signMessage = window?.objectForKeyedSubscript("signMessage")
        let signature = signMessage?.call(withArguments: [message, privateKey!])!.toString()
        
        return signature!
    }
    
    func generateKeys(seed: String) -> Keys {
        
        let context = getJSContext()
        
        let window = context?.objectForKeyedSubscript("window")
        let keyGenerator = window?.objectForKeyedSubscript("keyGenerator")
        let generateKeysFunction = keyGenerator?.objectForKeyedSubscript("generateKeys")
        let result = generateKeysFunction?.call(withArguments: [seed])
        let newKeys = Keys(privateKey: ((result?.objectForKeyedSubscript("private")!.toString())!), publicKey: (result?.objectForKeyedSubscript("public")!.toString())!)
        
        Utils().saveEncodableToDefaults(newKeys, key: "keys")
        
        return newKeys
    }
    
    func getKeys() -> Keys? {
        let defaults = UserDefaults.standard
        guard let jsonString = defaults.string(forKey: "keys") else { return nil }
        let jsonData = jsonString.data(using: String.Encoding.utf8)
        var decodedKeys = Keys()
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData!, options: .allowFragments)
            decodedKeys = try JSONDecoder().decode(Keys.self, from: jsonData!)
        } catch {
            print("Error getting keys")
            print(error)
        }
        return decodedKeys
    }
}
