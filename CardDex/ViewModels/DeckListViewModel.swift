//
//  DeckListViewModel.swift
//  CardDex
//
//  Created by Martin Plut on 2/2/26.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class DeckListViewModel {
    
    private let modelContext: ModelContext
    
    // MARK: - State
    var decks: [Deck] = []
    var searchText: String = "" {
        didSet {
            applyFiltersAndSort()
        }
    }
    var filteredDecks: [Deck] = []
    var selectedSortOption: DeckSortOption = .dateModified {
        didSet {
            applyFiltersAndSort()
        }
    }
    var showFavoritesOnly: Bool = false {
        didSet {
            applyFiltersAndSort()
        }
    }
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Sort Options
    enum DeckSortOption: String, CaseIterable {
        case name = "Name"
        case dateCreated = "Date Created"
        case dateModified = "Date Modified"
        case cardCount = "Card Count"
        
        var systemImage: String {
            switch self {
            case .name: return "textformat"
            case .dateCreated: return "calendar.badge.plus"
            case .dateModified: return "calendar.badge.clock"
            case .cardCount: return "number"
            }
        }
    }
    
    // MARK: - Computed Properties
    var totalDecks: Int {
        decks.count
    }
    
    var validDecks: Int {
        decks.filter { $0.isValid }.count
    }
    
    var favoriteDecks: Int {
        decks.filter { $0.isFavorite }.count
    }
    
    var hasActiveFilters: Bool {
        !searchText.isEmpty || showFavoritesOnly
    }
    
    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchDecks()
    }
    
    // MARK: - Data Operations
    
    func fetchDecks() {
        let descriptor = FetchDescriptor<Deck>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        
        do {
            decks = try modelContext.fetch(descriptor)
            applyFiltersAndSort()
        } catch {
            errorMessage = "Failed to fetch decks: \(error.localizedDescription)"
        }
    }
    
    func createDeck(name: String, description: String?) {
        let deck = Deck(
            name: name,
            deckDescription: description
        )
        
        modelContext.insert(deck)
        saveContext()
        fetchDecks()
    }
    
    func deleteDeck(_ deck: Deck) {
        modelContext.delete(deck)
        saveContext()
        fetchDecks()
    }
    
    func duplicateDeck(_ deck: Deck) {
        // Create new deck with same name (+ copy)
        let newDeck = Deck(
            name: "\(deck.name) (Copy)",
            deckDescription: deck.deckDescription,
            isFavorite: false
        )
        
        modelContext.insert(newDeck)
        
        // Copy all cards
        if let deckCards = deck.deckCards {
            for deckCard in deckCards {
                let newDeckCard = DeckCard(
                    quantity: deckCard.quantity,
                    deck: newDeck,
                    card: deckCard.card
                )
                modelContext.insert(newDeckCard)
            }
        }
        
        saveContext()
        fetchDecks()
    }
    
    func toggleFavorite(_ deck: Deck) {
        deck.isFavorite.toggle()
        deck.updatedAt = Date()
        saveContext()
        fetchDecks()
    }
    
    func updateDeck(_ deck: Deck, name: String, description: String?) {
        deck.name = name
        deck.deckDescription = description
        deck.updatedAt = Date()
        saveContext()
        fetchDecks()
    }
    
    // MARK: - Filtering and Sorting
    
    private func applyFiltersAndSort() {
        var result = decks
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { deck in
                deck.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply favorites filter
        if showFavoritesOnly {
            result = result.filter { $0.isFavorite }
        }
        
        // Apply sorting
        result = sortDecks(result, by: selectedSortOption)
        
        filteredDecks = result
    }
    
    private func sortDecks(_ decks: [Deck], by option: DeckSortOption) -> [Deck] {
        switch option {
        case .name:
            return decks.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .dateCreated:
            return decks.sorted { $0.createdAt > $1.createdAt }
        case .dateModified:
            return decks.sorted { $0.updatedAt > $1.updatedAt }
        case .cardCount:
            return decks.sorted { $0.totalCards > $1.totalCards }
        }
    }
    
    func clearFilters() {
        searchText = ""
        showFavoritesOnly = false
    }
    
    // MARK: - Helper Methods
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Statistics
    
    func deckStatistics() -> DeckStatistics {
        DeckStatistics(
            totalDecks: totalDecks,
            validDecks: validDecks,
            favoriteDecks: favoriteDecks,
            totalCards: decks.reduce(0) { $0 + $1.totalCards }
        )
    }
}

// MARK: - Supporting Types

struct DeckStatistics {
    let totalDecks: Int
    let validDecks: Int
    let favoriteDecks: Int
    let totalCards: Int
}
