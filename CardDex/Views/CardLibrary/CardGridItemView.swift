//
//  CardGridItemView.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//


import SwiftUI

struct CardGridItemView: View {
    let card: Card
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Card Image
            CachedAsyncImage(url: card.displayImage) { image in
                image
                    .resizable()
                    .aspectRatio(AppConstants.UI.cardAspectRatio, contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(LinearGradient.shimmer)
                    .aspectRatio(AppConstants.UI.cardAspectRatio, contentMode: .fit)
                    .shimmer()
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: Color.cardShadow, radius: 3, x: 0, y: 2)
            
            // Card Info
            VStack(alignment: .leading, spacing: 4) {
                Text(card.name)
                    .font(.caption.bold())
                    .lineLimit(1)
                
                HStack {
                    Text(card.setName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if card.quantityOwned > 1 {
                        Text("×\(card.quantityOwned)")
                            .font(.caption2.bold())
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
        .cardAppearance()
    }
}

#Preview {
    CardGridItemView(
        card: Card(
            id: "base1-4",
            name: "Charizard",
            supertype: "Pokémon",
            setID: "base1",
            setName: "Base Set",
            number: "4",
            quantityOwned: 2
        )
    )
    .frame(width: 150)
    .padding()
}
