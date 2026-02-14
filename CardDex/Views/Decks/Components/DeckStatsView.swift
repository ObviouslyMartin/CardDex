//
//  DeckStatsView.swift
//  CardDex
//
//  Created by Martin Plut on 2/2/26.
//


import SwiftUI
import Charts

struct DeckStatsView: View {
    let deck: Deck
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Overall stats
                overallStats
                
                // Card type breakdown chart
                cardTypeChart
                
                // Energy type breakdown
                energyTypeBreakdown
                
                // Validation issues
                validationSection
            }
            .padding()
        }
        .navigationTitle("Deck Statistics")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Overall Stats
    
    private var overallStats: some View {
        VStack(spacing: 16) {
            Text("Overall Statistics")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    title: "Total Cards",
                    value: "\(deck.totalCards)",
//                    subtitle: "/ 60",
                    icon: "square.stack.3d.up.fill",
                    color: deck.isValid ? .green : .orange,
                )
                
                StatCard(
                    title: "Unique Cards",
                    value: "\(deck.uniqueCards)",
//                    subtitle: "different cards",
                    icon: "square.grid.2x2",
                    color: .blue
                    
                )
                
                StatCard(
                    title: "Pokémon",
                    value: "\(deck.pokemonCount)",
//                    subtitle: "\(percentageString(deck.pokemonCount))",
                    icon: "person.fill",
                    color: .blue
                    
                )
                
                StatCard(
                    title: "Trainers",
                    value: "\(deck.trainerCount)",
//                    subtitle: "\(percentageString(deck.trainerCount))",
                    icon: "figure.walk",
                    color: .purple
                    
                )
                
                StatCard(
                    title: "Energy",
                    value: "\(deck.energyCount)",
//                    subtitle: "\(percentageString(deck.energyCount))",
                    icon: "bolt.fill",
                    color: .yellow
                    
                )
                
                StatCard(
                    title: "Status",
                    value: deck.isValid ? "Valid" : "Invalid",
//                    subtitle: deck.isValid ? "60 cards" : "\(abs(60 - deck.totalCards)) off",
                    icon: deck.isValid ? "checkmark.seal.fill" : "exclamationmark.triangle.fill",
                    color: deck.isValid ? .green : .red
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Card Type Chart
    
    private var cardTypeChart: some View {
        VStack(spacing: 16) {
            Text("Card Type Distribution")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if deck.totalCards > 0 {
                Chart {
                    if deck.pokemonCount > 0 {
                        SectorMark(
                            angle: .value("Count", deck.pokemonCount),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(.blue)
                        .annotation(position: .overlay) {
                            Text("\(deck.pokemonCount)")
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                        }
                    }
                    
                    if deck.trainerCount > 0 {
                        SectorMark(
                            angle: .value("Count", deck.trainerCount),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(.purple)
                        .annotation(position: .overlay) {
                            Text("\(deck.trainerCount)")
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                        }
                    }
                    
                    if deck.energyCount > 0 {
                        SectorMark(
                            angle: .value("Count", deck.energyCount),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(.yellow)
                        .annotation(position: .overlay) {
                            Text("\(deck.energyCount)")
                                .font(.caption.bold())
                                .foregroundStyle(.primary)
                        }
                    }
                }
                .frame(height: 200)
                
                // Legend
                HStack(spacing: 20) {
                    LegendItem(color: .blue, label: "Pokémon", count: deck.pokemonCount)
                    LegendItem(color: .purple, label: "Trainers", count: deck.trainerCount)
                    LegendItem(color: .yellow, label: "Energy", count: deck.energyCount)
                }
                .font(.caption)
            } else {
                Text("No cards in deck")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Energy Type Breakdown
    
    private var energyTypeBreakdown: some View {
        VStack(spacing: 16) {
            Text("Energy Type Distribution")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            let energyTypes = deck.energyTypes.sorted { $0.value > $1.value }
            
            if !energyTypes.isEmpty {
                VStack(spacing: 12) {
                    ForEach(energyTypes, id: \.key) { type, count in
                        HStack {
                            TypeBadgeView(type: type, size: .medium)
                            
                            Text(type)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("\(count)")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            Text("\(percentageString(count))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 50, alignment: .trailing)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
                    }
                }
            } else {
                Text("No energy types in deck")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Validation Section
    
    private var validationSection: some View {
        VStack(spacing: 16) {
            Text("Deck Validation")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                // Card count validation
                ValidationRow(
                    icon: deck.totalCards == 60 ? "checkmark.circle.fill" : "exclamationmark.circle.fill",
                    color: deck.totalCards == 60 ? .green : .orange,
                    title: "Total Card Count",
                    message: deck.totalCards == 60 ? "Perfect! Deck has 60 cards" : 
                            deck.totalCards < 60 ? "Need \(60 - deck.totalCards) more cards" : 
                            "Remove \(deck.totalCards - 60) cards"
                )
                
                // Pokemon count recommendation
                ValidationRow(
                    icon: deck.pokemonCount >= 10 ? "checkmark.circle.fill" : "info.circle.fill",
                    color: deck.pokemonCount >= 10 ? .green : .orange,
                    title: "Pokémon Count",
                    message: deck.pokemonCount >= 10 ? "Good Pokémon count" : 
                            "Consider adding more Pokémon (recommended: 10+)"
                )
                
                // Energy count recommendation
                ValidationRow(
                    icon: deck.energyCount >= 10 ? "checkmark.circle.fill" : "info.circle.fill",
                    color: deck.energyCount >= 10 ? .green : .orange,
                    title: "Energy Count",
                    message: deck.energyCount >= 10 ? "Good Energy count" : 
                            "Consider adding more Energy cards (recommended: 10+)"
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Helper Methods
    
    private func percentageString(_ count: Int) -> String {
        guard deck.totalCards > 0 else { return "0%" }
        let percentage = Double(count) / Double(deck.totalCards) * 100
        return String(format: "%.0f%%", percentage)
    }
}

// MARK: - Supporting Views

//struct StatCard: View {
//    let title: String
//    let value: String
//    let subtitle: String
//    let color: Color
//    let icon: String
//    
//    var body: some View {
//        VStack(spacing: 8) {
//            Image(systemName: icon)
//                .font(.title2)
//                .foregroundStyle(color)
//            
//            Text(value)
//                .font(.title2.bold())
//            
//            Text(title)
//                .font(.caption)
//                .foregroundStyle(.primary)
//            
//            Text(subtitle)
//                .font(.caption2)
//                .foregroundStyle(.secondary)
//        }
//        .frame(maxWidth: .infinity)
//        .padding()
//        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
//    }
//}

struct LegendItem: View {
    let color: Color
    let label: String
    let count: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            
            Text("\(label) (\(count))")
        }
    }
}

struct ValidationRow: View {
    let icon: String
    let color: Color
    let title: String
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    NavigationStack {
        DeckStatsView(deck: Deck(name: "Test Deck"))
    }
}
