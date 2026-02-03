//
//  DeckBuilderViewModel.swift
//  CardDex
//
//  Created by Martin Plut on 2/2/26.
//


import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class DeckBuilderViewModel {
    
    private let modelContext: ModelContext
    let deck: Deck
    
    // MARK: - State
    var deckCards: [DeckCard] = []
    var availableCards: [Card] = []
    var searchText: String = "" {
        didSet {
            applyFilters()
        }
    }
    var filteredCards: [Card] = []
    var selectedSupertypes: Set<String> = [] {
        didSet {
            applyFilters()
        }
    }
    var selectedTypes: Set<String> = [] {
        didSet {
            applyFilters()
        }
    }
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Computed Properties
    
    var totalCards: Int {
        deck.totalCards
    }
    
    var uniqueCards: Int {
        deck.uniqueCards
    }
    
    var isValid: Bool {
        deck.isValid
    }
    
    var pokemonCount: Int {
        deck.pokemonCount
    }
    
    var trainerCount: Int {
        deck.trainerCount
    }
    
    var energyCount: Int {
        deck.energyCount
    }
    
    var needsMoreCards: Int {
        deck.needsMoreCards
    }
    
    var hasTooManyCards: Bool {
        deck.hasTooManyCards
    }
    
    var statusMessage: String {
        if isValid {
            return "✓ Deck is valid (60 cards)"
        } else if hasTooManyCards {
            return "⚠️ Too many cards (\(totalCards)/60)"
        } else {
            return "⚠️ Need \(needsMoreCards) more cards (\(totalCards)/60)"
        }
    }
    
    var statusColor: Color {
        if isValid {
            return .green
        } else if hasTooManyCards {
            return .red
        } else {
            return .orange
        }
    }
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext, deck: Deck) {
        self.modelContext = modelContext
        self.deck = deck
        fetchData()
    }
    
    // MARK: - Data Operations
    
    func fetchData() {
        // Fetch deck cards
        deckCards = deck.deckCards ?? []
        
        // Fetch all cards from collection
        let descriptor = FetchDescriptor<Card>(
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            availableCards = try modelContext.fetch(descriptor)
            applyFilters()
        } catch {
            errorMessage = "Failed to fetch cards: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Card Management
    
    func addCard(_ card: Card, quantity: Int = 1) {
        let currentInDeck = cardQuantityInDeck(card)
        let maxAllowed = maxAllowedQuantity(for: card)
        
        // Don't add if already at limit
        guard maxAllowed > 0 else {
            print("⚠️ Cannot add \(card.name): Already at limit (in deck: \(currentInDeck), owned: \(card.quantityOwned))")
            return
        }
        
        // Check if card already exists in deck
        if let existingDeckCard = deckCards.first(where: { $0.card?.id == card.id }) {
            // Update quantity (respect both game rules and owned quantity)
            let newQuantity = min(existingDeckCard.quantity + quantity, currentInDeck + maxAllowed)
            existingDeckCard.quantity = newQuantity
            print("✅ Updated \(card.name) to \(newQuantity) in deck (owned: \(card.quantityOwned))")
        } else {
            // Create new DeckCard (respect limits)
            let safeQuantity = min(quantity, maxAllowed)
            let deckCard = DeckCard(
                quantity: safeQuantity,
                deck: deck,
                card: card
            )
            modelContext.insert(deckCard)
            print("✅ Added \(safeQuantity)x \(card.name) to deck (owned: \(card.quantityOwned))")
        }
        
        deck.updatedAt = Date()
        saveContext()
        fetchData()
    }
    
    func removeCard(_ card: Card, quantity: Int = 1) {
        guard let deckCard = deckCards.first(where: { $0.card?.id == card.id }) else {
            return
        }
        
        if deckCard.quantity <= quantity {
            // Remove completely
            modelContext.delete(deckCard)
        } else {
            // Decrease quantity
            deckCard.quantity -= quantity
        }
        
        deck.updatedAt = Date()
        saveContext()
        fetchData()
    }
    
    func updateCardQuantity(_ card: Card, quantity: Int) {
        guard let deckCard = deckCards.first(where: { $0.card?.id == card.id }) else {
            return
        }
        
        if quantity <= 0 {
            modelContext.delete(deckCard)
        } else {
            deckCard.quantity = min(quantity, 4)
        }
        
        deck.updatedAt = Date()
        saveContext()
        fetchData()
    }
    
    func removeCardCompletely(_ card: Card) {
        guard let deckCard = deckCards.first(where: { $0.card?.id == card.id }) else {
            return
        }
        
        modelContext.delete(deckCard)
        deck.updatedAt = Date()
        saveContext()
        fetchData()
    }
    
    // MARK: - Card Queries
    
    func cardQuantityInDeck(_ card: Card) -> Int {
        deck.cardQuantity(for: card)
    }
    
    func isCardInDeck(_ card: Card) -> Bool {
        deck.containsCard(card)
    }
    
    func canAddCard(_ card: Card) -> Bool {
        let currentInDeck = cardQuantityInDeck(card)
        let owned = card.quantityOwned
        
        // Can only add if:
        // 1. Less than 4 in deck (game rules)
        // 2. Have enough owned copies remaining
        return currentInDeck < 4 && currentInDeck < owned
    }
    
    func maxAllowedQuantity(for card: Card) -> Int {
        let currentInDeck = cardQuantityInDeck(card)
        let owned = card.quantityOwned
        let gameRuleMax = 4
        
        // Max is the lesser of:
        // - Game rules (4 max per card)
        // - What you own
        return min(gameRuleMax - currentInDeck, owned - currentInDeck)
    }
    
    func availableQuantity(for card: Card) -> Int {
        let currentInDeck = cardQuantityInDeck(card)
        return card.quantityOwned - currentInDeck
    }
    
    // MARK: - Filtering
    
    private func applyFilters() {
        var result = availableCards
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { card in
                card.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply supertype filter
        if !selectedSupertypes.isEmpty {
            result = result.filter { card in
                selectedSupertypes.contains(card.supertype)
            }
        }
        
        // Apply type filter
        if !selectedTypes.isEmpty {
            result = result.filter { card in
                guard let types = card.types else { return false }
                return !Set(types).isDisjoint(with: selectedTypes)
            }
        }
        
        filteredCards = result
    }
    
    func clearFilters() {
        searchText = ""
        selectedSupertypes.removeAll()
        selectedTypes.removeAll()
    }
    
    // MARK: - Sorting
    
    func sortDeckCards(by option: DeckCardSortOption) -> [DeckCard] {
        let cards = deckCards
        
        switch option {
        case .name:
            return cards.sorted { ($0.card?.name ?? "") < ($1.card?.name ?? "") }
        case .type:
            return cards.sorted { ($0.card?.supertype ?? "") < ($1.card?.supertype ?? "") }
        case .quantity:
            return cards.sorted { $0.quantity > $1.quantity }
        case .dateAdded:
            return cards.sorted { $0.addedAt > $1.addedAt }
        }
    }
    
    enum DeckCardSortOption: String, CaseIterable {
        case name = "Name"
        case type = "Type"
        case quantity = "Quantity"
        case dateAdded = "Date Added"
    }
    
    // MARK: - Statistics
    
    func cardTypeBreakdown() -> [String: Int] {
        var breakdown: [String: Int] = [:]
        
        for deckCard in deckCards {
            guard let card = deckCard.card else { continue }
            let type = card.supertype
            breakdown[type, default: 0] += deckCard.quantity
        }
        
        return breakdown
    }
    
    func energyTypeBreakdown() -> [String: Int] {
        deck.energyTypes
    }
    
    // MARK: - Validation
    
    func validateDeck() -> [ValidationIssue] {
        var issues: [ValidationIssue] = []
        
        // Check total card count
        if totalCards < 60 {
            issues.append(.tooFewCards(needsMoreCards))
        } else if totalCards > 60 {
            issues.append(.tooManyCards(totalCards - 60))
        }
        
        // Check for illegal quantities (should never happen, but safety check)
        for deckCard in deckCards {
            if deckCard.quantity > 4 {
                issues.append(.illegalQuantity(deckCard.card?.name ?? "Unknown", deckCard.quantity))
            }
        }
        
        // Check minimum Pokémon count (recommended)
        if pokemonCount < 10 {
            issues.append(.lowPokemonCount(pokemonCount))
        }
        
        // Check minimum Energy count (recommended)
        if energyCount < 10 {
            issues.append(.lowEnergyCount(energyCount))
        }
        
        return issues
    }
    
    enum ValidationIssue: Identifiable {
        case tooFewCards(Int)
        case tooManyCards(Int)
        case illegalQuantity(String, Int)
        case lowPokemonCount(Int)
        case lowEnergyCount(Int)
        
        var id: String {
            switch self {
            case .tooFewCards: return "tooFewCards"
            case .tooManyCards: return "tooManyCards"
            case .illegalQuantity(let name, _): return "illegalQuantity-\(name)"
            case .lowPokemonCount: return "lowPokemonCount"
            case .lowEnergyCount: return "lowEnergyCount"
            }
        }
        
        var message: String {
            switch self {
            case .tooFewCards(let count):
                return "Need \(count) more cards to reach 60"
            case .tooManyCards(let count):
                return "Remove \(count) cards (currently over 60)"
            case .illegalQuantity(let name, let quantity):
                return "\(name) has \(quantity) copies (max 4 allowed)"
            case .lowPokemonCount(let count):
                return "Only \(count) Pokémon cards (recommended: 10+)"
            case .lowEnergyCount(let count):
                return "Only \(count) Energy cards (recommended: 10+)"
            }
        }
        
        var severity: ValidationSeverity {
            switch self {
            case .tooFewCards, .tooManyCards, .illegalQuantity:
                return .error
            case .lowPokemonCount, .lowEnergyCount:
                return .warning
            }
        }
    }
    
    enum ValidationSeverity {
        case error
        case warning
        
        var color: Color {
            switch self {
            case .error: return .red
            case .warning: return .orange
            }
        }
        
        var icon: String {
            switch self {
            case .error: return "xmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
        }
    }
}
