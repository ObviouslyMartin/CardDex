//
//  Card.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//


import Foundation
import SwiftData

@Model
final class Card {
    // MARK: - Basic Properties
    var id: String
    var name: String
    var supertype: String // "Pokémon", "Trainer", "Energy"
    var subtypes: [String]? // ["Basic", "Stage 1", "Item", "Supporter", etc.]
    
    // MARK: - Pokemon-specific Properties
    var hp: String? // Optional for non-Pokemon cards
    var types: [String]? // ["Fire", "Water", etc.]
    var evolvesFrom: String?
    var evolvesTo: [String]?
    var retreatCost: [String]? // Array of energy types
    
    // MARK: - Abilities and Attacks
    @Attribute(.externalStorage)
    var attacksData: Data?
    
    @Attribute(.externalStorage)
    var abilityData: Data?
    
    // MARK: - Type Effects
    @Attribute(.externalStorage)
    var weaknessesData: Data?
    
    @Attribute(.externalStorage)
    var resistancesData: Data?
    
    // Computed properties for easy access
    var attacks: [Attack]? {
        get {
            guard let data = attacksData else { return nil }
            return try? JSONDecoder().decode([Attack].self, from: data)
        }
        set {
            attacksData = try? JSONEncoder().encode(newValue)
        }
    }
    
    var ability: Ability? {
        get {
            guard let data = abilityData else { return nil }
            return try? JSONDecoder().decode(Ability.self, from: data)
        }
        set {
            abilityData = try? JSONEncoder().encode(newValue)
        }
    }
    
    var weaknesses: [TypeEffect]? {
        get {
            guard let data = weaknessesData else { return nil }
            return try? JSONDecoder().decode([TypeEffect].self, from: data)
        }
        set {
            weaknessesData = try? JSONEncoder().encode(newValue)
        }
    }
    
    var resistances: [TypeEffect]? {
        get {
            guard let data = resistancesData else { return nil }
            return try? JSONDecoder().decode([TypeEffect].self, from: data)
        }
        set {
            resistancesData = try? JSONEncoder().encode(newValue)
        }
    }
    
    // Trainer specific
    var effect: String?
    var trainerType: String?
    
    // MARK: - Set Information
    var setID: String
    var setName: String
    var setLogo: String?
    var number: String
    var rarity: String?
    
    // MARK: - Images
    var imageSmall: String?
    var imageLarge: String?
    
    // MARK: - Additional Info
    var artist: String?
    var flavorText: String?
    var nationalPokedexNumbers: [Int]?
    var regulationMark: String?
    
    // MARK: - Collection Management
    var quantityOwned: Int
    var dateAdded: Date
    
    // MARK: - Relationships
    @Relationship(deleteRule: .cascade, inverse: \DeckCard.card)
    var deckCards: [DeckCard]?
    
    @Relationship(inverse: \CardSet.cards)
    var cardSet: CardSet?
    
    // MARK: - Initialization
    init(
        id: String,
        name: String,
        supertype: String,
        subtypes: [String]? = nil,
        hp: String? = nil,
        types: [String]? = nil,
        evolvesFrom: String? = nil,
        evolvesTo: [String]? = nil,
        retreatCost: [String]? = nil,
        attacks: [Attack]? = nil,
        ability: Ability? = nil,
        weaknesses: [TypeEffect]? = nil,
        resistances: [TypeEffect]? = nil,
        effect: String? = nil,
        trainerType: String? = nil,
        setID: String,
        setName: String,
        setLogo: String? = nil,
        number: String,
        rarity: String? = nil,
        imageSmall: String? = nil,
        imageLarge: String? = nil,
        artist: String? = nil,
        flavorText: String? = nil,
        nationalPokedexNumbers: [Int]? = nil,
        regulationMark: String? = nil,
        quantityOwned: Int = 1,
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.supertype = supertype
        self.subtypes = subtypes
        self.hp = hp
        self.types = types
        self.evolvesFrom = evolvesFrom
        self.evolvesTo = evolvesTo
        self.retreatCost = retreatCost
        
        // Encode complex types to Data
        self.attacksData = try? JSONEncoder().encode(attacks)
        self.abilityData = try? JSONEncoder().encode(ability)
        self.weaknessesData = try? JSONEncoder().encode(weaknesses)
        self.resistancesData = try? JSONEncoder().encode(resistances)
        self.effect = effect
        self.trainerType = trainerType
        self.setID = setID
        self.setName = setName
        self.setLogo = setLogo
        self.number = number
        self.rarity = rarity
        self.imageSmall = imageSmall
        self.imageLarge = imageLarge
        self.artist = artist
        self.flavorText = flavorText
        self.nationalPokedexNumbers = nationalPokedexNumbers
        self.regulationMark = regulationMark
        self.quantityOwned = quantityOwned
        self.dateAdded = dateAdded
    }
}

// MARK: - Computed Properties
extension Card {
    var isPokemon: Bool {
        let lowercased = supertype.lowercased()
        return lowercased == "pokémon" || lowercased == "pokemon"
    }
    
    var isTrainer: Bool {
        supertype.lowercased() == "trainer"
    }
    
    var isEnergy: Bool {
        supertype.lowercased() == "energy"
    }
    
    var displayImage: String {
        imageLarge ?? imageSmall ?? ""
    }
    
    var hasAbility: Bool {
        ability != nil
    }
    
    var attackCount: Int {
        attacks?.count ?? 0
    }
}
