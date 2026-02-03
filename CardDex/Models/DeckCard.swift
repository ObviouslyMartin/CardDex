//
//  DeckCard.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//


import Foundation
import SwiftData

@Model
final class DeckCard {
    var quantity: Int
    var addedAt: Date
    
    @Relationship
    var deck: Deck?
    
    @Relationship
    var card: Card?
    
    init(
        quantity: Int = 1,
        addedAt: Date = Date(),
        deck: Deck? = nil,
        card: Card? = nil
    ) {
        self.quantity = quantity
        self.addedAt = addedAt
        self.deck = deck
        self.card = card
    }
}

// MARK: - Computed Properties
extension DeckCard {
    var isMaxed: Bool {
        quantity >= 4 // Standard format limit
    }
    
    var canAddMore: Bool {
        quantity < 4
    }
    
    var displayName: String {
        card?.name ?? "Unknown Card"
    }
}

// MARK: - Helper Methods
extension DeckCard {
    func incrementQuantity() {
        guard canAddMore else { return }
        quantity += 1
    }
    
    func decrementQuantity() {
        guard quantity > 0 else { return }
        quantity -= 1
    }
}
