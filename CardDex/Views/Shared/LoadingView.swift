//
//  LoadingView.swift
//  CardDex
//
//  Created by Martin Plut on 2/8/26.
//

import SwiftUI

// MARK: - Generic Loading View
struct LoadingView: View {
    let message: String
    
    init(_ message: String = "Loading...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Card Grid Skeleton
struct CardGridSkeleton: View {
    let columns: Int
    let rows: Int
    
    init(columns: Int = 3, rows: Int = 4) {
        self.columns = columns
        self.rows = rows
    }
    
    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: columns),
            spacing: 12
        ) {
            ForEach(0..<(columns * rows), id: \.self) { _ in
                SkeletonCardItem()
            }
        }
        .padding()
    }
}

// MARK: - Card List Skeleton
struct CardListSkeleton: View {
    let count: Int
    
    init(count: Int = 10) {
        self.count = count
    }
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(0..<count, id: \.self) { _ in
                SkeletonCardRow()
            }
        }
        .padding()
    }
}

// MARK: - Skeleton Card Item (for grid)
struct SkeletonCardItem: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Card image placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(shimmerGradient)
                .aspectRatio(0.715, contentMode: .fit) // Standard Pokemon card ratio
            
            // Card name placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(shimmerGradient)
                .frame(height: 12)
                .frame(maxWidth: .infinity)
            
            // Card set placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(shimmerGradient)
                .frame(height: 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(width: 80)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
    
    private var shimmerGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.gray.opacity(0.3),
                Color.gray.opacity(0.1),
                Color.gray.opacity(0.3)
            ],
            startPoint: isAnimating ? .leading : .trailing,
            endPoint: isAnimating ? .trailing : .leading
        )
    }
}

// MARK: - Skeleton Card Row (for list)
struct SkeletonCardRow: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail placeholder
            RoundedRectangle(cornerRadius: 6)
                .fill(shimmerGradient)
                .frame(width: 60, height: 84)
            
            VStack(alignment: .leading, spacing: 8) {
                // Name placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(shimmerGradient)
                    .frame(height: 16)
                    .frame(maxWidth: .infinity)
                
                // Details placeholder
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(shimmerGradient)
                        .frame(width: 30, height: 12)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(shimmerGradient)
                        .frame(width: 30, height: 12)
                }
                
                // Set placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(shimmerGradient)
                    .frame(height: 10)
                    .frame(width: 100)
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
    
    private var shimmerGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.gray.opacity(0.3),
                Color.gray.opacity(0.1),
                Color.gray.opacity(0.3)
            ],
            startPoint: isAnimating ? .leading : .trailing,
            endPoint: isAnimating ? .trailing : .leading
        )
    }
}

// MARK: - Deck Card Skeleton
struct DeckCardSkeleton: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(shimmerGradient)
                .frame(width: 100, height: 140)
            
            VStack(alignment: .leading, spacing: 12) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(shimmerGradient)
                    .frame(height: 20)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(shimmerGradient)
                    .frame(height: 16)
                    .frame(maxWidth: 200)
                
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(shimmerGradient)
                            .frame(width: 40, height: 12)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
    
    private var shimmerGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.gray.opacity(0.3),
                Color.gray.opacity(0.1),
                Color.gray.opacity(0.3)
            ],
            startPoint: isAnimating ? .leading : .trailing,
            endPoint: isAnimating ? .trailing : .leading
        )
    }
}

// MARK: - Previews
#Preview("Loading View") {
    LoadingView("Loading cards...")
}

#Preview("Grid Skeleton") {
    ScrollView {
        CardGridSkeleton(columns: 3, rows: 4)
    }
}

#Preview("List Skeleton") {
    ScrollView {
        CardListSkeleton(count: 5)
    }
}

#Preview("Deck Card Skeleton") {
    ScrollView {
        VStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { _ in
                DeckCardSkeleton()
            }
        }
        .padding()
    }
}
