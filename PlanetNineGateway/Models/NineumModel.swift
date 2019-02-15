//
//  NineumModel.swift
//  Planet Nine
//
//  Created by Zach Babb on 11/27/18.
//  Copyright © 2018 Planet Nine. All rights reserved.
//

import Foundation
import UIKit

public enum Universes: String {
    case theUniverse = "The Universe"
}

public enum Addresses: String {
    case planetNine = "Planet Nine"
}

public enum Charges: String {
    case positive = "Positive"
    case negative = "Negative"
}

public enum Directions: String {
    case north = "North"
    case south = "South"
    case east = "East"
    case west = "West"
    case up = "Up"
    case down = "Down"
}

public enum Rarities: String {
    case common = "Common"
    case nine = "Nine"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    case mythical = "Mythical"
}

public enum Sizes: String {
    case miniscule = "Miniscule"
    case tiny = "Tiny"
    case small = "Small"
    case medium = "Medium"
    case standard = "Standard"
    case big = "Big"
    case large = "Large"
    case huge = "Huge"
}

public enum Textures: String {
    case soft = "Soft"
    case bumpy = "Bumpy"
    case satin = "Satin"
    case rough = "Rough"
    case gritty = "Gritty"
    case metallic = "Metallic"
    case plush = "Plush"
    case woolen = "Woolen"
}

public enum Shapes: String {
    case sphere = "Sphere"
    case cylinder = "Cylinder"
    case tetrahedron = "Tetrahedron"
    case cube = "Cube"
    case octahedron = "Octahedron"
    case dodecahedron = "Dodecahedron"
    case cone = "Cone"
    case torus = "Torus"
}

public enum Years: String {
    case year1 = "Year One"
    case year2 = "Year Two"
    case year3 = "Year Three"
    case year4 = "Year Four"
    case year5 = "Year Five"
    case year6 = "Year Six"
    case year7 = "Year Seven"
    case year8 = "Year Eight"
}

public struct Nineum {
    public let universe: Universes
    public let address: Addresses
    public let charge: Charges
    public let direction: Directions
    public let rarity: Rarities
    public let size: Sizes
    public let texture: Textures
    public let shape: Shapes
    public let year: Years
    public let ordinal: Int
}

public class NineumModel {
    
    public init() {
        
    }
    
    public func getNineumArrayForNineumHexStrings(hexStrings: [String]) -> [Nineum] {
        var nineumArray = [Nineum]()
        for hexString in hexStrings {
            let nineum = getNineumFromHexString(hexString: hexString)
            nineumArray.append(nineum)
        }
        return nineumArray
    }
    
    public func getNineumFromHexString(hexString: String) -> Nineum {
        //print("Nineum \(hexString)")
        let universeStart = hexString.startIndex
        let universeEnd = hexString.index(hexString.startIndex, offsetBy: 2)
        let universeRange = universeStart..<universeEnd
        let universe = getUniverseFromHexString(hexString: String(hexString[universeRange]))
        
        let addressStart = universeEnd
        let addressEnd = hexString.index(universeEnd, offsetBy: 8)
        let addressRange = addressStart..<addressEnd
        let address = getAddressFromHexString(hexString: String(hexString[addressRange]))
        
        let chargeStart = addressEnd
        let chargeEnd = hexString.index(addressEnd, offsetBy: 2)
        let chargeRange = chargeStart..<chargeEnd
        let charge = getChargeFromHexString(hexString: String(hexString[chargeRange]))
        
        let directionStart = chargeEnd
        let directionEnd = hexString.index(chargeEnd, offsetBy: 2)
        let directionRange = directionStart..<directionEnd
        let direction = getDirectionFromHexString(hexString: String(hexString[directionRange]))
        
        let rarityStart = directionEnd
        let rarityEnd = hexString.index(directionEnd, offsetBy: 2)
        let rarityRange = rarityStart..<rarityEnd
        let rarity = getRarityFromHexString(hexString: String(hexString[rarityRange]))
        
        let sizeStart = rarityEnd
        let sizeEnd = hexString.index(rarityEnd, offsetBy: 2)
        let sizeRange = sizeStart..<sizeEnd
        let size = getSizeFromHexString(hexString: String(hexString[sizeRange]))
        
        let textureStart = sizeEnd
        let textureEnd = hexString.index(sizeEnd, offsetBy: 2)
        let textureRange = textureStart..<textureEnd
        let texture = getTextureFromHexString(hexString: String(hexString[textureRange]))
        
        let shapeStart = textureEnd
        let shapeEnd = hexString.index(textureEnd, offsetBy: 2)
        let shapeRange = shapeStart..<shapeEnd
        let shape = getShapeFromHexString(hexString: String(hexString[shapeRange]))
        
        let yearStart = shapeEnd
        let yearEnd = hexString.index(shapeEnd, offsetBy: 2)
        let yearRange = yearStart..<yearEnd
        let year = getYearFromHexString(hexString: String(hexString[yearRange]))
        
        let ordinalStart = yearEnd
        let ordinalEnd = hexString.index(yearEnd, offsetBy: 8)
        let ordinalRange = ordinalStart..<ordinalEnd
        let ordinal = getOrdinalFromHexString(hexString: String(hexString[ordinalRange]))
        
        let nineum = Nineum(universe: universe, address: address, charge: charge, direction: direction, rarity: rarity, size: size, texture: texture, shape: shape, year: year, ordinal: ordinal)
        
        return nineum
    }
    
    public func getUniverseFromHexString(hexString: String) -> Universes {
        //print("Universe \(hexString)")
        switch hexString {
        case "01":
            return .theUniverse
        default:
            return .theUniverse
        }
    }
    
    public func getAddressFromHexString(hexString: String) -> Addresses {
        //print("Address \(hexString)")
        switch hexString {
        case "00000001":
            return .planetNine
        default:
            return .planetNine
        }
    }
    
    public func getChargeFromHexString(hexString: String) -> Charges {
        //print("Charge \(hexString)")
        switch hexString {
        case "01":
            return .positive
        case "02":
            return .negative
        default:
            return .positive
        }
    }
    
    public func getDirectionFromHexString(hexString: String) -> Directions {
        //print("Direction \(hexString)")
        switch hexString {
        case "01":
            return .north
        case "02":
            return .south
        case "03":
            return .east
        case "04":
            return .west
        case "05":
            return .up
        case "06":
            return .down
        default:
            return .north
        }
    }
    
    public func getRarityFromHexString(hexString: String) -> Rarities {
        //print("Rarity \(hexString)")
        switch hexString {
        case "01":
            return .common
        case "02":
            return .uncommon
        case "03":
            return .rare
        case "04":
            return .epic
        case "05":
            return .legendary
        case "06":
            return .mythical
        case "09":
            return .nine
        default:
            return .common
        }
    }
    
    public func getSizeFromHexString(hexString: String) -> Sizes {
        //print("Size \(hexString)")
        switch hexString {
        case "01":
            return .miniscule
        case "02":
            return .tiny
        case "03":
            return .small
        case "04":
            return .medium
        case "05":
            return .standard
        case "06":
            return .big
        case "07":
            return .large
        case "08":
            return .huge
        default:
            return .miniscule
        }
    }
    
    public func getTextureFromHexString(hexString: String) -> Textures {
        //print("Texture \(hexString)")
        switch hexString {
        case "01":
            return .soft
        case "02":
            return .bumpy
        case "03":
            return .satin
        case "04":
            return .rough
        case "05":
            return .gritty
        case "06":
            return .metallic
        case "07":
            return .plush
        case "08":
            return .woolen
        default:
            return .soft
        }
    }
    
    public func getShapeFromHexString(hexString: String) -> Shapes {
        //print("Shape \(hexString)")
        switch hexString {
        case "01":
            return .sphere
        case "02":
            return .cylinder
        case "03":
            return .tetrahedron
        case "04":
            return .cube
        case "05":
            return .octahedron
        case "06":
            return .dodecahedron
        case "07":
            return .cone
        case "08":
            return .torus
        default:
            return .sphere
        }
    }
    
    public func getYearFromHexString(hexString: String) -> Years {
        //print("Year \(hexString)")
        switch hexString {
        case "01":
            return .year1
        case "02":
            return .year2
        case "03":
            return .year3
        case "04":
            return .year4
        case "05":
            return .year5
        case "06":
            return .year6
        case "07":
            return .year7
        case "08":
            return .year8
        default:
            return .year8
        }
    }
    
    public func getOrdinalFromHexString(hexString: String) -> Int {
        //print("Ordinal \(hexString)")
        return Int(hexString, radix: 16)!
    }
    
    public func getNineumForRarityOrdering(nineum: [String], anOrdering: [String]?) -> [Int: [Int: String]] {
        var results = [Int: [Int: String]]()
        var tempResults = [Int: [Int: String]]()
        var mapping = [String: Int]()
        var sectionIndex = 0
        var itemIndex = 0
        for ninea in nineum {
            let aNineum = getNineumFromHexString(hexString: ninea)
            
            if anOrdering != nil {
                sectionIndex = (anOrdering?.firstIndex(of: aNineum.rarity.rawValue))!
                if mapping[aNineum.rarity.rawValue] != nil {
                    itemIndex = mapping[aNineum.rarity.rawValue]!
                    mapping[aNineum.rarity.rawValue]! += 1
                }
                tempResults[sectionIndex]![itemIndex] = ninea
            } else {
                if tempResults[sectionIndex] == nil {
                    tempResults[sectionIndex] = [Int: String]()
                }
                tempResults[sectionIndex]![itemIndex] = ninea
                itemIndex += 1
            }
        }
        results = tempResults
        return results
    }
    
    //Helper methods for the collection view
    public func getOrderedRaritiesFromNineumArray(nineum: [String], anOrdering: [String] = ["Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Nine"]) -> [String] {
        var results = [String]()
        var tempResults = [String]()
        var mapping = [String: Int]()
        for ninea in nineum {
            let aNineum = getNineumFromHexString(hexString: ninea)
            if mapping[aNineum.rarity.rawValue] == nil {
                mapping[aNineum.rarity.rawValue] = 1
                tempResults.append(aNineum.rarity.rawValue)
            }
        }
        
        for rarity in anOrdering {
            if tempResults.contains(rarity) {
                results.append(rarity)
            }
        }
        
        return results
    }
    
    public func getCountForRarity(nineum: [String], rarity: Rarities) -> Int {
        var count = 0
        for ninea in nineum {
            if getNineumFromHexString(hexString: ninea).rarity == rarity {
                count += 1
            }
        }
        return count
    }
    
    public func getImageForRarity(rarity: Rarities) -> UIImage {
        switch rarity {
        case .common:
            return UIImage(named: "NineumBubble_Pink")!
        case .uncommon:
            return UIImage(named: "NineumBubble_Yellow")!
        case .rare:
            return UIImage(named: "NineumBubble_Orange")!
        case .epic:
            return UIImage(named: "NineumBubble_LightBlue")!
        case .legendary:
            return UIImage(named: "NineumBubble_Teal")!
        case .mythical:
            return UIImage(named: "NineumBubble_Purple")!
        case .nine:
            return UIImage(named: "NineumBubble_Green")!
        }
    }
    
    public func getBigImageForRarity(rarity: Rarities) -> UIImage {
        switch rarity {
        case .common:
            return UIImage(named: "Nineum1_Large")!
        case .uncommon:
            return UIImage(named: "Nineum3_Large")!
        case .rare:
            return UIImage(named: "Nineum4_Large")!
        case .epic:
            return UIImage(named: "Nineum5_Large")!
        case .legendary:
            return UIImage(named: "Nineum6_Large")!
        case .mythical:
            return UIImage(named: "Nineum7_Large")!
        case .nine:
            return UIImage(named: "Nineum2_Large")!
        }
    }
}
