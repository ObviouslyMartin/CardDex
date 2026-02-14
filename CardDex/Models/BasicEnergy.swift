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
        case "grass": return "leaf.fill"
        case "fire": return "flame.fill"
        case "water": return "drop.fill"
        case "lightning": return "bolt.fill"
        case "psychic": return "brain.head.profile"
        case "fighting": return "figure.boxing"
        case "darkness": return "moon.fill"
        case "metal": return "shield.fill"
        default: return "circle.fill"
        }
    }
}


