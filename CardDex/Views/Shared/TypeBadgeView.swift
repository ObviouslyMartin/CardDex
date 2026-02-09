//
//  TypeBadgeView.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//

import SwiftUI

struct TypeBadgeView: View {
    let type: String
    let size: BadgeSize
    
    enum BadgeSize {
        case small, medium, large
        
        var fontSize: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .subheadline
            }
        }
        
        var padding: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .large: return 8
            }
        }
    }
    
    init(type: String, size: BadgeSize = .small) {
        self.type = type
        self.size = size
    }
    
    var body: some View {
        Text(type)
            .font(size.fontSize)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, size.padding * 1.5)
            .padding(.vertical, size.padding)
            .background(typeColor, in: Capsule())
    }
    
    private var typeColor: Color {
        Color.typeColor(for: type)
    }
}

#Preview {
    VStack {
        HStack {
            TypeBadgeView(type: "Fire", size: .small)
            TypeBadgeView(type: "Water", size: .small)
            TypeBadgeView(type: "Grass", size: .small)
        }
        
        HStack {
            TypeBadgeView(type: "Lightning", size: .medium)
            TypeBadgeView(type: "Psychic", size: .medium)
            TypeBadgeView(type: "Fighting", size: .medium)
        }
        
        HStack {
            TypeBadgeView(type: "Dragon", size: .large)
            TypeBadgeView(type: "Fairy", size: .large)
            TypeBadgeView(type: "Metal", size: .large)
        }
    }
    .padding()
}
