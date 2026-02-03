//
//  CardRowView.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//


import SwiftUI

struct CardRowView: View {
    let card: Card
    
    var body: some View {
        HStack(spacing: 12) {
            // Card Image
            CachedAsyncImage(url: card.imageSmall ?? "") { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay {
                        ProgressView()
                    }
            }
            .frame(width: 60, height: 84)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(radius: 2)
            
            // Card Info
            VStack(alignment: .leading, spacing: 4) {
                Text(card.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    // Type badges
                    if let types = card.types {
                        ForEach(types, id: \.self) { type in
                            TypeBadgeView(type: type)
                        }
                    }
                }
                
                HStack {
                    Text(card.setName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .foregroundStyle(.secondary)
                    
                    Text("#\(card.number)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if let rarity = card.rarity {
                        Text("•")
                            .foregroundStyle(.secondary)
                        
                        Text(rarity)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Quantity
            VStack {
                Text("×\(card.quantityOwned)")
                    .font(.title3.bold())
                    .foregroundStyle(.blue)
                
                Text("owned")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    CardRowView(
        card: Card(
            id: "base1-4",
            name: "Charizard",
            supertype: "Pokémon",
            types: ["Fire"],
            setID: "base1",
            setName: "Base Set",
            number: "4",
            rarity: "Rare Holo",
            quantityOwned: 2
        )
    )
    .padding()
}
