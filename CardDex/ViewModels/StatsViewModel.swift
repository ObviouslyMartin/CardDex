//
//  StatsViewModel.swift
//  CardDex
//
//  Created by Martin Plut on 9/13/26.
//


 
import Foundation
import SwiftData
 
@MainActor
@Observable
final class StatsViewModel {
 
    private let modelContext: ModelContext
 
    // MARK: - State
    var cards: [Card] = []
    var sets: [CardSet] = []
    var deckCount: Int = 0
    var errorMessage: String?
 
    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchData()
    }
 
    // MARK: - Data Operations
    func fetchData() {
        let cardDescriptor = FetchDescriptor<Card>()
        let setDescriptor = FetchDescriptor<CardSet>(sortBy: [SortDescriptor(\.name)])
        let deckDescriptor = FetchDescriptor<Deck>()
 
        do {
            cards = try modelContext.fetch(cardDescriptor)
        } catch {
            errorMessage = "Failed to fetch cards: \(error.localizedDescription)"
            cards = []
        }
 
        do {
            sets = try modelContext.fetch(setDescriptor)
        } catch {
            errorMessage = "Failed to fetch sets: \(error.localizedDescription)"
            sets = []
        }
 
        do {
            deckCount = try modelContext.fetchCount(deckDescriptor)
        } catch {
            deckCount = 0
        }
    }
 
    // MARK: - Owned Cards
 
    /// Cards actually owned (quantity > 0) — excludes cards edited down to zero copies.
    private var ownedCards: [Card] {
        cards.filter { $0.quantityOwned > 0 }
    }
 
    var hasCollection: Bool {
        !ownedCards.isEmpty
    }
 
    // MARK: - Overview Stats
 
    var totalCardsOwned: Int {
        ownedCards.reduce(0) { $0 + $1.quantityOwned }
    }
 
    var uniqueCardsOwned: Int {
        ownedCards.count
    }
 
    var setsStarted: Int {
        startedSets.count
    }
 
    var totalDecks: Int {
        deckCount
    }
 
    // MARK: - Set Completion
 
    /// Sets with at least one owned card, sorted by completion percentage (highest first).
    var startedSets: [CardSet] {
        sets
            .filter { $0.ownedCardsCount > 0 }
            .sorted { lhs, rhs in
                if lhs.completionPercentage != rhs.completionPercentage {
                    return lhs.completionPercentage > rhs.completionPercentage
                }
                return lhs.name < rhs.name
            }
    }
 
    // MARK: - Breakdown Stats
 
    /// Owned card counts grouped by supertype (Pokémon / Trainer / Energy).
    var cardsBySupertype: [(key: String, value: Int)] {
        var counts: [String: Int] = [:]
        for card in ownedCards {
            counts[card.supertype, default: 0] += card.quantityOwned
        }
        return counts.sorted { $0.value > $1.value }
    }
 
    /// Owned card counts grouped by Pokémon elemental type (Fire, Water, etc).
    var cardsByType: [(key: String, value: Int)] {
        var counts: [String: Int] = [:]
        for card in ownedCards {
            guard let types = card.types else { continue }
            for type in types {
                counts[type, default: 0] += card.quantityOwned
            }
        }
        return counts.sorted { $0.value > $1.value }
    }
 
    /// Owned card counts grouped by rarity.
    var cardsByRarity: [(key: String, value: Int)] {
        var counts: [String: Int] = [:]
        for card in ownedCards {
            let rarity = card.rarity ?? "Unknown"
            counts[rarity, default: 0] += card.quantityOwned
        }
        return counts.sorted { $0.value > $1.value }
    }
 
    // MARK: - Helpers
 
    func percentageOfCollection(_ count: Int) -> Double {
        guard totalCardsOwned > 0 else { return 0 }
        return Double(count) / Double(totalCardsOwned) * 100
    }
}
 
