//
//  TypeEffect.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//


import Foundation

struct TypeEffect: Codable, Hashable {
    let type: String // Energy type (e.g., "Fire", "Water")
    let value: String // Modifier (e.g., "×2", "+20", "-30")
    
    init(type: String, value: String) {
        self.type = type
        self.value = value
    }
}

// MARK: - Computed Properties
extension TypeEffect {
    var isMultiplier: Bool {
        value.contains("×")
    }
    
    var isAdditive: Bool {
        value.hasPrefix("+")
    }
    
    var isReduction: Bool {
        value.hasPrefix("-")
    }
    
    var numericValue: Int? {
        let numbers = value.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Int(numbers)
    }
}

// MARK: - ValueTransformer for SwiftData
final class TypeEffectTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let effects = value as? [TypeEffect] else { return nil }
        return try? JSONEncoder().encode(effects)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? JSONDecoder().decode([TypeEffect].self, from: data)
    }
}
