//
//  DeckDetailView.swift
//  CardDex
//
//  Created by Martin Plut on 2/2/26.
//

import SwiftUI
import SwiftData

struct DeckDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let deck: Deck
    @State private var showingEditDeck = false
    @State private var showingDeckBuilder = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with deck info
                deckHeader
                
                // Deck statistics
                deckStats
                
                // Card type breakdown
                cardTypeBreakdown
                
                // Deck validation
                deckValidation
                
                // Cards list
                cardsList
            }
            .padding()
        }
        .navigationTitle(deck.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        HapticFeedback.light()
                        showingDeckBuilder = true
                    } label: {
                        Label("Edit Deck", systemImage: "pencil")
                    }
                    
                    Button {
                        HapticFeedback.light()
                        showingEditDeck = true
                    } label: {
                        Label("Deck Info", systemImage: "info.circle")
                    }
                    
                    Divider()
                    
                    Button {
                        HapticFeedback.light()
                        exportDeckList()
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditDeck) {
            EditDeckInfoView(deck: deck)
        }
        .sheet(isPresented: $showingDeckBuilder) {
            NavigationStack {
                DeckBuilderView(deck: deck)
            }
        }
    }
    
    // MARK: - View Components
    
    private var deckHeader: some View {
        VStack(spacing: 8) {
            if let description = deck.deckDescription {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            HStack {
                Text("Created \(deck.createdAt.formatted(date: .abbreviated, time: .omitted))")
                Text("•")
                Text("Modified \(deck.updatedAt.formatted(date: .abbreviated, time: .omitted))")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var deckStats: some View {
        HStack(spacing: 16) {
            StatColumn(
                title: "Total",
                value: "\(deck.totalCards)/60",
                color: deck.isValid ? .green : .orange
            )
            
            Divider()
            
            StatColumn(
                title: "Pokémon",
                value: "\(deck.pokemonCount)",
                color: .blue
            )
            
            Divider()
            
            StatColumn(
                title: "Trainers",
                value: "\(deck.trainerCount)",
                color: .purple
            )
            
            Divider()
            
            StatColumn(
                title: "Energy",
                value: "\(deck.energyCount)",
                color: .yellow
            )
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var cardTypeBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Type Distribution")
                .font(.headline)
            
            let energyTypes = deck.energyTypes
            if !energyTypes.isEmpty {
                VStack(spacing: 8) {
                    ForEach(energyTypes.sorted(by: { $0.value > $1.value }), id: \.key) { type, count in
                        HStack {
                            TypeBadgeView(type: type, size: .medium)
                            Text(type)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("\(count)")
                                .font(.subheadline.bold())
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } else {
                Text("No type distribution available")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var deckValidation: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: deck.isValid ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(deck.isValid ? .green : .orange)
                
                Text(deck.isValid ? "Deck is Valid" : "Deck Incomplete")
                    .font(.headline)
            }
            
            if !deck.isValid {
                if deck.hasTooManyCards {
                    Label("Remove \(deck.totalCards - 60) cards", systemImage: "minus.circle")
                        .font(.caption)
                        .foregroundStyle(.red)
                } else {
                    Label("Add \(deck.needsMoreCards) more cards", systemImage: "plus.circle")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background((deck.isValid ? Color.green : Color.orange).opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var cardsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Cards (\(deck.uniqueCards))")
                    .font(.headline)
                
                Spacer()
                
                if deck.uniqueCards > 0 {
                    Button {
                        showingDeckBuilder = true
                    } label: {
                        Text("Edit")
                            .font(.caption)
                    }
                }
            }
            
            if let deckCards = deck.deckCards, !deckCards.isEmpty {
                VStack(spacing: 8) {
                    ForEach(deckCards.sorted(by: { ($0.card?.name ?? "") < ($1.card?.name ?? "") }), id: \.id) { deckCard in
                        if let card = deckCard.card {
                            DeckCardRowView(card: card, quantity: deckCard.quantity)
                        }
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "square.stack.3d.up.slash")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    
                    Text("No cards in deck yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Button {
                        showingDeckBuilder = true
                    } label: {
                        Label("Add Cards", systemImage: "plus")
                            .font(.subheadline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 8))
                            .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
            
            // Basic energies section
            if let basicEnergies = deck.basicEnergies, !basicEnergies.isEmpty {
                Divider()
                    .padding(.vertical, 8)
                
                Text("Basic Energy (\(String(describing: deck.totalBasicEnergies)))")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 8) {
                    ForEach(basicEnergies.sorted(by: { $0.key < $1.key }), id: \.key) { type, quantity in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.typeColor(for: type).opacity(0.2))
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: energyIcon(for: type))
                                    .font(.caption)
                                    .foregroundStyle(Color.typeColor(for: type))
                            }
                            
                            Text("\(type) Energy")
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("×\(quantity)")
                                .font(.subheadline.bold().monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.typeColor(for: type).opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Actions
    
    private func exportDeckList() {
        var deckList = "\(deck.name)\n"
        if let description = deck.deckDescription {
            deckList += "\(description)\n"
        }
        deckList += "\nTotal: \(deck.totalCards) cards\n\n"
        
        if let deckCards = deck.deckCards {
            let sortedCards = deckCards.sorted { ($0.card?.name ?? "") < ($1.card?.name ?? "") }
            
            // Group by type
            let pokemon = sortedCards.filter { $0.card?.isPokemon == true }
            let trainers = sortedCards.filter { $0.card?.isTrainer == true }
            let energy = sortedCards.filter { $0.card?.isEnergy == true }
            
            if !pokemon.isEmpty {
                deckList += "Pokémon (\(pokemon.reduce(0) { $0 + $1.quantity })):\n"
                for deckCard in pokemon {
                    deckList += "\(deckCard.quantity)x \(deckCard.card?.name ?? "Unknown")\n"
                }
                deckList += "\n"
            }
            
            if !trainers.isEmpty {
                deckList += "Trainers (\(trainers.reduce(0) { $0 + $1.quantity })):\n"
                for deckCard in trainers {
                    deckList += "\(deckCard.quantity)x \(deckCard.card?.name ?? "Unknown")\n"
                }
                deckList += "\n"
            }
            
            if !energy.isEmpty {
                deckList += "Energy (\(energy.reduce(0) { $0 + $1.quantity })):\n"
                for deckCard in energy {
                    deckList += "\(deckCard.quantity)x \(deckCard.card?.name ?? "Unknown")\n"
                }
            }
        }
        
        // Share sheet
        let activityVC = UIActivityViewController(activityItems: [deckList], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func energyIcon(for type: String) -> String {
        switch type.lowercased() {
        case "grass": return "leaf.fill"
        case "fire": return "flame.fill"
        case "water": return "drop.fill"
        case "lightning": return "bolt.fill"
        case "psychic": return "brain.head.profile"
        case "fighting": return "figure.boxing"
        case "darkness": return "moon.fill"
        case "metal": return "shield.fill"
        case "fairy": return "sparkles"
        case "dragon": return "tornado"
        default: return "circle.fill"
        }
    }
}

// MARK: - Supporting Views

struct StatColumn: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct DeckCardRowView: View {
    let card: Card
    let quantity: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Card image thumbnail
            if let imageURL = card.imageSmall {
                CachedAsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(width: 40, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            // Card info
            VStack(alignment: .leading, spacing: 4) {
                Text(card.name)
                    .font(.subheadline.bold())
                
                HStack(spacing: 4) {
                    if let types = card.types {
                        ForEach(Array(types.prefix(2)).indices, id: \.self) { index in
                            let type = Array(types.prefix(2))[index]
                            TypeBadgeView(type: type, size: .small)
                                .id("\(card.id)-type-\(index)")
                        }
                    }
                }
            }
            
            Spacer()
            
            // Quantity
            Text("×\(quantity)")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct EditDeckInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let deck: Deck
    @State private var deckName: String
    @State private var deckDescription: String
    
    init(deck: Deck) {
        self.deck = deck
        _deckName = State(initialValue: deck.name)
        _deckDescription = State(initialValue: deck.deckDescription ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Deck Name") {
                    TextField("Name", text: $deckName)
                }
                
                Section("Description") {
                    TextField("Description (Optional)", text: $deckDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Deck Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveDeck()
                    }
                    .disabled(deckName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func saveDeck() {
        deck.name = deckName.trimmingCharacters(in: .whitespaces)
        let trimmedDesc = deckDescription.trimmingCharacters(in: .whitespaces)
        deck.deckDescription = trimmedDesc.isEmpty ? nil : trimmedDesc
        deck.updatedAt = Date()
        
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    NavigationStack {
        DeckDetailView(deck: Deck(name: "Fire Deck", deckDescription: "A powerful fire-type deck"))
    }
    .modelContainer(for: [Deck.self, Card.self, DeckCard.self], inMemory: true)
}
