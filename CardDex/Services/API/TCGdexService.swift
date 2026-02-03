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
    func searchCardsByNumber(localId: String, total: String? = nil) async throws -> [CardBriefAPI] {
        // Get all cards and filter by localId
        let allCards = try await getAllCards()
        
        var filtered = allCards.filter { $0.localId == localId }
        
        // If total is provided, further filter by set's official count
        if let total = total, let totalInt = Int(total) {
            // We'd need to fetch set info to match, for now just return the localId matches
            return filtered
        }
        
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
    
    /// Get full card details for cards in a set
    func getFullCardsFromSet(_ setId: String) async throws -> [CardAPIResponse] {
        let cardBriefs = try await getCardsFromSet(setId)
        
        // Fetch full details for each card
        var fullCards: [CardAPIResponse] = []
        
        for brief in cardBriefs {
            do {
                let fullCard = try await getCard(id: brief.id)
                fullCards.append(fullCard)
            } catch {
                // Continue if one card fails
                print("Failed to fetch card \(brief.id): \(error)")
            }
        }
        
        return fullCards
    }
    
    // MARK: - Smart Search
    
    /// Smart search that detects search type and returns appropriate results
    func smartSearch(_ query: String) async throws -> SmartSearchResult {
        let pattern = SearchPattern.detect(from: query)
        
        switch pattern {
        case .cardNumber(let localId, let total):
            let cards = try await searchCardsByNumber(localId: localId, total: total)
            return .cards(cards)
            
        case .cardName(let name):
            // Try as set name first
            let sets = try await searchSetsByName(name)
            if !sets.isEmpty {
                return .sets(sets)
            }
            
            // Fall back to card name search
            let cards = try await searchCardsByName(name)
            return .cards(cards)
            
        case .setName(let name):
            let sets = try await searchSetsByName(name)
            return .sets(sets)
        }
    }
    
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

// MARK: - Smart Search Result
enum SmartSearchResult {
    case cards([CardBriefAPI])
    case sets([SetBriefAPI])
}
