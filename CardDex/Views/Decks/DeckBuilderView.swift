//
//  DeckBuilderView.swift
//  CardDex
//
//  Created by Martin Plut on 2/2/26.
//

import SwiftUI
import SwiftData

struct DeckBuilderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let deck: Deck
    @State private var viewModel: DeckBuilderViewModel?
    @State private var showingFilters = false
    @State private var selectedTab: BuilderTab = .collection
    
    enum BuilderTab {
        case collection
        case deck
    }
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                contentView(viewModel: viewModel)
            } else {
                ProgressView()
                    .onAppear {
                        viewModel = DeckBuilderViewModel(modelContext: modelContext, deck: deck)
                    }
            }
        }
    }
    
    @ViewBuilder
    private func contentView(viewModel: DeckBuilderViewModel) -> some View {
        VStack(spacing: 0) {
            // Status bar
            statusBar(viewModel: viewModel)
            
            // Tab picker
            Picker("View", selection: $selectedTab) {
                Text("Collection").tag(BuilderTab.collection)
                Text("Deck (\(viewModel.uniqueCards))").tag(BuilderTab.deck)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Content based on selected tab
            if selectedTab == .collection {
                collectionView(viewModel: viewModel)
            } else {
                deckView(viewModel: viewModel)
            }
        }
        .navigationTitle(deck.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
            
            if selectedTab == .collection {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingFilters = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingFilters) {
            FilterSheet(viewModel: viewModel)
        }
    }
    
    // MARK: - Status Bar
    
    @ViewBuilder
    private func statusBar(viewModel: DeckBuilderViewModel) -> some View {
        VStack(spacing: 8) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                    
                    // Progress
                    Rectangle()
                        .fill(viewModel.statusColor)
                        .frame(width: geometry.size.width * (CGFloat(viewModel.totalCards) / 60.0))
                }
            }
            .frame(height: 8)
            .clipShape(Capsule())
            
            // Status message
            HStack {
                Text(viewModel.statusMessage)
                    .font(.caption.bold())
                    .foregroundStyle(viewModel.statusColor)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Label("\(viewModel.pokemonCount)", systemImage: "p.circle.fill")
                        .foregroundStyle(.blue)
                    Label("\(viewModel.trainerCount)", systemImage: "t.circle.fill")
                        .foregroundStyle(.purple)
                    Label("\(viewModel.energyCount)", systemImage: "bolt.fill")
                        .foregroundStyle(.yellow)
                }
                .font(.caption)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Collection View
    
    @ViewBuilder
    private func collectionView(viewModel: DeckBuilderViewModel) -> some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search cards", text: Binding(
                    get: { viewModel.searchText },
                    set: { viewModel.searchText = $0 }
                ))
            }
            .padding()
            .background(.ultraThinMaterial)
            
            if viewModel.filteredCards.isEmpty {
                emptyCollectionContent(viewModel: viewModel)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.filteredCards) { card in
                            CollectionCardRow(
                                card: card,
                                quantityInDeck: viewModel.cardQuantityInDeck(card),
                                canAdd: viewModel.canAddCard(card),
                                onAdd: { viewModel.addCard(card) }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    @ViewBuilder
    private func emptyCollectionContent(viewModel: DeckBuilderViewModel) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            
            Text("No cards found")
                .font(.headline)
            
            Text("Try adjusting your search or filters")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            if !viewModel.searchText.isEmpty || !viewModel.selectedSupertypes.isEmpty || !viewModel.selectedTypes.isEmpty {
                Button("Clear Filters") {
                    viewModel.clearFilters()
                }
                .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Deck View
    
    @ViewBuilder
    private func deckView(viewModel: DeckBuilderViewModel) -> some View {
        if viewModel.deckCards.isEmpty {
            emptyDeckState
        } else {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.sortDeckCards(by: .name), id: \.id) { deckCard in
                        if let card = deckCard.card {
                            DeckCardEditRow(
                                card: card,
                                quantity: deckCard.quantity,
                                onIncrement: { viewModel.addCard(card, quantity: 1) },
                                onDecrement: { viewModel.removeCard(card, quantity: 1) },
                                onRemove: { viewModel.removeCardCompletely(card) }
                            )
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private var emptyDeckState: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            
            Text("No cards in deck")
                .font(.headline)
            
            Text("Switch to Collection tab to add cards")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Button("Go to Collection") {
                selectedTab = .collection
            }
            .font(.subheadline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Collection Card Row

struct CollectionCardRow: View {
    let card: Card
    let quantityInDeck: Int
    let canAdd: Bool
    let onAdd: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            if let imageURL = card.imageSmall {
                CachedAsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(width: 50, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            // Card info
            VStack(alignment: .leading, spacing: 4) {
                Text(card.name)
                    .font(.subheadline.bold())
                
                HStack(spacing: 4) {
                    if let types = card.types {
                        ForEach(types.prefix(2), id: \.self) { type in
                            TypeBadgeView(type: type, size: .small)
                        }
                    }
                    
                    if let hp = card.hp {
                        Text("\(hp) HP")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Show quantity in deck if any
                if quantityInDeck > 0 {
                    Text("\(quantityInDeck) in deck")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
            
            Spacer()
            
            // Add button
            Button(action: onAdd) {
                Image(systemName: canAdd ? "plus.circle.fill" : "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(canAdd ? .blue : .green)
            }
            .disabled(!canAdd)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Deck Card Edit Row

struct DeckCardEditRow: View {
    let card: Card
    let quantity: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            if let imageURL = card.imageSmall {
                CachedAsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(width: 50, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            // Card info
            VStack(alignment: .leading, spacing: 4) {
                Text(card.name)
                    .font(.subheadline.bold())
                
                HStack(spacing: 4) {
                    if let types = card.types {
                        ForEach(types.prefix(2), id: \.self) { type in
                            TypeBadgeView(type: type, size: .small)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Quantity controls
            HStack(spacing: 12) {
                Button(action: onDecrement) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.orange)
                }
                
                Text("×\(quantity)")
                    .font(.headline)
                    .frame(minWidth: 30)
                
                Button(action: onIncrement) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                }
                .disabled(quantity >= 4)
                
                Button(action: onRemove) {
                    Image(systemName: "trash.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Filter Sheet

struct FilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: DeckBuilderViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Card Type") {
                    ForEach(["Pokémon", "Trainer", "Energy"], id: \.self) { type in
                        Toggle(type, isOn: Binding(
                            get: { viewModel.selectedSupertypes.contains(type) },
                            set: { isSelected in
                                if isSelected {
                                    viewModel.selectedSupertypes.insert(type)
                                } else {
                                    viewModel.selectedSupertypes.remove(type)
                                }
                            }
                        ))
                    }
                }
                
                if !viewModel.selectedSupertypes.isEmpty || !viewModel.selectedTypes.isEmpty {
                    Section {
                        Button("Clear All Filters", role: .destructive) {
                            viewModel.clearFilters()
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DeckBuilderView(deck: Deck(name: "Test Deck"))
    }
    .modelContainer(for: [Deck.self, Card.self, DeckCard.self], inMemory: true)
}
