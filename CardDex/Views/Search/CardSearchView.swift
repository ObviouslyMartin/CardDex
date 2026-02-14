//
//  CardSearchView.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//

import SwiftUI
import SwiftData

struct CardSearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SearchViewModel?
    @State private var showingBulkAddSheet = false
    
    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    contentView(viewModel: viewModel)
                } else {
                    LoadingView("Preparing search...")
                }
            }
            .navigationTitle("Add Cards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                if let viewModel = viewModel, viewModel.hasSelectedCards {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add \(viewModel.selectedCardsCount)") {
                            HapticFeedback.cardAdded()
                            showingBulkAddSheet = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showingBulkAddSheet) {
                if let viewModel = viewModel {
                    BulkAddConfirmationSheet(viewModel: viewModel, dismiss: dismiss)
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = SearchViewModel(modelContext: modelContext)
                }
            }
        }
    }
    
    @ViewBuilder
    private func contentView(viewModel: SearchViewModel) -> some View {
        VStack(spacing: 0) {
            // Search Mode Picker
            searchModePicker(viewModel: viewModel)
            
            // Search Bar
            searchBar(viewModel: viewModel)
            
            // Content
            if viewModel.isSearching && viewModel.cardBriefResults.isEmpty && viewModel.setSearchResults.isEmpty {
                LoadingView("Searching...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !viewModel.setSearchResults.isEmpty {
                // Show set selection list (multiple sets found)
                setSelectionList(viewModel: viewModel)
            } else if !viewModel.cardBriefResults.isEmpty {
                // Show card results
                searchResults(viewModel: viewModel)
            } else if let errorMessage = viewModel.errorMessage {
                // Show error
                errorView(message: errorMessage, viewModel: viewModel)
            } else {
                // Show empty state
                emptyView(viewModel: viewModel)
            }
        }
    }
    
    private func searchModePicker(viewModel: SearchViewModel) -> some View {
        Picker("Search Mode", selection: Binding(
            get: { viewModel.searchMode },
            set: { viewModel.searchMode = $0 }
        )) {
            Text("Set Name").tag(SearchViewModel.SearchMode.setName)
            Text("Card Name/Number").tag(SearchViewModel.SearchMode.cardNameOrNumber)
        }
        .pickerStyle(.segmented)
        .padding()
        .onChange(of: viewModel.searchMode) { _, _ in
            viewModel.clearSearch()
        }
    }
    
    private func searchBar(viewModel: SearchViewModel) -> some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField(
                    viewModel.searchMode.placeholder,
                    text: Binding(
                        get: { viewModel.searchText },
                        set: { viewModel.searchText = $0 }
                    )
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .onSubmit {
                    Task {
                        await viewModel.search()
                    }
                }
                
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.clearSearch()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(8)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            
            Button("Search") {
                Task {
                    await viewModel.search()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.searchText.isEmpty)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    @ViewBuilder
    private func searchResults(viewModel: SearchViewModel) -> some View {
        VStack(spacing: 0) {
            // Set Info Header (if set is selected)
            if let selectedSet = viewModel.selectedSet {
                setInfoHeader(setInfo: selectedSet, viewModel: viewModel)
            }
            
            // Selection Summary
            if viewModel.hasSelectedCards {
                selectionSummary(viewModel: viewModel)
            }
            
            // Cards Grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(viewModel.cardBriefResults) { cardBrief in
                        SelectableCardBriefItem(
                            cardBrief: cardBrief,
                            isSelected: viewModel.isCardSelected(cardBrief.id),
                            selectedQuantity: viewModel.getSelectedQuantity(cardBrief.id),
                            isInCollection: viewModel.isCardInCollection(cardBrief.id),
                            collectionQuantity: viewModel.getCardQuantity(cardBrief.id),
                            onTap: {
                                viewModel.toggleCardSelection(cardBrief.id)
                            },
                            onQuantityChange: { quantity in
                                viewModel.updateCardQuantity(cardBrief.id, quantity: quantity)
                            }
                        )
                    }
                }
                .padding()
            }
        }
    }
    
    private func setInfoHeader(setInfo: SetAPIResponse, viewModel: SearchViewModel) -> some View {
        VStack(spacing: 8) {
            Text(setInfo.name)
                .font(.headline)
            
            HStack {
                Text("Set ID: \(setInfo.id)")
                Text("•")
                Text("\(viewModel.cardBriefResults.count) cards")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
    }
    
    private func setSelectionList(viewModel: SearchViewModel) -> some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Select a set:")
                    .font(.headline)
                    .padding(.top)
                
                ForEach(viewModel.setSearchResults) { set in
                    Button {
                        Task {
                            await viewModel.selectSet(set)
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(set.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                Text("ID: \(set.id)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                if let cardCount = set.cardCount {
                                    Text("\(cardCount.official) cards")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
        }
    }
    
    private func selectionSummary(viewModel: SearchViewModel) -> some View {
        HStack {
            Text("\(viewModel.selectedCards.count) cards selected")
                .font(.subheadline.bold())
            
            Spacer()
            
            Button("Clear") {
                viewModel.clearSelections()
            }
            .font(.caption)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
    }
    
    private func emptyView(viewModel: SearchViewModel) -> some View {
        ContentUnavailableView {
            Label("No Results", systemImage: "magnifyingglass")
        } description: {
            VStack(spacing: 8) {
                Text(viewModel.searchMode.placeholder)
                    .font(.subheadline)
                
                switch viewModel.searchMode {
                case .setName:
                    Text("Examples: Journey Together, Destined Rivals, Stellar Crown")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                case .cardNameOrNumber:
                    VStack(spacing: 4) {
                        Text("By name: Charizard, Pikachu, Mewtwo")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("By number: 25/167, 1/102")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Combined: Dragapult ex 25/167")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    private func errorView(message: String, viewModel: SearchViewModel) -> some View {
        ContentUnavailableView {
            Label("Error", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again") {
                Task {
                    await viewModel.search()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Selectable Card Brief Item (uses CardBrief - no full details needed)
struct SelectableCardBriefItem: View {
    let cardBrief: CardBriefAPI
    let isSelected: Bool
    let selectedQuantity: Int
    let isInCollection: Bool
    let collectionQuantity: Int
    let onTap: () -> Void
    let onQuantityChange: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                // Card Image - TCGdex requires /low.png or /high.png suffix
                if let imageURL = cardBrief.image {
                    let fullImageURL = imageURL.hasSuffix(".png") ? imageURL : "\(imageURL)/low.png"
                    CachedAsyncImage(url: fullImageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .aspectRatio(2.5/3.5, contentMode: .fit)
                            .overlay {
                                ProgressView()
                            }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                    )
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(2.5/3.5, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                        )
                }
                
                // Selection Badge
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .background(Circle().fill(Color.blue))
                        .padding(6)
                }
                
                // Collection Badge
                if isInCollection && !isSelected {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                        Text("×\(collectionQuantity)")
                            .font(.caption.bold())
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.green, in: Capsule())
                    .padding(6)
                }
            }
            .onTapGesture(perform: onTap)
            
            // Card Info
            Text(cardBrief.name)
                .font(.caption2.bold())
                .lineLimit(1)
            
            Text("#\(cardBrief.localId)")
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            // Quantity Stepper (only when selected)
            if isSelected {
                Stepper(
                    value: Binding(
                        get: { selectedQuantity },
                        set: { onQuantityChange($0) }
                    ),
                    in: 1...99
                ) {
                    Text("×\(selectedQuantity)")
                        .font(.caption.bold())
                }
                .labelsHidden()
            }
        }
    }
}

// MARK: - Bulk Add Confirmation Sheet
struct BulkAddConfirmationSheet: View {
    @Bindable var viewModel: SearchViewModel
    let dismiss: DismissAction
    @State private var isAdding = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(selectedCardsList) { cardBrief in
                        HStack {
                            if let imageURL = cardBrief.image {
                                let fullImageURL = imageURL.hasSuffix(".png") ? imageURL : "\(imageURL)/low.png"
                                CachedAsyncImage(url: fullImageURL) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                }
                                .frame(width: 40, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 40, height: 56)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                            
                            VStack(alignment: .leading) {
                                Text(cardBrief.name)
                                    .font(.subheadline.bold())
                                Text("#\(cardBrief.localId)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("×\(viewModel.selectedCards[cardBrief.id] ?? 1)")
                                .font(.headline)
                                .foregroundStyle(.blue)
                        }
                    }
                } header: {
                    Text("Cards to Add")
                }
                
                Section {
                    HStack {
                        Text("Total Cards")
                            .font(.headline)
                        Spacer()
                        Text("\(viewModel.selectedCardsCount)")
                            .font(.headline)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .navigationTitle("Confirm Addition")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isAdding)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add to Collection") {
                        Task {
                            isAdding = true
                            await viewModel.addSelectedCardsToCollection()
                            dismiss()
                        }
                    }
                    .disabled(isAdding)
                }
            }
            .overlay {
                if isAdding {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Adding cards...")
                                .font(.headline)
                        }
                        .padding(32)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private var selectedCardsList: [CardBriefAPI] {
        viewModel.cardBriefResults.filter { viewModel.selectedCards[$0.id] != nil }
    }
}

#Preview {
    CardSearchView()
        .modelContainer(for: [Card.self], inMemory: true)
}
