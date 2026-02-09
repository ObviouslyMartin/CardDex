//
//  CardLibraryView.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//


import SwiftUI
import SwiftData

struct CardLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: CardLibraryViewModel?
    @State private var showingSearch = false
    @State private var showingFilters = false
    @State private var viewMode: ViewMode = .grid
    @State private var selectedCard: Card?
    
    enum ViewMode {
        case grid, list
    }
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                contentView(viewModel: viewModel)
                    .onAppear {
                        // Refresh cards when view appears (e.g., after adding cards)
                        viewModel.fetchCards()
                    }
            } else {
                LoadingView("Loading your collection...")
                    .onAppear {
                        viewModel = CardLibraryViewModel(modelContext: modelContext)
                    }
            }
        }
    }
    
    @ViewBuilder
    private func contentView(viewModel: CardLibraryViewModel) -> some View {
        NavigationStack {
            ZStack {
                if viewModel.filteredCards.isEmpty {
                    emptyState(viewModel: viewModel)
                } else {
                    cardContent(viewModel: viewModel)
                }
            }
            .navigationTitle("Collection")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            viewMode = .grid
                        } label: {
                            Label("Grid View", systemImage: "square.grid.2x2")
                        }
                        
                        Button {
                            viewMode = .list
                        } label: {
                            Label("List View", systemImage: "list.bullet")
                        }
                        
                        Divider()
                        
                        Button {
                            showingFilters = true
                        } label: {
                            Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
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
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSearch = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .searchable(
                text: Binding(
                    get: { viewModel.searchText },
                    set: { viewModel.searchText = $0 }
                ),
                prompt: "Search your collection"
            )
            .sheet(isPresented: $showingSearch) {
                CardSearchView()
            }
            .sheet(isPresented: $showingFilters) {
                FilterView(viewModel: viewModel)
            }
            .sheet(item: $selectedCard) { card in
                CardDetailView(card: card)
            }
        }
    }
    
    @ViewBuilder
    private func cardContent(viewModel: CardLibraryViewModel) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                // Stats header
                collectionStats(viewModel: viewModel)
                
                // Cards
                if viewMode == .grid {
                    CardGridView(
                        cards: viewModel.filteredCards,
                        onCardTap: { card in
                            selectedCard = card
                        }
                    )
                } else {
                    CardListView(
                        cards: viewModel.filteredCards,
                        onCardTap: { card in
                            selectedCard = card
                        }
                    )
                }
            }
            .padding()
        }
    }
    
    private func collectionStats(viewModel: CardLibraryViewModel) -> some View {
        HStack(spacing: 20) {
            VStack {
                Text("\(viewModel.totalCards)")
                    .font(.title.bold())
                Text("Total Cards")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
                .frame(height: 40)
            
            VStack {
                Text("\(viewModel.uniqueCards)")
                    .font(.title.bold())
                Text("Unique")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
                .frame(height: 40)
            
            VStack {
                Text("\(viewModel.filteredCards.count)")
                    .font(.title.bold())
                Text("Showing")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func emptyState(viewModel: CardLibraryViewModel) -> some View {
        Group {
            if viewModel.hasActiveFilters {
                EmptyStateView.noFilteredResults(onClear: {
                    HapticFeedback.filterToggled()
                    viewModel.clearFilters()
                })
            } else {
                EmptyStateView.emptyCollection(onAdd: {
                    HapticFeedback.light()
                    showingSearch = true
                })
            }
        }
    }
}

#Preview {
    CardLibraryView()
        .modelContainer(for: [Card.self, Deck.self, CardSet.self, DeckCard.self], inMemory: true)
}
