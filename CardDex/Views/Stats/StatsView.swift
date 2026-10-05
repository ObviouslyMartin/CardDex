//
//  StatsView.swift
//  CardDex
//
//  Created by Martin Plut on 9/13/26.
//

import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: StatsViewModel?
    var body: some View {
        Group {
            if let viewModel = viewModel {
                contentView(viewModel: viewModel)
            } else {
                LoadingView("Loading collection stats...")
                    .onAppear {
                        viewModel = StatsViewModel(modelContext: modelContext)
                    }
            }
        }
    }

    @ViewBuilder
    private func contentView(viewModel: StatsViewModel) -> some View {
        NavigationStack {
            Group {
                if viewModel.hasCollection {
                    ScrollView {
                        VStack(spacing: 20) {
//                            overviewStats(viewModel: viewModel)
                            supertypeChart(viewModel: viewModel)
                            typeBreakdown(viewModel: viewModel)
                            rarityBreakdown(viewModel: viewModel)
//                            setCompletion(viewModel: viewModel)
                        }
                        .padding()
                    }
                    .refreshable {
                        viewModel.fetchData()
                    }
                } else {
                    emptyState
                }
            }
            .navigationTitle("Collection Stats")
        }
    }

    // MARK: - Overview

    private func overviewStats(viewModel: StatsViewModel) -> some View {
        VStack(spacing: 16) {
            Text("Overview")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatCard(
                    title: "Total Cards",
                    value: "\(viewModel.totalCardsOwned)",
                    icon: "square.stack.3d.up.fill",
                    color: .blue
                )

                StatCard(
                    title: "Unique Cards",
                    value: "\(viewModel.uniqueCardsOwned)",
                    icon: "square.grid.2x2",
                    color: .green
                )

//                StatCard(
//                    title: "Sets Started",
//                    value: "\(viewModel.setsStarted)",
//                    icon: "square.stack.3d.up.badge.a",
//                    color: .purple
//                )

                StatCard(
                    title: "Decks Built",
                    value: "\(viewModel.totalDecks)",
                    icon: "rectangle.stack.fill",
                    color: .orange
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Supertype Chart

    private func supertypeChart(viewModel: StatsViewModel) -> some View {
        VStack(spacing: 16) {
            Text("Card Type Distribution")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Chart {
                ForEach(viewModel.cardsBySupertype, id: \.key) { supertype, count in
                    SectorMark(
                        angle: .value("Count", count),
                        innerRadius: .ratio(0.5),
                        angularInset: 2
                    )
                    .foregroundStyle(supertypeColor(for: supertype))
                    .annotation(position: .overlay) {
                        Text("\(count)")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    }
                }
            }
            .frame(height: 200)

            HStack(spacing: 20) {
                ForEach(viewModel.cardsBySupertype, id: \.key) { supertype, count in
                    LegendItem(color: supertypeColor(for: supertype), label: supertype, count: count)
                }
            }
            .font(.caption)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func supertypeColor(for supertype: String) -> Color {
        switch supertype.lowercased() {
        case "pokémon", "pokemon": return .blue
        case "trainer": return .purple
        case "energy": return .yellow
        default: return .gray
        }
    }

    // MARK: - Type Breakdown

    private func typeBreakdown(viewModel: StatsViewModel) -> some View {
        VStack(spacing: 16) {
            Text("Pokémon Type Distribution")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if viewModel.cardsByType.isEmpty {
                Text("No Pokémon in your collection yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.cardsByType, id: \.key) { type, count in
                        BreakdownRow(
                            leading: {
                                ZStack {
                                    Circle()
                                        .fill(Color.typeColor(for: type).opacity(0.2))
                                        .frame(width: 28, height: 28)

                                    Image(BasicEnergy.icon(for: type))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 28, height: 28)
                                }
                            },
                            label: type,
                            count: count,
                            percentage: viewModel.percentageOfCollection(count),
                            barColor: Color.typeColor(for: type)
                        )
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Rarity Breakdown

    private func rarityBreakdown(viewModel: StatsViewModel) -> some View {
        VStack(spacing: 16) {
            Text("Rarity Breakdown")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 10) {
                ForEach(viewModel.cardsByRarity, id: \.key) { rarity, count in
                    BreakdownRow(
                        leading: {
                            Circle()
                                .fill(Color.rarityColor(for: rarity))
                                .frame(width: 14, height: 14)
                        },
                        label: rarity,
                        count: count,
                        percentage: viewModel.percentageOfCollection(count),
                        barColor: Color.rarityColor(for: rarity)
                    )
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Set Completion

//    private func setCompletion(viewModel: StatsViewModel) -> some View {
//        VStack(spacing: 16) {
//            Text("Set Completion")
//                .font(.headline)
//                .frame(maxWidth: .infinity, alignment: .leading)
//
//            if viewModel.startedSets.isEmpty {
//                Text("No sets completed yet")
//                    .font(.caption)
//                    .foregroundStyle(.secondary)
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 12)
//            } else {
//                VStack(spacing: 12) {
//                    ForEach(viewModel.startedSets, id: \.id) { set in
//                        SetCompletionRow(set: set)
//                    }
//                }
//            }
//        }
//        .padding()
//        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
//    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)

            Text("No Stats Yet")
                .font(.title2.bold())

            Text("Add cards to your collection to see stats about your types, rarities, and set completion here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Breakdown Row

private struct BreakdownRow<Leading: View>: View {
    let leading: () -> Leading
    let label: String
    let count: Int
    let percentage: Double
    let barColor: Color

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                leading()

                Text(label)
                    .font(.subheadline)

                Spacer()

                Text("\(count)")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)

                Text(String(format: "%.0f%%", percentage))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 44, alignment: .trailing)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(barColor)
                        .frame(width: geometry.size.width * CGFloat(min(max(percentage / 100, 0), 1)), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Set Completion Row

private struct SetCompletionRow: View {
    let set: CardSet

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(set.name)
                    .font(.subheadline)
                    .lineLimit(1)

                Spacer()

                Text("\(set.ownedCardsCount)/\(set.total)")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)

                Text(String(format: "%.0f%%", set.completionPercentage))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 44, alignment: .trailing)
            }

            ProgressView(value: min(max(set.completionPercentage / 100, 0), 1))
                .tint(set.isComplete ? .green : .blue)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Preview

#Preview {
    StatsView()
        .modelContainer(for: [Card.self, CardSet.self, Deck.self, DeckCard.self, BasicEnergy.self], inMemory: true)
}
