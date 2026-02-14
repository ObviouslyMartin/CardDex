//
//  BasicEnergyView.swift
//  CardDex
//
//  Created by Martin Plut on 2/8/26.
//

import SwiftUI
import SwiftData

struct BasicEnergyView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: BasicEnergyViewModel?
    @State private var showingResetAlert = false
    @State private var editingEnergy: BasicEnergy?
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                contentView(viewModel: viewModel)
            } else {
                LoadingView("Loading energy cards...")
                    .onAppear {
                        viewModel = BasicEnergyViewModel(modelContext: modelContext)
                    }
            }
        }
    }
    
    @ViewBuilder
    private func contentView(viewModel: BasicEnergyViewModel) -> some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Statistics Header
                    statsHeader(viewModel: viewModel)
                    
                    // Energy Cards
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.energies, id: \.type) { energy in
                            EnergyCardRow(
                                energy: energy,
                                onIncrement: { viewModel.increment(type: energy.type) },
                                onDecrement: { viewModel.decrement(type: energy.type) },
                                onEdit: { editingEnergy = energy }
                            )
                        }
                    }
                    
                    // Info Card
                    infoCard
                }
                .padding()
            }
            .navigationTitle("Basic Energy")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showingResetAlert = true
                        } label: {
                            Label("Reset All", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Reset All Energy Counts?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset All", role: .destructive) {
                    viewModel.resetAll()
                }
            } message: {
                Text("This will set all basic energy counts to 0. This action cannot be undone.")
            }
            .sheet(item: $editingEnergy) { energy in
                EditEnergyCountSheet(
                    energy: energy,
                    onSave: { newCount in
                        viewModel.updateCount(for: energy.type, count: newCount)
                        editingEnergy = nil
                    }
                )
            }
        }
    }
    
    @ViewBuilder
    private func statsHeader(viewModel: BasicEnergyViewModel) -> some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Total Energy",
                value: "\(viewModel.totalEnergyCount)",
                icon: "bolt.fill",
                color: .yellow
                
            )
            
            StatCard(
                title: "Types Owned",
                value: "\(viewModel.energyTypesOwned)/\(BasicEnergy.allTypes.count)",
                icon: "square.stack.3d.up.fill",
                color: .blue
                
            )
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    @ViewBuilder
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.blue)
                Text("About Basic Energy Cards")
                    .font(.headline)
            }
            
            Text("Basic energy cards are not available through the API, so you can manually track your collection here. Use the + and - buttons to adjust counts, or tap the card to enter a specific amount.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Energy Card Row

struct EnergyCardRow: View {
    let energy: BasicEnergy
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        Button(action: onEdit) {
            HStack(spacing: 16) {
                // Energy icon with color
                ZStack {
                    Circle()
                        .fill(Color.typeColor(for: energy.type).opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: energy.icon)
                        .font(.title2)
                        .foregroundStyle(Color.typeColor(for: energy.type))
                }
                
                // Energy info
                VStack(alignment: .leading, spacing: 4) {
                    Text(energy.type)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text("\(energy.count) cards")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Controls
                HStack(spacing: 12) {
                    // Decrement button
                    Button(action: {
                        onDecrement()
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(energy.count > 0 ? .red : .gray)
                    }
                    .disabled(energy.count == 0)
                    .buttonStyle(.plain)
                    
                    // Count display
                    Text("\(energy.count)")
                        .font(.title2.bold())
                        .foregroundStyle(.primary)
                        .frame(minWidth: 40)
                    
                    // Increment button
                    Button(action: {
                        onIncrement()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.green)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .buttonStyle(.plain)
        .cardStyle()
        .cardAppearance()
    }
}

// MARK: - Edit Energy Count Sheet

struct EditEnergyCountSheet: View {
    @Environment(\.dismiss) private var dismiss
    let energy: BasicEnergy
    let onSave: (Int) -> Void
    
    @State private var countText: String
    @FocusState private var isTextFieldFocused: Bool
    
    init(energy: BasicEnergy, onSave: @escaping (Int) -> Void) {
        self.energy = energy
        self.onSave = onSave
        _countText = State(initialValue: "\(energy.count)")
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Energy icon
                ZStack {
                    Circle()
                        .fill(Color.typeColor(for: energy.type).opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: energy.icon)
                        .font(.system(size: 50))
                        .foregroundStyle(Color.typeColor(for: energy.type))
                }
                .padding(.top, 20)
                
                // Energy type
                Text("\(energy.type) Energy")
                    .font(.title2.bold())
                
                // Count input
                VStack(spacing: 8) {
                    Text("How many do you own?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    TextField("Count", text: $countText)
                        .keyboardType(.numberPad)
                        .font(.system(size: 60, weight: .bold))
                        .multilineTextAlignment(.center)
                        .focused($isTextFieldFocused)
                        .frame(height: 80)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Edit Count")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let count = Int(countText) {
                            onSave(count)
                        }
                    }
                    .disabled(Int(countText) == nil)
                }
            }
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }
}

// MARK: - Stat Card Component

struct StatCard: View {
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
                .font(.title.bold())
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview

#Preview {
    BasicEnergyView()
        .modelContainer(for: [BasicEnergy.self, Card.self, Deck.self, CardSet.self, DeckCard.self], inMemory: true)
}
