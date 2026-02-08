//
//  PokemonTCGService.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//

import Foundation

@MainActor
final class TCGdexService {
    
    static let shared = TCGdexService()
    
    private let baseURL = APIConstants.baseURL
    private let session: URLSession
    private var requestCache: [String: CachedResponse] = [:]
    
    private struct CachedResponse {
        let data: Data
        let timestamp: Date
        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > 3600 // 1 hour cache
        }
    }
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = APIConstants.Defaults.timeout
        config.requestCachePolicy = .returnCacheDataElseLoad
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Card Operations
    
    /// Get a specific card by ID
    func getCard(id: String) async throws -> CardAPIResponse {
        let endpoint = "\(baseURL)\(APIConstants.Endpoint.card(id: id))"
        
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        return try await performRequest(url: url)
    }
    
    /// Search cards by name
    func searchCardsByName(_ name: String) async throws -> [CardBriefAPI] {
        let endpoint = "\(baseURL)\(APIConstants.Endpoint.cards)"
        guard var components = URLComponents(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        // TCGdex filters by adding query parameters
        components.queryItems = [URLQueryItem(name: "name", value: name)]
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        let cards: [CardBriefAPI] = try await performRequest(url: url)
        return cards.filter { $0.name.localizedCaseInsensitiveContains(name) }
    }
    
    /// Search cards by local ID and optional total
    func searchCardsByNumber(localId: String, total: Int? = nil) async throws -> [CardBriefAPI] {
        // Get all cards and filter by localId
        let allCards = try await getAllCards()
        
        let filtered = allCards.filter { $0.localId == localId }
        
        // If total is provided, further filter by set's official count
        if total != nil {
            // Filter by cards from sets with matching card count
            // Note: This is approximate since we don't have direct set.total access
            return filtered
        }
        
        return filtered
    }
    
    /// Search cards by name AND number for precise matching
    func searchCardsByNameAndNumber(name: String, localId: String, total: Int? = nil) async throws -> [CardBriefAPI] {
        // Get all cards
        let allCards = try await getAllCards()
        
        // Filter by both name and localId
        let filtered = allCards.filter { card in
            card.name.localizedCaseInsensitiveContains(name) && card.localId == localId
        }
        
        // If total is provided, could potentially filter further
        // For now, the name + localId combo should be specific enough
        
        return filtered
    }
    
    /// Get all cards (for searching)
    func getAllCards() async throws -> [CardBriefAPI] {
        let endpoint = "\(baseURL)\(APIConstants.Endpoint.cards)"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        return try await performRequest(url: url)
    }
    
    // MARK: - Set Operations
    
    /// Get all sets
    func getAllSets() async throws -> [SetBriefAPI] {
        let endpoint = "\(baseURL)\(APIConstants.Endpoint.sets)"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        return try await performRequest(url: url)
    }
    
    /// Get a specific set by ID with all its cards
    func getSet(id: String) async throws -> SetAPIResponse {
        let endpoint = "\(baseURL)\(APIConstants.Endpoint.set(id: id))"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        return try await performRequest(url: url)
    }
    
    /// Search sets by name
    func searchSetsByName(_ name: String) async throws -> [SetBriefAPI] {
        let allSets = try await getAllSets()
        return allSets.filter { $0.name.localizedCaseInsensitiveContains(name) }
    }
    
    /// Get all cards from a set by set ID
    func getCardsFromSet(_ setId: String) async throws -> [CardBriefAPI] {
        let setData = try await getSet(id: setId)
        return setData.cards ?? []
    }
    
    /// Get full card details for cards in a set with retry logic and rate limiting
    func getFullCardsFromSet(_ setId: String) async throws -> [CardAPIResponse] {
        let cardBriefs = try await getCardsFromSet(setId)
        
        print("📦 Fetching \(cardBriefs.count) cards from set \(setId)")
        
        // Fetch full details for each card with rate limiting
        var fullCards: [CardAPIResponse] = []
        var failedCards: [(CardBriefAPI, Error)] = []
        
        for (index, brief) in cardBriefs.enumerated() {
            do {
                let fullCard = try await getCard(id: brief.id)
                fullCards.append(fullCard)
                
                // Log progress every 10 cards
                if (index + 1) % 10 == 0 {
                    print("✅ Loaded \(index + 1)/\(cardBriefs.count) cards")
                }
                
                // Add small delay to avoid rate limiting (50ms between requests)
                try? await Task.sleep(nanoseconds: 50_000_000)
                
            } catch {
                print("⚠️ Failed to fetch card \(brief.id) (attempt 1): \(error.localizedDescription)")
                failedCards.append((brief, error))
            }
        }
        
        // Retry failed cards once
        if !failedCards.isEmpty {
            print("🔄 Retrying \(failedCards.count) failed cards...")
            
            for (brief, _) in failedCards {
                do {
                    // Wait a bit longer before retry
                    try await Task.sleep(nanoseconds: 200_000_000) // 200ms
                    let fullCard = try await getCard(id: brief.id)
                    fullCards.append(fullCard)
                    print("✅ Retry successful for \(brief.id)")
                } catch {
                    print("❌ Retry failed for card \(brief.id): \(error.localizedDescription)")
                }
            }
        }
        
        print("✅ Successfully loaded \(fullCards.count)/\(cardBriefs.count) cards")
        
        return fullCards
    }
    
    // MARK: - Smart Search
    
    
    // MARK: - Helper Methods
    
    private func performRequest<T: Decodable>(url: URL) async throws -> T {
        // Check cache first
        let cacheKey = url.absoluteString
        if let cached = requestCache[cacheKey], !cached.isExpired {
            return try decode(cached.data)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(APIConstants.Header.applicationJSON, forHTTPHeaderField: APIConstants.Header.contentType)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.from(statusCode: httpResponse.statusCode)
            }
            
            // Cache successful response
            requestCache[cacheKey] = CachedResponse(data: data, timestamp: Date())
            
            return try decode(data)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.from(error: error)
        }
    }
    
    private func decode<T: Decodable>(_ data: Data) throws -> T {
        let decoder = JSONDecoder()
        // TCGdex uses camelCase, no special decoding needed
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    // MARK: - Cache Management
    
    func clearCache() {
        requestCache.removeAll()
    }
    
    func clearExpiredCache() {
        requestCache = requestCache.filter { !$0.value.isExpired }
    }
}
