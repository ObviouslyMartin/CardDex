//
//  APIConstants.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//


import Foundation

enum APIConstants {
    static let baseURL = "https://api.tcgdex.net/v2/en"
    
    // MARK: - Endpoints
    enum Endpoint {
        static let cards = "/cards"
        static let sets = "/sets"
        static let series = "/series"
        
        static func card(id: String) -> String {
            "\(cards)/\(id)"
        }
        
        static func set(id: String) -> String {
            "\(sets)/\(id)"
        }
        
        static func serie(id: String) -> String {
            "\(series)/\(id)"
        }
    }
    
    // MARK: - Query Parameters
    enum QueryParam {
        static let name = "name"
        static let hp = "hp"
        static let types = "types"
        static let category = "category"
        static let localId = "localId"
    }
    
    // MARK: - Default Values
    enum Defaults {
        static let timeout: TimeInterval = 30
    }
    
    // MARK: - Headers
    enum Header {
        static let contentType = "Content-Type"
        static let applicationJSON = "application/json"
    }
    
    // MARK: - No API Key Required
    static var apiKey: String? {
        return nil // TCGdex is free and doesn't require authentication
    }
}

// MARK: - Search Pattern Detection
enum SearchPattern {
    case cardNumber(localId: String, total: String?) // "25" or "25/167"
    case setName(String)
    case cardName(String)
    
    static func detect(from input: String) -> SearchPattern {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        
        // Check for card number format: "25/167"
        if trimmed.contains("/") {
            let parts = trimmed.split(separator: "/")
            if parts.count == 2,
               let localId = parts.first?.trimmingCharacters(in: .whitespaces),
               let total = parts.last?.trimmingCharacters(in: .whitespaces),
               !localId.isEmpty,
               !total.isEmpty {
                return .cardNumber(localId: localId, total: total)
            }
        }
        
        // Check if it's just a number (potential localId)
        if Int(trimmed) != nil {
            return .cardNumber(localId: trimmed, total: nil)
        }
        
        // Default to text search - we'll determine if it's a set name or card name contextually
        return .cardName(trimmed)
    }
}

