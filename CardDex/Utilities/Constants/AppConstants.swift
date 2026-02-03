//
//  AppConstants.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//


import Foundation

enum AppConstants {
    
    // MARK: - Deck Rules
    enum DeckRules {
        static let standardDeckSize = 60
        static let maxCopiesPerCard = 4
        static let minDeckSize = 60
        static let maxDeckSize = 60
    }
    
    // MARK: - UI Constants
    enum UI {
        static let cardAspectRatio: CGFloat = 2.5 / 3.5
        static let gridSpacing: CGFloat = 12
        static let cornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 4
        
        enum GridColumns {
            static let phonePortrait = 2
            static let phoneLandscape = 3
            static let padPortrait = 3
            static let padLandscape = 5
        }
    }
    
    // MARK: - Image Cache
    enum Cache {
        static let maxMemoryCache = 100 // Number of images
        static let maxDiskCacheSize: Int64 = 500_000_000 // 500MB
        static let cacheFolderName = "CardImageCache"
    }
    
    // MARK: - Search
    enum Search {
        static let debounceDelay: TimeInterval = 0.5
        static let minimumSearchLength = 2
        static let defaultPageSize = 250
    }
    
    // MARK: - Animation
    enum Animation {
        static let defaultDuration: TimeInterval = 0.3
        static let springResponse: Double = 0.4
        static let springDamping: Double = 0.8
    }
    
    // MARK: - Formats
    enum DateFormat {
        static let display = "MMM d, yyyy"
        static let full = "MMMM d, yyyy 'at' h:mm a"
        static let short = "MM/dd/yy"
    }
}

// MARK: - Pokemon Types
enum PokemonType: String, CaseIterable {
    case colorless = "Colorless"
    case darkness = "Darkness"
    case dragon = "Dragon"
    case fairy = "Fairy"
    case fighting = "Fighting"
    case fire = "Fire"
    case grass = "Grass"
    case lightning = "Lightning"
    case metal = "Metal"
    case psychic = "Psychic"
    case water = "Water"
    
    var systemImage: String {
        switch self {
        case .colorless: return "circle"
        case .darkness: return "moon.fill"
        case .dragon: return "flame.fill"
        case .fairy: return "sparkles"
        case .fighting: return "figure.boxing"
        case .fire: return "flame.fill"
        case .grass: return "leaf.fill"
        case .lightning: return "bolt.fill"
        case .metal: return "shield.fill"
        case .psychic: return "eye.fill"
        case .water: return "drop.fill"
        }
    }
}

// MARK: - Card Supertypes
enum CardSupertype: String, CaseIterable {
    case pokemon = "Pokémon"
    case trainer = "Trainer"
    case energy = "Energy"
    
    var systemImage: String {
        switch self {
        case .pokemon: return "figure.stand"
        case .trainer: return "person.fill"
        case .energy: return "bolt.fill"
        }
    }
}

// MARK: - Sort Options
enum CardSortOption: String, CaseIterable {
    case name = "Name"
    case dateAdded = "Date Added"
    case setName = "Set"
    case number = "Number"
    case rarity = "Rarity"
    case type = "Type"
    
    var systemImage: String {
        switch self {
        case .name: return "textformat"
        case .dateAdded: return "calendar"
        case .setName: return "square.stack.3d.up"
        case .number: return "number"
        case .rarity: return "star"
        case .type: return "tag"
        }
    }
}
