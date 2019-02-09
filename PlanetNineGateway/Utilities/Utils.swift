//
//  Utils.swift
//  PlanetNineGateway
//
//  Created by Zach Babb on 1/31/19.
//  Copyright © 2019 Planet Nine. All rights reserved.
//

import Foundation

class Utils {
    func encodableToJSONData<T: Encodable>(_ object: T) -> Data {
        var jsonData = Data()
        let encoder = JSONEncoder()
        do {
            jsonData = try encoder.encode(object)
        } catch {
            print(error)
        }
        return jsonData
    }
}

extension String {
    func urlEncoded() -> String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
}
