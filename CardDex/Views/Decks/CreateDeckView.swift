//
//  CreateDeckView.swift
//  CardDex
//
//  Created by Martin Plut on 2/2/26.
//

import SwiftUI
import SwiftData

struct CreateDeckView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: DeckListViewModel
    
    @State private var deckName = ""
    @State private var deckDescription = ""
    @FocusState private var isNameFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Deck Name", text: $deckName)
                        .focused($isNameFieldFocused)
                    
                    TextField("Description (Optional)", text: $deckDescription, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Deck Details")
                } footer: {
                    Text("Give your deck a memorable name and optional description")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("60 cards total", systemImage: "square.stack.3d.up.fill")
                        Label("Max 4 copies per card", systemImage: "doc.on.doc")
                        Label("At least 10 Pokémon recommended", systemImage: "checkmark.circle")
                        Label("At least 10 Energy recommended", systemImage: "bolt.fill")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                } header: {
                    Text("Deck Building Rules")
                }
            }
            .navigationTitle("New Deck")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createDeck()
                    }
                    .disabled(deckName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                isNameFieldFocused = true
            }
        }
    }
    
    private func createDeck() {
        let trimmedName = deckName.trimmingCharacters(in: .whitespaces)
        let trimmedDescription = deckDescription.trimmingCharacters(in: .whitespaces)
        
        viewModel.createDeck(
            name: trimmedName,
            description: trimmedDescription.isEmpty ? nil : trimmedDescription
        )
        
        dismiss()
    }
}


#Preview {
    @Previewable @State var modelContext = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Card.self, Deck.self, CardSet.self, DeckCard.self,
            configurations: config
        )
        return container.mainContext
    }()
    
    CreateDeckView(viewModel: DeckListViewModel(modelContext: modelContext))
}
