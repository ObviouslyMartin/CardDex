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
                                availableQuantity: viewModel.availableQuantity(for: card),
                                onAdd: {
                                    HapticFeedback.cardAddedToDeck()
                                    viewModel.addCard(card)
                                }
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
        ScrollView {
            LazyVStack(spacing: 16) {
                // Regular cards section
                if !viewModel.deckCards.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cards")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.sortDeckCards(by: .name), id: \.id) { deckCard in
                            if let card = deckCard.card {
                                DeckCardEditRow(
                                    card: card,
                                    quantity: deckCard.quantity,
                                    canAddMore: viewModel.canAddCard(card),
                                    onIncrement: {
                                        HapticFeedback.light()
                                        viewModel.addCard(card, quantity: 1)
                                    },
                                    onDecrement: {
                                        HapticFeedback.light()
                                        viewModel.removeCard(card, quantity: 1)
                                    },
                                    onRemove: {
                                        HapticFeedback.cardRemovedFromDeck()
                                        viewModel.removeCardCompletely(card)
                                    }
                                )
                            }
                        }
                    }
                }
                
                // Basic energy section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Basic Energy")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text("\(String(describing: deck.totalBasicEnergies)) cards")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    
                    ForEach(BasicEnergy.allTypes, id: \.self) { type in
                        DeckBasicEnergyRow(
                            energyType: type,
                            quantity: viewModel.basicEnergyQuantity(for: type),
                            owned: viewModel.basicEnergyOwned(for: type),
                            available: viewModel.basicEnergyAvailable(for: type),
                            canAddMore: viewModel.canAddBasicEnergy(type: type),
                            onIncrement: {
                                HapticFeedback.light()
                                viewModel.addBasicEnergy(type: type)
                            },
                            onDecrement: {
                                HapticFeedback.light()
                                viewModel.removeBasicEnergy(type: type)
                            },
                            onEdit: { newQuantity in
                                HapticFeedback.light()
                                viewModel.setBasicEnergyQuantity(type: type, quantity: newQuantity)
                            }
                        )
                    }
                }
                
                // Empty state if completely empty
                if viewModel.deckCards.isEmpty && deck.totalBasicEnergies() == 0 {
                    emptyDeckState
                }
            }
            .padding()
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
    let availableQuantity: Int
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
                        ForEach(Array(types.prefix(2)).indices, id: \.self) { index in
                            let type = Array(types.prefix(2))[index]
                            TypeBadgeView(type: type, size: .small)
                                .id("\(card.id)-type-\(index)")
                        }
                    }
                    
                    if let hp = card.hp {
                        Text("\(hp) HP")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if card.isPokemon{
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(card.setName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Show owned and in-deck quantities
                HStack(spacing: 8) {
                    Text("Own: \(card.quantityOwned)")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    
                    if quantityInDeck > 0 {
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("In deck: \(quantityInDeck)")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                    
                    if availableQuantity > 0 {
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Available: \(availableQuantity)")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
            
            Spacer()
            
            // Add button
            Button(action: onAdd) {
                if canAdd {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(quantityInDeck >= 4 ? .green : .gray)
                }
            }
            .disabled(!canAdd)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .opacity(availableQuantity == 0 ? 0.5 : 1.0)
    }
}

// MARK: - Deck Card Edit Row

struct DeckCardEditRow: View {
    let card: Card
    let quantity: Int
    let canAddMore: Bool
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
                        ForEach(Array(types.prefix(2)).indices, id: \.self) { index in
                            let type = Array(types.prefix(2))[index]
                            TypeBadgeView(type: type, size: .small)
                                .id("\(card.id)-type-\(index)")
                        }
                    }
                    if card.isPokemon{
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(card.setName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                
                // Show owned quantity
                Text("Own: \(card.quantityOwned)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
                        .foregroundStyle(canAddMore ? .blue : .gray)
                }
                .disabled(!canAddMore)
                
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

// MARK: - Deck Basic Energy Row

struct DeckBasicEnergyRow: View {
    let energyType: String
    let quantity: Int
    let owned: Int
    let available: Int
    let canAddMore: Bool
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onEdit: (Int) -> Void
    
    @State private var showingEditSheet = false
    
    var body: some View {
        Button {
            showingEditSheet = true
        } label: {
            HStack(spacing: 12) {
                // Energy icon
                ZStack {
                    Circle()
                        .fill(Color.typeColor(for: energyType).opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(energyIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width:40, height:40)
                        .font(.title2)
                        .foregroundStyle(Color.typeColor(for: energyType))
                }
                
                // Energy name and availability
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(energyType) Energy")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    
                    Text("\(available) available")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Controls
                HStack(spacing: 12) {
                    Button(action: onDecrement) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(quantity > 0 ? .red : .gray)
                    }
                    .disabled(quantity == 0)
                    .buttonStyle(.plain)
                    
                    Text("\(quantity)")
                        .font(.body.bold().monospacedDigit())
                        .foregroundStyle(.primary)
                        .frame(minWidth: 30)
                    
                    Button(action: onIncrement) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(canAddMore ? .green : .gray)
                    }
                    .disabled(!canAddMore)
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .background(
            quantity > 0 ? Color.typeColor(for: energyType).opacity(0.05) : Color.clear,
            in: RoundedRectangle(cornerRadius: 8)
        )
        .sheet(isPresented: $showingEditSheet) {
            EditBasicEnergySheet(
                energyType: energyType,
                currentQuantity: quantity,
                maxQuantity: owned,
                onSave: onEdit
            )
        }
    }
    
    private var energyIcon: String {
        switch energyType.lowercased() {
        case "grass": return "GrassTypeIcon"
        case "fire": return "FireTypeIcon"
        case "water": return "WaterTypeIcon"
        case "lightning": return "ElectricTypeIcon"
        case "psychic": return "PsychicTypeIcon"
        case "fighting": return "FightingTypeIcon"
        case "darkness": return "DarkTypeIcon"
        case "metal": return "SteelTypeIcon"
        default: return "circle.fill"
        }
    }
}

// MARK: - Edit Basic Energy Sheet

struct EditBasicEnergySheet: View {
    @Environment(\.dismiss) private var dismiss
    let energyType: String
    let currentQuantity: Int
    let maxQuantity: Int
    let onSave: (Int) -> Void
    
    @State private var quantityText: String
    @FocusState private var isTextFieldFocused: Bool
    
    init(energyType: String, currentQuantity: Int, maxQuantity: Int, onSave: @escaping (Int) -> Void) {
        self.energyType = energyType
        self.currentQuantity = currentQuantity
        self.maxQuantity = maxQuantity
        self.onSave = onSave
        _quantityText = State(initialValue: "\(currentQuantity)")
    }
    
    var isValid: Bool {
        guard let quantity = Int(quantityText) else { return false }
        return quantity >= 0 && quantity <= maxQuantity
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Energy icon
                ZStack {
                    Circle()
                        .fill(Color.typeColor(for: energyType).opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Image(energyIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width:100, height:100)
                        .font(.title2)
                        .foregroundStyle(Color.typeColor(for: energyType))
                }
                .padding(.top, 20)
                
                // Energy type
                Text("\(energyType) Energy")
                    .font(.title2.bold())
                
                // Count input
                VStack(spacing: 8) {
                    Text("How many in this deck?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("You own \(maxQuantity)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    TextField("Quantity", text: $quantityText)
                        .keyboardType(.numberPad)
                        .font(.system(size: 60, weight: .bold))
                        .multilineTextAlignment(.center)
                        .focused($isTextFieldFocused)
                        .frame(height: 80)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    if let quantity = Int(quantityText), quantity > maxQuantity {
                        Text("Cannot add more than \(maxQuantity)")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Edit Quantity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let quantity = Int(quantityText) {
                            onSave(quantity)
                            dismiss()
                        }
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }
    
    private var energyIcon: String {
        switch energyType.lowercased() {
        case "grass": return "GrassTypeIcon"
        case "fire": return "FireTypeIcon"
        case "water": return "WaterTypeIcon"
        case "lightning": return "ElectricTypeIcon"
        case "psychic": return "PsychicTypeIcon"
        case "fighting": return "FightingTypeIcon"
        case "darkness": return "DarkTypeIcon"
        case "metal": return "SteelTypeIcon"
        default: return "circle.fill"
        }
    }
}

#Preview {
    NavigationStack {
        DeckBuilderView(deck: Deck(name: "Test Deck"))
    }
    .modelContainer(for: [Deck.self, Card.self, DeckCard.self], inMemory: true)
}
