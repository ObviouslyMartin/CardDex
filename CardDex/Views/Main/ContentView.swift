//
//  CardRowView.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
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
            
            DeckListView()
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
