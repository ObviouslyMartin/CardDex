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
    }
}

// MARK: - Computed Properties
extension Deck {
    var totalCards: Int {
        deckCards?.reduce(0) { $0 + $1.quantity } ?? 0
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
        deckCards?.filter { $0.card?.isEnergy == true }
            .reduce(0) { $0 + $1.quantity } ?? 0
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
}
