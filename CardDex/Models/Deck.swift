//
//  Deck.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//


import Foundation
import SwiftData

@Model
final class Deck {
    var id: UUID
    var name: String
    var deckDescription: String?
    var createdAt: Date
    var updatedAt: Date
    var isFavorite: Bool
    
    @Relationship(deleteRule: .cascade, inverse: \DeckCard.deck)
    var deckCards: [DeckCard]?
    
    // Basic energy counts: [EnergyType: Count]
    // e.g., ["Fire": 10, "Water": 5]
    var basicEnergies: [String: Int]?
    
    init(
        id: UUID = UUID(),
        name: String,
        deckDescription: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.deckDescription = deckDescription
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isFavorite = isFavorite
        self.basicEnergies = [:]
    }
}

// MARK: - Computed Properties
extension Deck {
    var totalCards: Int {
        let deckCardCount = deckCards?.reduce(0) { $0 + $1.quantity } ?? 0
        let basicEnergyCount = basicEnergies?.values.reduce(0, +) ?? 0
        return deckCardCount + basicEnergyCount
    }
    
    var uniqueCards: Int {
        deckCards?.count ?? 0
    }
    
    var isValid: Bool {
        totalCards == 60
    }
    
    var pokemonCount: Int {
        deckCards?.filter { $0.card?.isPokemon == true }
            .reduce(0) { $0 + $1.quantity } ?? 0
    }
    
    var trainerCount: Int {
        deckCards?.filter { $0.card?.isTrainer == true }
            .reduce(0) { $0 + $1.quantity } ?? 0
    }
    
    var energyCount: Int {
        let cardEnergyCount = deckCards?.filter { $0.card?.isEnergy == true }
            .reduce(0) { $0 + $1.quantity } ?? 0
        let basicEnergyCount = basicEnergies?.values.reduce(0, +) ?? 0
        return cardEnergyCount + basicEnergyCount
    }
    
    var energyTypes: [String: Int] {
        var types: [String: Int] = [:]
        
        deckCards?.forEach { deckCard in
            guard let card = deckCard.card,
                  let cardTypes = card.types else { return }
            
            cardTypes.forEach { type in
                types[type, default: 0] += deckCard.quantity
            }
        }
        
        return types
    }
    
    var needsMoreCards: Int {
        max(0, 60 - totalCards)
    }
    
    var hasTooManyCards: Bool {
        totalCards > 60
    }
}

// MARK: - Deck Management Methods
extension Deck {
    func cardQuantity(for card: Card) -> Int {
        deckCards?.first(where: { $0.card?.id == card.id })?.quantity ?? 0
    }
    
    func containsCard(_ card: Card) -> Bool {
        cardQuantity(for: card) > 0
    }
    
    func canAddCard(_ card: Card) -> Bool {
        let currentQuantity = cardQuantity(for: card)
        return currentQuantity < 4 // Standard format rule
    }
    
    // MARK: - Basic Energy Methods
    
    func basicEnergyQuantity(for type: String) -> Int {
        basicEnergies?[type] ?? 0
    }
    
    func setBasicEnergy(type: String, quantity: Int) {
        if basicEnergies == nil {
            basicEnergies = [:]
        }
        basicEnergies?[type] = max(0, quantity)
    }
    
    func addBasicEnergy(type: String, quantity: Int = 1) {
        if basicEnergies == nil {
            basicEnergies = [:]
        }
        let currentQuantity = basicEnergies?[type] ?? 0
        basicEnergies?[type] = currentQuantity + quantity
    }
    
    func removeBasicEnergy(type: String, quantity: Int = 1) {
        guard let currentQuantity = basicEnergies?[type] else { return }
        let newQuantity = max(0, currentQuantity - quantity)
        
        if newQuantity == 0 {
            basicEnergies?.removeValue(forKey: type)
        } else {
            basicEnergies?[type] = newQuantity
        }
    }
    
    func totalBasicEnergies() -> Int {
        basicEnergies?.values.reduce(0, +) ?? 0
    }
}
