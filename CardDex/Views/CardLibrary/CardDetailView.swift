//
//  CardDetailView.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//

import SwiftUI
import SwiftData

struct CardDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let card: Card
    @State private var showingDeleteAlert = false
    @State private var quantity: Int
    
    init(card: Card) {
        self.card = card
        _quantity = State(initialValue: card.quantityOwned)
        
        // Debug: Log what data we have
        print("🔍 CardDetailView loaded for: \(card.name)")
        print("  - ID: \(card.id)")
        print("  - Supertype: \(card.supertype)")
        print("  - HP: \(card.hp ?? "nil")")
        print("  - Types: \(card.types?.joined(separator: ", ") ?? "nil")")
        print("  - Evolves From: \(card.evolvesFrom ?? "nil")")
        print("  - Ability: \(card.ability?.name ?? "nil")")
        print("  - Attacks: \(card.attacks?.count ?? 0)")
        if let attacks = card.attacks {
            for attack in attacks {
                print("    • \(attack.name): \(attack.displayDamage)")
            }
        }
        print("  - Weaknesses: \(card.weaknesses?.count ?? 0)")
        print("  - Resistances: \(card.resistances?.count ?? 0)")
        print("  - Retreat Cost: \(card.retreatCost?.count ?? 0)")
        print("  - Effect: \(card.effect ?? "nil")")
        print("  - Trainer Type: \(card.trainerType ?? "nil")")
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Card Image
                    CachedAsyncImage(url: card.displayImage) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .aspectRatio(AppConstants.UI.cardAspectRatio, contentMode: .fit)
                            .overlay {
                                ProgressView()
                            }
                    }
                    .frame(maxWidth: 400)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 12)
                    
                    // Card Information
                    VStack(spacing: 20) {
                        // Basic Info
                        basicInfo
                        
                        // Quantity Stepper
                        quantitySection
                        
                        // Pokemon-specific info
                        if card.isPokemon {
                            pokemonInfo
                        }
                        
                        // Trainer-specific info
                        if card.isTrainer {
                            trainerInfo
                        }
                        
                        // Energy-specific info
                        if card.isEnergy {
                            energyInfo
                        }
                        
                        // Set Info
                        setInfo
                        
                        // Artist Info
                        if let artist = card.artist {
                            artistInfo(artist: artist)
                        }
                        
                        // Deck Usage
                        deckUsageSection
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle(card.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        saveChanges()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
            .alert("Delete Card?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteCard()
                }
            } message: {
                Text("Are you sure you want to remove \(card.name) from your collection?")
            }
        }
    }
    
    // MARK: - View Components
    
    private var basicInfo: some View {
        VStack(spacing: 12) {
            HStack {
                Text(card.name)
                    .font(.title.bold())
                
                Spacer()
            }
            
            HStack {
                if let types = card.types {
                    ForEach(types.indices, id: \.self) { index in
                        TypeBadgeView(type: types[index], size: .large)
                            .id("\(card.id)-type-\(index)")
                    }
                }
                
                Spacer()
                
                if let hp = card.hp {
                    Text("\(hp) HP")
                        .font(.title2.bold())
                        .foregroundStyle(.red)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var quantitySection: some View {
        HStack {
            Text("Quantity Owned")
                .font(.headline)
            
            Spacer()
            
            HStack {
                Button {
                    if quantity > 0 {
                        quantity -= 1
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                }
                .disabled(quantity <= 0)
                
                Text("\(quantity)")
                    .font(.title3.bold())
                    .frame(minWidth: 40)
                
                Button {
                    quantity += 1
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var pokemonInfo: some View {
        VStack(spacing: 16) {
            // Always show a header to confirm this section is rendering
            Text("Pokémon Details")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Evolution
            if let evolvesFrom = card.evolvesFrom {
                InfoRow(label: "Evolves From", value: evolvesFrom)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
            
            // Ability
            if let ability = card.ability {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ability: \(ability.type)")
                        .font(.subheadline.bold())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ability.name)
                            .font(.subheadline.bold())
                        Text(ability.text)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.purple.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }
            }
            
            // Attacks
            if let attacks = card.attacks, !attacks.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Attacks (\(attacks.count))")
                        .font(.subheadline.bold())
                    
                    ForEach(attacks, id: \.name) { attack in
                        AttackView(attack: attack)
                    }
                }
            }
            
            // Weakness & Resistance
            if card.weaknesses != nil || card.resistances != nil {
                HStack(spacing: 12) {
                    if let weaknesses = card.weaknesses, !weaknesses.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Weakness")
                                .font(.caption.bold())
                            HStack {
                                ForEach(weaknesses.indices, id: \.self) { index in
                                    TypeBadgeView(type: weaknesses[index].type, size: .small)
                                        .id("\(card.id)-weakness-\(index)")
                                    Text(weaknesses[index].value)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    
                    if let resistances = card.resistances, !resistances.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Resistance")
                                .font(.caption.bold())
                            HStack {
                                ForEach(resistances.indices, id: \.self) { index in
                                    TypeBadgeView(type: resistances[index].type, size: .small)
                                        .id("\(card.id)-resistance-\(index)")
                                    Text(resistances[index].value)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            
            // Retreat Cost
            if let retreatCost = card.retreatCost, !retreatCost.isEmpty {
                InfoRow(label: "Retreat Cost", value: "\(retreatCost.count)")
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var trainerInfo: some View {
        VStack(spacing: 16) {
            // Always show a header to confirm this section is rendering
            Text("Trainer Card Details")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Trainer Type
            if let trainerType = card.trainerType {
                InfoRow(label: "Card Type", value: trainerType)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
            
            // Effect
            if let effect = card.effect {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Effect")
                        .font(.subheadline.bold())
                    
                    Text(effect)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(Color.orange.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var energyInfo: some View {
        VStack(spacing: 16) {
            // Always show a header to confirm this section is rendering
            Text("Energy Card Details")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Effect
            if let effect = card.effect {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Effect")
                        .font(.subheadline.bold())
                    
                    Text(effect)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.yellow.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(Color.yellow.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var setInfo: some View {
        VStack(spacing: 8) {
            InfoRow(label: "Set", value: card.setName)
            InfoRow(label: "Number", value: card.number)
            if let rarity = card.rarity {
                InfoRow(label: "Rarity", value: rarity)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func artistInfo(artist: String) -> some View {
        InfoRow(label: "Artist", value: artist)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var deckUsageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Deck Usage")
                .font(.headline)
            
            if let deckCards = card.deckCards, !deckCards.isEmpty {
                ForEach(deckCards, id: \.deck?.id) { deckCard in
                    if let deck = deckCard.deck {
                        HStack {
                            Text(deck.name)
                            Spacer()
                            Text("×\(deckCard.quantity)")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    }
                }
            } else {
                Text("Not in any decks")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Actions
    
    private func saveChanges() {
        card.quantityOwned = quantity
        try? modelContext.save()
    }
    
    private func deleteCard() {
        modelContext.delete(card)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Helper Views

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

struct AttackView: View {
    let attack: Attack
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(attack.name)
                    .font(.subheadline.bold())
                
                Spacer()
                
                Text(attack.displayDamage)
                    .font(.subheadline.bold())
                    .foregroundStyle(.red)
            }
            
            if let cost = attack.cost, !cost.isEmpty {
                HStack(spacing: 4) {
                    ForEach(cost.indices, id: \.self) { index in
                        TypeBadgeView(type: cost[index], size: .small)
                            .id("\(attack.name)-energy-\(index)")
                    }
                }
            }
            
            if let text = attack.text {
                Text(text)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    CardDetailView(
        card: Card(
            id: "base1-4",
            name: "Charizard",
            supertype: "Pokémon",
            hp: "120",
            types: ["Fire"],
            setID: "base1",
            setName: "Base Set",
            number: "4",
            rarity: "Rare Holo",
            quantityOwned: 2
        )
    )
    .modelContainer(for: [Card.self], inMemory: true)
}
