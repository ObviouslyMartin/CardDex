//
//  APIError.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//


import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)
    case noData
    case rateLimitExceeded
    case unauthorized
    case notFound
    case serverError
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .invalidResponse:
            return "The server response was invalid."
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .noData:
            return "No data received from the server."
        case .rateLimitExceeded:
            return "API rate limit exceeded. Please try again later."
        case .unauthorized:
            return "Unauthorized. Please check your API key."
        case .notFound:
            return "The requested resource was not found."
        case .serverError:
            return "Server error occurred. Please try again later."
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidURL:
            return "Please check the URL and try again."
        case .invalidResponse, .noData:
            return "Please try again."
        case .httpError(let statusCode) where statusCode >= 500:
            return "The server is experiencing issues. Please try again later."
        case .networkError:
            return "Please check your internet connection and try again."
        case .rateLimitExceeded:
            return "Wait a moment before making another request."
        case .unauthorized:
            return "Verify your API credentials."
        case .notFound:
            return "The card or set may no longer exist."
        default:
            return "Please try again."
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .networkError, .rateLimitExceeded, .serverError:
            return true
        case .httpError(let code):
            return code >= 500 || code == 429
        default:
            return false
        }
    }
}

// MARK: - Error Creation Helpers
extension APIError {
    static func from(statusCode: Int) -> APIError {
        switch statusCode {
        case 401:
            return .unauthorized
        case 404:
            return .notFound
        case 429:
            return .rateLimitExceeded
        case 500...599:
            return .serverError
        default:
            return .httpError(statusCode: statusCode)
        }
    }
    
    static func from(error: Error) -> APIError {
        if let apiError = error as? APIError {
            return apiError
        }
        
        if let urlError = error as? URLError {
            return .networkError(urlError)
        }
        
        return .unknown(error)
    }
}
