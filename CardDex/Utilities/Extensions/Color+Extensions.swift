//
//  Color+Extensions.swift
//  CardDex
//
//  Created by Martin Plut on 2/8/26.
//


import SwiftUI

extension Color {
    
    // MARK: - App Theme Colors
    
    /// Primary card background - adapts to light/dark mode
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    
    /// Secondary background for nested elements
    static let secondaryBackground = Color(uiColor: .tertiarySystemGroupedBackground)
    
    /// Subtle border color
    static let subtleBorder = Color(uiColor: .separator)
    
    /// Card shadow color
    static let cardShadow = Color.black.opacity(0.1)
    
    // MARK: - Pokemon Type Colors (optimized for dark mode)
    
    static func typeColor(for type: String) -> Color {
        switch type.lowercased() {
        case "grass": return Color(light: Color(red: 0.48, green: 0.78, blue: 0.33), dark: Color(red: 0.38, green: 0.68, blue: 0.23))
        case "fire": return Color(light: Color(red: 0.93, green: 0.51, blue: 0.19), dark: Color(red: 0.83, green: 0.41, blue: 0.09))
        case "water": return Color(light: Color(red: 0.39, green: 0.58, blue: 0.93), dark: Color(red: 0.29, green: 0.48, blue: 0.83))
        case "lightning", "electric": return Color(light: Color(red: 0.98, green: 0.82, blue: 0.18), dark: Color(red: 0.88, green: 0.72, blue: 0.08))
        case "psychic": return Color(light: Color(red: 0.98, green: 0.41, blue: 0.55), dark: Color(red: 0.88, green: 0.31, blue: 0.45))
        case "fighting": return Color(light: Color(red: 0.75, green: 0.22, blue: 0.17), dark: Color(red: 0.65, green: 0.12, blue: 0.07))
        case "darkness", "dark": return Color(light: Color(red: 0.31, green: 0.31, blue: 0.31), dark: Color(red: 0.51, green: 0.51, blue: 0.51))
        case "metal", "steel": return Color(light: Color(red: 0.60, green: 0.67, blue: 0.72), dark: Color(red: 0.50, green: 0.57, blue: 0.62))
        case "fairy": return Color(light: Color(red: 0.85, green: 0.51, blue: 0.85), dark: Color(red: 0.75, green: 0.41, blue: 0.75))
        case "dragon": return Color(light: Color(red: 0.44, green: 0.35, blue: 0.98), dark: Color(red: 0.34, green: 0.25, blue: 0.88))
        case "colorless", "normal": return Color(light: Color(red: 0.66, green: 0.66, blue: 0.66), dark: Color(red: 0.56, green: 0.56, blue: 0.56))
        default: return Color.gray
        }
    }
    
    // MARK: - Rarity Colors
    
    static func rarityColor(for rarity: String?) -> Color {
        guard let rarity = rarity?.lowercased() else { return .gray }
        
        switch rarity {
        case "common": return Color(light: .gray, dark: Color(white: 0.6))
        case "uncommon": return Color(light: Color(red: 0.20, green: 0.60, blue: 0.20), dark: Color(red: 0.30, green: 0.70, blue: 0.30))
        case "rare": return Color(light: Color(red: 0.80, green: 0.60, blue: 0.20), dark: Color(red: 0.90, green: 0.70, blue: 0.30))
        case "ultra rare", "holo rare": return Color(light: Color(red: 0.60, green: 0.20, blue: 0.80), dark: Color(red: 0.70, green: 0.30, blue: 0.90))
        case "secret rare", "hyper rare": return Color(light: Color(red: 0.90, green: 0.20, blue: 0.20), dark: Color(red: 1.0, green: 0.30, blue: 0.30))
        default: return .gray
        }
    }
    
    // MARK: - Status Colors
    
    static let successGreen = Color(light: Color(red: 0.20, green: 0.78, blue: 0.35), dark: Color(red: 0.30, green: 0.88, blue: 0.45))
    static let warningOrange = Color(light: Color(red: 1.0, green: 0.58, blue: 0.0), dark: Color(red: 1.0, green: 0.68, blue: 0.2))
    static let errorRed = Color(light: Color(red: 1.0, green: 0.23, blue: 0.19), dark: Color(red: 1.0, green: 0.33, blue: 0.29))
    
    // MARK: - Adaptive Color Helper
    
    /// Creates a color that adapts between light and dark mode
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

// MARK: - Gradient Extensions

extension LinearGradient {
    
    /// Subtle card gradient for backgrounds
    static func cardGradient(for type: String?) -> LinearGradient {
        guard let type = type else {
            return LinearGradient(
                colors: [.clear, Color.gray.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        let baseColor = Color.typeColor(for: type)
        return LinearGradient(
            colors: [baseColor.opacity(0.2), baseColor.opacity(0.05)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Shimmer gradient for loading states
    static var shimmer: LinearGradient {
        LinearGradient(
            colors: [
                Color.gray.opacity(0.3),
                Color.gray.opacity(0.1),
                Color.gray.opacity(0.3)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            Text("Type Colors")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(["Grass", "Fire", "Water", "Lightning", "Psychic", "Fighting", "Darkness", "Metal", "Fairy", "Dragon"], id: \.self) { type in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.typeColor(for: type))
                        .frame(height: 60)
                        .overlay(
                            Text(type)
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                        )
                }
            }
            
            Divider()
            
            Text("Rarity Colors")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(["Common", "Uncommon", "Rare", "Ultra Rare", "Secret Rare"], id: \.self) { rarity in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.rarityColor(for: rarity))
                        .frame(height: 40)
                        .overlay(
                            Text(rarity)
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                        )
                }
            }
            
            Divider()
            
            Text("Status Colors")
                .font(.headline)
            
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.successGreen)
                    .frame(height: 40)
                    .overlay(Text("Success").font(.caption.bold()).foregroundStyle(.white))
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.warningOrange)
                    .frame(height: 40)
                    .overlay(Text("Warning").font(.caption.bold()).foregroundStyle(.white))
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.errorRed)
                    .frame(height: 40)
                    .overlay(Text("Error").font(.caption.bold()).foregroundStyle(.white))
            }
        }
        .padding()
    }
}
