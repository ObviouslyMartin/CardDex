//
//  CardSearchResponse.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//


import Foundation

// MARK: - Card Response (Full)
struct CardAPIResponse: Codable, Identifiable {
    let id: String
    let localId: String
    let name: String
    let image: String?
    
    // Category (Pokémon, Trainer, Energy)
    let category: String?
    
    // Pokémon specific
    let hp: Int?
    let types: [String]?
    let evolveFrom: String?
    let description: String?
    let level: String?
    let stage: String?
    
    // Abilities and Attacks
    let abilities: [AbilityAPI]?
    let attacks: [AttackAPI]?
    
    // Weaknesses and Resistances
    let weaknesses: [WeaknessResistanceAPI]?
    let resistances: [WeaknessResistanceAPI]?
    let retreat: Int?
    
    // Set Information
    let set: SetBriefAPI
    
    // Additional Info
    let rarity: String?
    let illustrator: String?
    let regulationMark: String?
    
    // Trainer specific
    let effect: String?
    let trainerType: String?
    
    // Legal information
    let legal: LegalAPI?
    
    enum CodingKeys: String, CodingKey {
        case id, localId, name, image, category, types, evolveFrom, description, level, stage
        case abilities, attacks, weaknesses, resistances, retreat, set, rarity, illustrator
        case regulationMark, effect, trainerType, legal, hp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        localId = try container.decode(String.self, forKey: .localId)
        name = try container.decode(String.self, forKey: .name)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        
        // Handle HP as either Int or String
        if let hpInt = try? container.decodeIfPresent(Int.self, forKey: .hp) {
            hp = hpInt
        } else if let hpString = try? container.decodeIfPresent(String.self, forKey: .hp),
                  let hpInt = Int(hpString) {
            hp = hpInt
        } else {
            hp = nil
        }
        
        types = try container.decodeIfPresent([String].self, forKey: .types)
        evolveFrom = try container.decodeIfPresent(String.self, forKey: .evolveFrom)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        level = try container.decodeIfPresent(String.self, forKey: .level)
        stage = try container.decodeIfPresent(String.self, forKey: .stage)
        abilities = try container.decodeIfPresent([AbilityAPI].self, forKey: .abilities)
        attacks = try container.decodeIfPresent([AttackAPI].self, forKey: .attacks)
        weaknesses = try container.decodeIfPresent([WeaknessResistanceAPI].self, forKey: .weaknesses)
        resistances = try container.decodeIfPresent([WeaknessResistanceAPI].self, forKey: .resistances)
        
        // Handle retreat as either Int or String
        if let retreatInt = try? container.decodeIfPresent(Int.self, forKey: .retreat) {
            retreat = retreatInt
        } else if let retreatString = try? container.decodeIfPresent(String.self, forKey: .retreat),
                  let retreatInt = Int(retreatString) {
            retreat = retreatInt
        } else {
            retreat = nil
        }
        
        set = try container.decode(SetBriefAPI.self, forKey: .set)
        rarity = try container.decodeIfPresent(String.self, forKey: .rarity)
        illustrator = try container.decodeIfPresent(String.self, forKey: .illustrator)
        regulationMark = try container.decodeIfPresent(String.self, forKey: .regulationMark)
        effect = try container.decodeIfPresent(String.self, forKey: .effect)
        trainerType = try container.decodeIfPresent(String.self, forKey: .trainerType)
        legal = try container.decodeIfPresent(LegalAPI.self, forKey: .legal)
    }
}

// MARK: - Card Brief (List Response)
struct CardBriefAPI: Codable, Identifiable {
    let id: String
    let localId: String
    let name: String
    let image: String?
}

// MARK: - Set Response (Full)
struct SetAPIResponse: Codable, Identifiable {
    let id: String
    let name: String
    let logo: String?
    let symbol: String?
    
    let cardCount: CardCountAPI
    let releaseDate: String
    let legal: LegalAPI?
    
    let serie: SerieBriefAPI?
    let tcgOnline: String?
    
    let cards: [CardBriefAPI]?
}

// MARK: - Set Brief (List Response)
struct SetBriefAPI: Codable, Identifiable {
    let id: String
    let name: String
    let logo: String?
    let symbol: String?
    let cardCount: CardCountAPI?
}

// MARK: - Serie Response
struct SerieAPIResponse: Codable, Identifiable {
    let id: String
    let name: String
    let logo: String?
    let sets: [SetBriefAPI]?
}

struct SerieBriefAPI: Codable, Identifiable {
    let id: String
    let name: String
}

// MARK: - Supporting Structures
struct AttackAPI: Codable, Hashable {
    let cost: [String]?
    let name: String
    let effect: String?
    let damage: String?
    
    enum CodingKeys: String, CodingKey {
        case cost, name, effect, damage
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cost = try container.decodeIfPresent([String].self, forKey: .cost)
        name = try container.decode(String.self, forKey: .name)
        effect = try container.decodeIfPresent(String.self, forKey: .effect)
        
        // Handle damage as either String or Int
        if let damageString = try? container.decodeIfPresent(String.self, forKey: .damage) {
            damage = damageString
        } else if let damageInt = try? container.decodeIfPresent(Int.self, forKey: .damage) {
            damage = String(damageInt)
        } else {
            damage = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(cost, forKey: .cost)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(effect, forKey: .effect)
        try container.encodeIfPresent(damage, forKey: .damage)
    }
}

struct AbilityAPI: Codable, Hashable {
    let type: String?
    let name: String
    let effect: String
}

struct WeaknessResistanceAPI: Codable, Hashable {
    let type: String
    let value: String?
    
    enum CodingKeys: String, CodingKey {
        case type, value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        
        // Handle value as either String or Int
        if let valueString = try? container.decodeIfPresent(String.self, forKey: .value) {
            value = valueString
        } else if let valueInt = try? container.decodeIfPresent(Int.self, forKey: .value) {
            value = String(valueInt)
        } else {
            value = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(value, forKey: .value)
    }
}

struct CardCountAPI: Codable {
    let total: Int?
    let official: Int
    let normal: Int?
    let reverse: Int?
    let holo: Int?
    let firstEd: Int?
}

struct LegalAPI: Codable {
    let standard: Bool?
    let expanded: Bool?
}

// MARK: - Sets List Response
typealias SetsListResponse = [SetBriefAPI]

// MARK: - Cards List Response
typealias CardsListResponse = [CardBriefAPI]
