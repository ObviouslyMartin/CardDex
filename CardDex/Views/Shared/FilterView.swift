//
//  FilterView.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//


import SwiftUI
import SwiftData

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: CardLibraryViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                // Sort Section
                Section("Sort By") {
                    Picker("Sort Option", selection: $viewModel.selectedSortOption) {
                        ForEach(CardSortOption.allCases, id: \.self) { option in
                            Label(option.rawValue, systemImage: option.systemImage)
                                .tag(option)
                        }
                    }
                    .pickerStyle(.inline)
                }
                
                // Supertype Filter
                Section("Card Type") {
                    ForEach(CardSupertype.allCases, id: \.self) { supertype in
                        Toggle(isOn: Binding(
                            get: { viewModel.selectedSupertypes.contains(supertype.rawValue) },
                            set: { isOn in
                                if isOn {
                                    viewModel.selectedSupertypes.insert(supertype.rawValue)
                                } else {
                                    viewModel.selectedSupertypes.remove(supertype.rawValue)
                                }
                            }
                        )) {
                            Label(supertype.rawValue, systemImage: supertype.systemImage)
                        }
                    }
                }
                
                // Pokemon Type Filter
                Section("Pokémon Type") {
                    ForEach(PokemonType.allCases, id: \.self) { type in
                        Toggle(isOn: Binding(
                            get: { viewModel.selectedTypes.contains(type.rawValue) },
                            set: { isOn in
                                if isOn {
                                    viewModel.selectedTypes.insert(type.rawValue)
                                } else {
                                    viewModel.selectedTypes.remove(type.rawValue)
                                }
                            }
                        )) {
                            HStack {
                                TypeBadgeView(type: type.rawValue, size: .small)
                                Text(type.rawValue)
                            }
                        }
                    }
                }
                
                // Rarity Filter
                Section("Rarity") {
                    ForEach(availableRarities, id: \.self) { rarity in
                        Toggle(isOn: Binding(
                            get: { viewModel.selectedRarities.contains(rarity) },
                            set: { isOn in
                                if isOn {
                                    viewModel.selectedRarities.insert(rarity)
                                } else {
                                    viewModel.selectedRarities.remove(rarity)
                                }
                            }
                        )) {
                            Text(rarity)
                        }
                    }
                }
                
                // Set Filter
                if !availableSets.isEmpty {
                    Section("Set") {
                        ForEach(availableSets, id: \.setID) { set in
                            Toggle(isOn: Binding(
                                get: { viewModel.selectedSets.contains(set.setID) },
                                set: { isOn in
                                    if isOn {
                                        viewModel.selectedSets.insert(set.setID)
                                    } else {
                                        viewModel.selectedSets.remove(set.setID)
                                    }
                                }
                            )) {
                                Text(set.setName)
                            }
                        }
                    }
                }
                
                // Clear Filters
                if viewModel.hasActiveFilters {
                    Section {
                        Button(role: .destructive) {
                            viewModel.clearFilters()
                        } label: {
                            Label("Clear All Filters", systemImage: "xmark.circle")
                        }
                    }
                }
            }
            .navigationTitle("Filters & Sort")
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
    
    // MARK: - Computed Properties
    
    private var availableRarities: [String] {
        let rarities = Set(viewModel.cards.compactMap { $0.rarity })
        return rarities.sorted()
    }
    
    private var availableSets: [(setID: String, setName: String)] {
        // Create dictionary to remove duplicates, then convert to sorted array
        var setsDict: [String: String] = [:]
        for card in viewModel.cards {
            setsDict[card.setID] = card.setName
        }
        return setsDict.map { (setID: $0.key, setName: $0.value) }
            .sorted { $0.setName < $1.setName }
    }
}

#Preview {
    FilterView(
        viewModel: CardLibraryViewModel(
            modelContext: ModelContext(
                try! ModelContainer(
                    for: Card.self,
                    configurations: ModelConfiguration(isStoredInMemoryOnly: true)
                )
            )
        )
    )
}
