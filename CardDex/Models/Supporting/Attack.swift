//
//  Attack.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//


import Foundation

struct Attack: Codable, Hashable {
    let name: String
    let cost: [String]? // Energy types required
    let damage: String? // Can be "20", "30+", "×20", etc.
    let text: String? // Attack description/effect
    let convertedEnergyCost: Int // Total energy needed
    
    init(
        name: String,
        cost: [String]? = nil,
        damage: String? = nil,
        text: String? = nil,
        convertedEnergyCost: Int = 0
    ) {
        self.name = name
        self.cost = cost
        self.damage = damage
        self.text = text
        self.convertedEnergyCost = convertedEnergyCost
    }
}

// MARK: - Computed Properties
extension Attack {
    var hasEffect: Bool {
        text != nil && !text!.isEmpty
    }
    
    var energyCount: Int {
        cost?.count ?? 0
    }
    
    var displayDamage: String {
        damage ?? "—"
    }
    
    var baseDamageValue: Int? {
        guard let damage = damage else { return nil }
        // Extract base number from strings like "20", "30+", "×20"
        let numbers = damage.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Int(numbers)
    }
}

// MARK: - ValueTransformer for SwiftData
final class AttackTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let attacks = value as? [Attack] else { return nil }
        return try? JSONEncoder().encode(attacks)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? JSONDecoder().decode([Attack].self, from: data)
    }
}
