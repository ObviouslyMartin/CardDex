//
//  HapticFeedback.swift
//  CardDex
//
//  Created by Martin Plut on 2/8/26.
//

import UIKit
import SwiftUI

/// Provides haptic feedback for user interactions
enum HapticFeedback {
    
    // MARK: - Feedback Types
    
    /// Light impact - for subtle interactions
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Medium impact - for standard interactions
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// Heavy impact - for significant interactions
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    /// Soft impact - for gentle interactions (iOS 17+)
    @available(iOS 17.0, *)
    static func soft() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }
    
    /// Rigid impact - for firm interactions (iOS 17+)
    @available(iOS 17.0, *)
    static func rigid() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
    }
    
    // MARK: - Notification Feedback
    
    /// Success notification
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// Warning notification
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    /// Error notification
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    // MARK: - Selection Feedback
    
    /// Selection changed
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - View Extension for Haptics

extension View {
    
    /// Adds haptic feedback to button taps
    func hapticFeedback(_ style: HapticStyle = .light) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded {
                switch style {
                case .light:
                    HapticFeedback.light()
                case .medium:
                    HapticFeedback.medium()
                case .heavy:
                    HapticFeedback.heavy()
                case .selection:
                    HapticFeedback.selection()
                case .success:
                    HapticFeedback.success()
                case .warning:
                    HapticFeedback.warning()
                case .error:
                    HapticFeedback.error()
                }
            }
        )
    }
   
}
enum HapticStyle {
    case light, medium, heavy, selection
    case success, warning, error
}
// MARK: - Common Use Cases

extension HapticFeedback {
    
    /// Card added to collection
    static func cardAdded() {
        success()
    }
    
    /// Card removed from collection
    static func cardRemoved() {
        light()
    }
    
    /// Deck created
    static func deckCreated() {
        success()
    }
    
    /// Card added to deck
    static func cardAddedToDeck() {
        light()
    }
    
    /// Card removed from deck
    static func cardRemovedFromDeck() {
        light()
    }
    
    /// Deck validated successfully
    static func deckValid() {
        success()
    }
    
    /// Deck validation failed
    static func deckInvalid() {
        warning()
    }
    
    /// Filter toggled
    static func filterToggled() {
        selection()
    }
    
    /// Search initiated
    static func searchInitiated() {
        light()
    }
    
    /// Tab changed
    static func tabChanged() {
        selection()
    }
}

// MARK: - Preview Helper
#Preview {
    VStack(spacing: 20) {
        Button("Light Impact") {
            HapticFeedback.light()
        }
        .buttonStyle(.borderedProminent)
        
        Button("Medium Impact") {
            HapticFeedback.medium()
        }
        .buttonStyle(.borderedProminent)
        
        Button("Heavy Impact") {
            HapticFeedback.heavy()
        }
        .buttonStyle(.borderedProminent)
        
        Divider()
        
        Button("Success") {
            HapticFeedback.success()
        }
        .buttonStyle(.borderedProminent)
        .tint(.green)
        
        Button("Warning") {
            HapticFeedback.warning()
        }
        .buttonStyle(.borderedProminent)
        .tint(.orange)
        
        Button("Error") {
            HapticFeedback.error()
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
        
        Divider()
        
        Button("Selection") {
            HapticFeedback.selection()
        }
        .buttonStyle(.borderedProminent)
    }
    .padding()
}
