//
//  CardLibraryViewModel.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//


import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class CardLibraryViewModel {
    
    private let modelContext: ModelContext
    
    // MARK: - State
    var cards: [Card] = []
    var filteredCards: [Card] = []
    var searchText: String = "" {
        didSet {
            applyFiltersAndSort()
        }
    }
    var selectedSortOption: CardSortOption = .name {
        didSet {
            applyFiltersAndSort()
        }
    }
    var selectedSupertypes: Set<String> = [] {
        didSet {
            applyFiltersAndSort()
        }
    }
    var selectedTypes: Set<String> = [] {
        didSet {
            applyFiltersAndSort()
        }
    }
    var selectedRarities: Set<String> = [] {
        didSet {
            applyFiltersAndSort()
        }
    }
    var selectedSets: Set<String> = [] {
        didSet {
            applyFiltersAndSort()
        }
    }
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Computed Properties
    var hasActiveFilters: Bool {
        !selectedSupertypes.isEmpty ||
        !selectedTypes.isEmpty ||
        !selectedRarities.isEmpty ||
        !selectedSets.isEmpty ||
        !searchText.isEmpty
    }
    
    var totalCards: Int {
        cards.reduce(0) { $0 + $1.quantityOwned }
    }
    
    var uniqueCards: Int {
        cards.count
    }
    
    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchCards()
    }
    
    // MARK: - Data Operations
    func fetchCards() {
        let descriptor = FetchDescriptor<Card>(
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            cards = try modelContext.fetch(descriptor)
            applyFiltersAndSort()
        } catch {
            errorMessage = "Failed to fetch cards: \(error.localizedDescription)"
        }
    }
    
    func addCard(_ card: Card) {
        modelContext.insert(card)
        saveContext()
        fetchCards()
    }
    
    func updateCardQuantity(_ card: Card, quantity: Int) {
        card.quantityOwned = max(0, quantity)
        saveContext()
        fetchCards()
    }
    
    func deleteCard(_ card: Card) {
        modelContext.delete(card)
        saveContext()
        fetchCards()
    }
    
    func deleteCards(at offsets: IndexSet) {
        for index in offsets {
            let card = filteredCards[index]
            modelContext.delete(card)
        }
        saveContext()
        fetchCards()
    }
    
    // MARK: - Filtering and Sorting
    private func applyFiltersAndSort() {
        var result = cards
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { card in
                card.name.localizedCaseInsensitiveContains(searchText) ||
                card.setName.localizedCaseInsensitiveContains(searchText) ||
                (card.artist?.localizedCaseInsensitiveContains(searchText) ?? false)
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
        
        // Apply rarity filter
        if !selectedRarities.isEmpty {
            result = result.filter { card in
                guard let rarity = card.rarity else { return false }
                return selectedRarities.contains(rarity)
            }
        }
        
        // Apply set filter
        if !selectedSets.isEmpty {
            result = result.filter { card in
                selectedSets.contains(card.setID)
            }
        }
        
        // Apply sorting
        result = sortCards(result, by: selectedSortOption)
        
        filteredCards = result
    }
    
    private func sortCards(_ cards: [Card], by option: CardSortOption) -> [Card] {
        switch option {
        case .name:
            return cards.sorted { $0.name < $1.name }
        case .dateAdded:
            return cards.sorted { $0.dateAdded > $1.dateAdded }
        case .setName:
            return cards.sorted { $0.setName < $1.setName }
        case .number:
            return cards.sorted { compareCardNumbers($0.number, $1.number) }
        case .rarity:
            return cards.sorted { ($0.rarity ?? "") < ($1.rarity ?? "") }
        case .type:
            return cards.sorted { 
                ($0.types?.first ?? "") < ($1.types?.first ?? "")
            }
        }
    }
    
    private func compareCardNumbers(_ num1: String, _ num2: String) -> Bool {
        // Extract numeric part for proper sorting (e.g., "1" < "2" < "10")
        let int1 = Int(num1.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0
        let int2 = Int(num2.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0
        return int1 < int2
    }
    
    func clearFilters() {
        searchText = ""
        selectedSupertypes.removeAll()
        selectedTypes.removeAll()
        selectedRarities.removeAll()
        selectedSets.removeAll()
    }
    
    // MARK: - Helper Methods
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Statistics
    func cardsByType() -> [String: Int] {
        var typeCount: [String: Int] = [:]
        
        for card in cards {
            if let types = card.types {
                for type in types {
                    typeCount[type, default: 0] += card.quantityOwned
                }
            }
        }
        
        return typeCount
    }
    
    func cardsBySupertype() -> [String: Int] {
        var supertypeCount: [String: Int] = [:]
        
        for card in cards {
            supertypeCount[card.supertype, default: 0] += card.quantityOwned
        }
        
        return supertypeCount
    }
    
    func cardsByRarity() -> [String: Int] {
        var rarityCount: [String: Int] = [:]
        
        for card in cards {
            let rarity = card.rarity ?? "Unknown"
            rarityCount[rarity, default: 0] += card.quantityOwned
        }
        
        return rarityCount
    }
}
