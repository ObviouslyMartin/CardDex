//
//  CardGridView.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//


import SwiftUI

struct CardGridView: View {
    let cards: [Card]
    let onCardTap: (Card) -> Void
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private var columns: [GridItem] {
        let columnCount: Int
        
        if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            // iPad
            columnCount = UIDevice.current.orientation.isLandscape ?
                AppConstants.UI.GridColumns.padLandscape :
                AppConstants.UI.GridColumns.padPortrait
        } else {
            // iPhone
            columnCount = UIDevice.current.orientation.isLandscape ?
                AppConstants.UI.GridColumns.phoneLandscape :
                AppConstants.UI.GridColumns.phonePortrait
        }
        
        return Array(repeating: GridItem(.flexible(), spacing: AppConstants.UI.gridSpacing), count: columnCount)
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: AppConstants.UI.gridSpacing) {
            ForEach(cards, id: \.id) { card in
                Button {
                    HapticFeedback.light()
                    onCardTap(card)
                } label: {
                    CardGridItemView(card: card)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    ScrollView {
        CardGridView(cards: [], onCardTap: { _ in })
            .padding()
    }
}
