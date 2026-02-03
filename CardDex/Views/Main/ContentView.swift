//
//  ContentView.swift
//  CardDex
//
//  Created by Martin
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            CardLibraryView()
                .tabItem {
                    Label("Collection", systemImage: "rectangle.stack")
                }
            
            // Placeholder for future tabs
            Text("Decks Coming Soon")
                .tabItem {
                    Label("Decks", systemImage: "square.stack.3d.up")
                }
            
            Text("Stats Coming Soon")
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Card.self, Deck.self, CardSet.self, DeckCard.self], inMemory: true)
}
