//
//  DeckListView.swift
//  CardDex
//
//  Created by Martin Plut on 2/2/26.
//


import SwiftUI
import SwiftData

struct DeckListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: DeckListViewModel?
    @State private var showingCreateDeck = false
    @State private var selectedDeck: Deck?
    @State private var deckToDelete: Deck?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                contentView(viewModel: viewModel)
            } else {
                ProgressView()
                    .onAppear {
                        viewModel = DeckListViewModel(modelContext: modelContext)
                    }
            }
        }
    }
    
    @ViewBuilder
    private func contentView(viewModel: DeckListViewModel) -> some View {
        NavigationStack {
            ZStack {
                if viewModel.filteredDecks.isEmpty {
                    emptyState(viewModel: viewModel)
                } else {
                    deckList(viewModel: viewModel)
                }
            }
            .navigationTitle("Decks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCreateDeck = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        // Sort options
                        Menu {
                            ForEach(DeckListViewModel.DeckSortOption.allCases, id: \.self) { option in
                                Button {
                                    viewModel.selectedSortOption = option
                                } label: {
                                    Label(option.rawValue, systemImage: option.systemImage)
                                    if viewModel.selectedSortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        } label: {
                            Label("Sort", systemImage: "arrow.up.arrow.down")
                        }
                        
                        Divider()
                        
                        // Filter favorites
                        Button {
                            viewModel.showFavoritesOnly.toggle()
                        } label: {
                            Label("Favorites Only", systemImage: viewModel.showFavoritesOnly ? "star.fill" : "star")
                        }
                        
                        if viewModel.hasActiveFilters {
                            Button(role: .destructive) {
                                viewModel.clearFilters()
                            } label: {
                                Label("Clear Filters", systemImage: "xmark.circle")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .searchable(text: Binding(
                get: { viewModel.searchText },
                set: { viewModel.searchText = $0 }
            ), prompt: "Search decks")
            .sheet(isPresented: $showingCreateDeck) {
                CreateDeckView(viewModel: viewModel)
            }
            .sheet(item: $selectedDeck) { deck in
                NavigationStack {
                    DeckDetailView(deck: deck)
                }
            }
            .alert("Delete Deck?", isPresented: $showingDeleteAlert, presenting: deckToDelete) { deck in
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.deleteDeck(deck)
                }
            } message: { deck in
                Text("Are you sure you want to delete \"\(deck.name)\"? This action cannot be undone.")
            }
            .refreshable {
                viewModel.fetchDecks()
            }
        }
    }
    
    @ViewBuilder
    private func deckList(viewModel: DeckListViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Statistics header
                statsHeader(viewModel: viewModel)
                
                // Deck cards
                ForEach(viewModel.filteredDecks) { deck in
                    DeckCardView(
                        deck: deck,
                        onTap: { selectedDeck = deck },
                        onFavorite: { viewModel.toggleFavorite(deck) },
                        onDuplicate: { viewModel.duplicateDeck(deck) },
                        onDelete: {
                            deckToDelete = deck
                            showingDeleteAlert = true
                        }
                    )
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private func statsHeader(viewModel: DeckListViewModel) -> some View {
        let stats = viewModel.deckStatistics()
        
        HStack(spacing: 16) {
            StatBox(
                title: "Total",
                value: "\(stats.totalDecks)",
                icon: "square.stack.3d.up.fill",
                color: .blue
            )
            
            StatBox(
                title: "Valid",
                value: "\(stats.validDecks)",
                icon: "checkmark.seal.fill",
                color: .green
            )
            
            StatBox(
                title: "Favorites",
                value: "\(stats.favoriteDecks)",
                icon: "star.fill",
                color: .yellow
            )
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    @ViewBuilder
    private func emptyState(viewModel: DeckListViewModel) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text(viewModel.hasActiveFilters ? "No Matching Decks" : "No Decks Yet")
                .font(.title2.bold())
            
            Text(viewModel.hasActiveFilters ?
                 "Try adjusting your filters or search" :
                 "Create your first deck to get started")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                if viewModel.hasActiveFilters {
                    viewModel.clearFilters()
                } else {
                    showingCreateDeck = true
                }
            } label: {
                Label(viewModel.hasActiveFilters ? "Clear Filters" : "Create Deck",
                      systemImage: viewModel.hasActiveFilters ? "xmark.circle" : "plus")
                    .font(.headline)
                    .padding()
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
            }
        }
        .padding()
    }
}

// MARK: - Deck Card View

struct DeckCardView: View {
    let deck: Deck
    let onTap: () -> Void
    let onFavorite: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Header with name and favorite
                HStack {
                    Text(deck.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Button(action: onFavorite) {
                        Image(systemName: deck.isFavorite ? "star.fill" : "star")
                            .foregroundStyle(deck.isFavorite ? .yellow : .secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                
                Divider()
                
                // Stats
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("\(deck.totalCards)")
                            .font(.title2.bold())
                            .foregroundStyle(deck.isValid ? .green : .orange)
                        Text("Cards")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(deck.pokemonCount)")
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                        Text("Pokémon")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(deck.trainerCount)")
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                        Text("Trainers")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(deck.energyCount)")
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                        Text("Energy")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                
                Divider()
                
                // Footer with status and actions
                HStack {
                    // Status badge
                    HStack(spacing: 4) {
                        Image(systemName: deck.isValid ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                            .font(.caption)
                        Text(deck.isValid ? "Valid" : "\(deck.needsMoreCards) needed")
                            .font(.caption.bold())
                    }
                    .foregroundStyle(deck.isValid ? .green : .orange)
                    
                    Spacer()
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        Button(action: onDuplicate) {
                            Image(systemName: "doc.on.doc")
                        }
                        
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        }
                    }
                    .buttonStyle(.plain)
                    .font(.subheadline)
                }
                .padding()
            }
        }
        .buttonStyle(.plain)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(deck.isValid ? Color.green.opacity(0.3) : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Stat Box

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title2.bold())
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    DeckListView()
        .modelContainer(for: [Deck.self, Card.self, DeckCard.self], inMemory: true)
}
