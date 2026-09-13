//
//  BasicEnergy.swift
//  CardDex
//
//  Created by Martin Plut on 2/8/26.
//

import Foundation
import SwiftData

@Model
final class BasicEnergy {
    var type: String // "Fire", "Water", "Grass", etc.
    var count: Int
    var dateModified: Date
    
    init(type: String, count: Int = 0) {
        self.type = type
        self.count = count
        self.dateModified = Date()
    }
    
    // All Pokemon TCG energy types
    static let allTypes = [
        "Grass",
        "Fire",
        "Water",
        "Lightning",
        "Psychic",
        "Fighting",
        "Darkness",
        "Metal"
    ]
    
    // Helper to get display icon for each type
    var icon: String {
        switch type.lowercased() {
        case "grass": return "grass"
        case "fire": return "fire"
        case "water": return "water"
        case "lightning": return "lightning"
        case "psychic": return "psychic"
        case "fighting": return "fighting"
        case "darkness": return "dark"
        case "metal": return "metal"
        default: return "circle.fill"
        }
    }
}


