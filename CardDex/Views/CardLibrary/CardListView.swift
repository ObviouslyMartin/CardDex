//
//  CardListView.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//


import SwiftUI

struct CardListView: View {
    let cards: [Card]
    let onCardTap: (Card) -> Void
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(cards, id: \.id) { card in
                Button {
                    HapticFeedback.light()
                    onCardTap(card)
                } label: {
                    CardRowView(card: card)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    ScrollView {
        CardListView(cards: [], onCardTap: { _ in })
            .padding()
    }
}
