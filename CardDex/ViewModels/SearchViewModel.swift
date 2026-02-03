//
//  SearchViewModel.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//


import Foundation
import SwiftData

@MainActor
@Observable
final class SearchViewModel {
    
    private let apiService = TCGdexService.shared
    private let modelContext: ModelContext
    
    // MARK: - State
    var searchText: String = ""
    var cardBriefResults: [CardBriefAPI] = [] // Show briefs immediately
    var isSearching = false
    var errorMessage: String?
    var hasMoreResults = false
    
    // MARK: - Search Mode
    enum SearchMode {
        case setName
        case cardName
        case cardNumber
        
        var placeholder: String {
            switch self {
            case .setName: return "Enter set name (e.g., Journey Together)"
            case .cardName: return "Search card name (e.g., Charizard)"
            case .cardNumber: return "Enter card number (e.g., 25/167)"
            }
        }
    }
    
    var searchMode: SearchMode = .setName
    
    // MARK: - Set Selection
    var selectedSet: SetAPIResponse?
    var setSearchResults: [SetBriefAPI] = []
    
    // MARK: - Bulk Selection State
    var selectedCards: [String: Int] = [:] // cardId: quantity
    
    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Search Operations
    
    func search() async {
        guard !searchText.isEmpty else {
            cardBriefResults = []
            setSearchResults = []
            return
        }
        
        isSearching = true
        errorMessage = nil
        selectedSet = nil
        
        do {
            switch searchMode {
            case .setName:
                await searchBySetName()
            case .cardName:
                await searchByCardName()
            case .cardNumber:
                await searchByCardNumber()
            }
        }
        
        isSearching = false
    }
    
    private func searchBySetName() async {
        do {
            let sets = try await apiService.searchSetsByName(searchText)
            
            if sets.isEmpty {
                errorMessage = "No sets found matching '\(searchText)'"
                setSearchResults = []
            } else if sets.count == 1 {
                // Auto-select if only one match
                let setId = sets[0].id
                let fullSet = try await apiService.getSet(id: setId)
                selectedSet = fullSet
                setSearchResults = []
                
                // Show card briefs immediately - no need to fetch full details yet!
                cardBriefResults = fullSet.cards ?? []
                
                if cardBriefResults.isEmpty {
                    errorMessage = "This set has no cards."
                }
            } else {
                // Multiple sets found - show selection list
                setSearchResults = sets
                cardBriefResults = []
                errorMessage = nil
            }
        } catch {
            errorMessage = handleError(error)
            setSearchResults = []
            cardBriefResults = []
        }
    }
    
    private func searchByCardName() async {
        do {
            let cardBriefs = try await apiService.searchCardsByName(searchText)
            
            if cardBriefs.isEmpty {
                errorMessage = "No cards found matching '\(searchText)'"
                cardBriefResults = []
            } else {
                cardBriefResults = Array(cardBriefs.prefix(50)) // Limit to 50 results
            }
        } catch {
            errorMessage = handleError(error)
            cardBriefResults = []
        }
    }
    
    private func searchByCardNumber() async {
        do {
            let pattern = SearchPattern.detect(from: searchText)
            
            guard case .cardNumber(let localId, let total) = pattern else {
                errorMessage = "Invalid card number format. Use format like '25/167' or '25'"
                return
            }
            
            let cardBriefs = try await apiService.searchCardsByNumber(localId: localId, total: total)
            
            if cardBriefs.isEmpty {
                errorMessage = "No cards found with number '\(searchText)'"
                cardBriefResults = []
            } else {
                cardBriefResults = cardBriefs
            }
        } catch {
            errorMessage = handleError(error)
            cardBriefResults = []
        }
    }
    
    func selectSet(_ set: SetBriefAPI) async {
        isSearching = true
        errorMessage = nil
        
        do {
            let fullSet = try await apiService.getSet(id: set.id)
            selectedSet = fullSet
            setSearchResults = []
            
            // Show card briefs immediately - no need to fetch full details yet!
            cardBriefResults = fullSet.cards ?? []
            
            if cardBriefResults.isEmpty {
                errorMessage = "This set has no cards."
            }
        } catch {
            errorMessage = handleError(error)
            cardBriefResults = []
        }
        
        isSearching = false
    }
    
    // MARK: - Bulk Selection
    
    func toggleCardSelection(_ cardId: String) {
        if selectedCards[cardId] != nil {
            selectedCards.removeValue(forKey: cardId)
        } else {
            selectedCards[cardId] = 1
        }
    }
    
    func updateCardQuantity(_ cardId: String, quantity: Int) {
        if quantity > 0 {
            selectedCards[cardId] = quantity
        } else {
            selectedCards.removeValue(forKey: cardId)
        }
    }
    
    func isCardSelected(_ cardId: String) -> Bool {
        selectedCards[cardId] != nil
    }
    
    func getSelectedQuantity(_ cardId: String) -> Int {
        selectedCards[cardId] ?? 0
    }
    
    var selectedCardsCount: Int {
        selectedCards.values.reduce(0, +)
    }
    
    var hasSelectedCards: Bool {
        !selectedCards.isEmpty
    }
    
    // MARK: - Card Management
    
    func addSelectedCardsToCollection() async {
        print("🎯 Starting to add \(selectedCards.count) cards to collection")
        
        var successCount = 0
        var failCount = 0
        
        // Now fetch full details only for selected cards
        for (cardId, quantity) in selectedCards {
            print("📦 Fetching full details for card: \(cardId) (quantity: \(quantity))")
            
            do {
                let fullCard = try await apiService.getCard(id: cardId)
                print("✅ Got full card data for: \(fullCard.name)")
//                #if DEBUG
//                print(fullCard.)
                
                addCardToCollection(fullCard, quantity: quantity)
                successCount += 1
                print("✅ Successfully added \(fullCard.name) x\(quantity) to collection")
                
            } catch {
                failCount += 1
                print("❌ Failed to fetch full details for card \(cardId): \(error)")
                errorMessage = "Some cards failed to add. Please try again."
            }
        }
        
        print("📊 Final results: \(successCount) succeeded, \(failCount) failed")
        
        // Clear selections after adding
        selectedCards.removeAll()
    }
    
    private func addCardToCollection(_ apiCard: CardAPIResponse, quantity: Int = 1) {
        print("💾 Adding card to collection: \(apiCard.name) x\(quantity)")
        
        // Check if card already exists
        let descriptor = FetchDescriptor<Card>(
            predicate: #Predicate { card in
                card.id == apiCard.id
            }
        )
        
        do {
            let existingCards = try modelContext.fetch(descriptor)
            print("🔍 Found \(existingCards.count) existing cards with id: \(apiCard.id)")
            
            if let existingCard = existingCards.first {
                // Update quantity
                let oldQuantity = existingCard.quantityOwned
                existingCard.quantityOwned += quantity
                print("📝 Updated existing card quantity: \(oldQuantity) -> \(existingCard.quantityOwned)")
            } else {
                // Add new card
                print("🆕 Creating new card: \(apiCard.name)")
                let card = APIMapper.mapToCard(from: apiCard, quantityOwned: quantity)
                print("✅ Card created with id: \(card.id), name: \(card.name), quantity: \(card.quantityOwned)")
                modelContext.insert(card)
                print("✅ Card inserted into context")
            }
            
            print("💾 Saving context...")
            try modelContext.save()
            print("✅ Context saved successfully!")
            
        } catch {
            print("❌ Failed to add card: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            errorMessage = "Failed to add card: \(error.localizedDescription)"
        }
    }
    
    func isCardInCollection(_ cardId: String) -> Bool {
        let descriptor = FetchDescriptor<Card>(
            predicate: #Predicate { card in
                card.id == cardId
            }
        )
        
        do {
            let cards = try modelContext.fetch(descriptor)
            return !cards.isEmpty
        } catch {
            return false
        }
    }
    
    func getCardQuantity(_ cardId: String) -> Int {
        let descriptor = FetchDescriptor<Card>(
            predicate: #Predicate { card in
                card.id == cardId
            }
        )
        
        do {
            let cards = try modelContext.fetch(descriptor)
            return cards.first?.quantityOwned ?? 0
        } catch {
            return 0
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleError(_ error: Error) -> String {
        if let apiError = error as? APIError {
            return apiError.localizedDescription
        }
        return "An unexpected error occurred: \(error.localizedDescription)"
    }
    
    func clearSearch() {
        searchText = ""
        cardBriefResults = []
        setSearchResults = []
        selectedSet = nil
        errorMessage = nil
        selectedCards.removeAll()
    }
    
    func clearSelections() {
        selectedCards.removeAll()
    }
}
