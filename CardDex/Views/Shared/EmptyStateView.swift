//
//  EmptyStateView.swift
//  CardDex
//
//  Created by Martin Plut on 2/8/26.
//


//
//  EmptyStateView.swift
//  CardDex
//
//  Created by Martin
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let action: EmptyStateAction?
    
    struct EmptyStateAction {
        let title: String
        let action: () -> Void
    }
    
    init(
        icon: String,
        title: String,
        message: String,
        action: EmptyStateAction? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
                .symbolEffect(.bounce, value: icon)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2.bold())
                
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            if let action = action {
                Button(action: action.action) {
                    Label(action.title, systemImage: "plus.circle.fill")
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .bouncyTap()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Presets for Common Empty States

extension EmptyStateView {
    
    /// Empty card collection
    static func emptyCollection(onAdd: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "rectangle.stack.badge.plus",
            title: "No Cards Yet",
            message: "Start building your collection by searching for and adding cards",
            action: EmptyStateAction(title: "Add Cards", action: onAdd)
        )
    }
    
    /// Empty deck list
    static func emptyDecks(onCreate: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "square.stack.3d.up.slash",
            title: "No Decks Yet",
            message: "Create your first deck to start building competitive strategies",
            action: EmptyStateAction(title: "Create Deck", action: onCreate)
        )
    }
    
    /// Empty search results
    static func noSearchResults(query: String) -> EmptyStateView {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No Results",
            message: "No cards found matching '\(query)'. Try a different search term.",
            action: nil
        )
    }
    
    /// Empty filtered results
    static func noFilteredResults(onClear: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "line.3.horizontal.decrease.circle",
            title: "No Matches",
            message: "No cards match your current filters. Try adjusting or clearing them.",
            action: EmptyStateAction(title: "Clear Filters", action: onClear)
        )
    }
    
    /// Network error state
    static func networkError(onRetry: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "wifi.slash",
            title: "Connection Error",
            message: "Unable to connect to the server. Please check your internet connection.",
            action: EmptyStateAction(title: "Try Again", action: onRetry)
        )
    }
    
    /// Generic error state
    static func error(message: String, onRetry: (() -> Void)? = nil) -> EmptyStateView {
        EmptyStateView(
            icon: "exclamationmark.triangle",
            title: "Something Went Wrong",
            message: message,
            action: onRetry.map { EmptyStateAction(title: "Try Again", action: $0) }
        )
    }
}

// MARK: - Preview
#Preview("Empty Collection") {
    EmptyStateView.emptyCollection(onAdd: {})
}

#Preview("Empty Decks") {
    EmptyStateView.emptyDecks(onCreate: {})
}

#Preview("No Search Results") {
    EmptyStateView.noSearchResults(query: "Charizard")
}

#Preview("Network Error") {
    EmptyStateView.networkError(onRetry: {})
}