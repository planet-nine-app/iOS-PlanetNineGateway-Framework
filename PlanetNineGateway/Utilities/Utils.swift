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
    
    func getTime() -> String {
        let currentDate = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let date = dateFormatter.date(from: dateFormatter.string(from: currentDate as Date))
        let nowDouble = date!.timeIntervalSince1970
        print("TIME:")
        print(nowDouble)
        print("EMIT")
        return String(Int(nowDouble * 1000.0))
    }
}
