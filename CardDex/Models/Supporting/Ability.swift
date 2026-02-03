//
//  Ability.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//

import Foundation

struct Ability: Codable, Hashable {
    let name: String
    let text: String
    let type: String // "Ability" or "Poké-Power" or "Poké-Body" etc.
    
    init(name: String, text: String, type: String = "Ability") {
        self.name = name
        self.text = text
        self.type = type
    }
}

// MARK: - Computed Properties
extension Ability {
    var displayType: String {
        type.replacingOccurrences(of: "Poké-", with: "")
    }
    
    var isModern: Bool {
        type == "Ability"
    }
}

// MARK: - ValueTransformer for SwiftData
final class AbilityTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let ability = value as? Ability else { return nil }
        return try? JSONEncoder().encode(ability)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? JSONDecoder().decode(Ability.self, from: data)
    }
}
