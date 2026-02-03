//
//  CardSet.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//


import Foundation
import SwiftData

@Model
final class CardSet {
    var id: String
    var name: String
    var series: String
    var printedTotal: Int
    var total: Int
    var releaseDate: String
    var updatedAt: String?
    var logoURL: String?
    var symbolURL: String?
    
    @Relationship(deleteRule: .nullify)
    var cards: [Card]?
    
    init(
        id: String,
        name: String,
        series: String,
        printedTotal: Int,
        total: Int,
        releaseDate: String,
        updatedAt: String? = nil,
        logoURL: String? = nil,
        symbolURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.series = series
        self.printedTotal = printedTotal
        self.total = total
        self.releaseDate = releaseDate
        self.updatedAt = updatedAt
        self.logoURL = logoURL
        self.symbolURL = symbolURL
    }
}

// MARK: - Computed Properties
extension CardSet {
    var ownedCardsCount: Int {
        cards?.filter { $0.quantityOwned > 0 }.count ?? 0
    }
    
    var completionPercentage: Double {
        guard total > 0 else { return 0 }
        return Double(ownedCardsCount) / Double(total) * 100
    }
    
    var isComplete: Bool {
        ownedCardsCount == total
    }
    
    var displayImage: String {
        logoURL ?? symbolURL ?? ""
    }
}
