//
//  View+Animations.swift
//  CardDex
//
//  Created by Martin Plut on 2/8/26.
//

import SwiftUI

extension View {
    
    // MARK: - Card Appearance Animation
    
    /// Animates card appearance with a smooth fade and scale
    func cardAppearance(delay: Double = 0) -> some View {
        self
            .transition(.asymmetric(
                insertion: .scale(scale: 0.95).combined(with: .opacity),
                removal: .opacity
            ))
    }
    
    /// Staggered appearance for lists - each item appears with increasing delay
    func staggeredAppearance(index: Int, itemsPerBatch: Int = 10) -> some View {
        let delay = Double(index % itemsPerBatch) * 0.05
        return self
            .opacity(1)
            .animation(.easeOut(duration: 0.3).delay(delay), value: index)
    }
    
    // MARK: - Tap Effects
    
    /// Adds a spring bounce effect on tap
    func bouncyTap() -> some View {
        self.modifier(BouncyTapModifier())
    }
    
    /// Adds a subtle scale effect on press
    func pressEffect() -> some View {
        self.modifier(PressEffectModifier())
    }
    
    // MARK: - Conditional Modifiers
    
    /// Conditionally applies a modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Bouncy Tap Modifier

struct BouncyTapModifier: ViewModifier {
    @State private var isTapped = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isTapped ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isTapped)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isTapped = true }
                    .onEnded { _ in isTapped = false }
            )
    }
}

// MARK: - Press Effect Modifier

struct PressEffectModifier: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

// MARK: - Custom Transitions

extension AnyTransition {
    
    /// Slide and fade transition
    static var slideAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
    
    /// Scale and fade with blur effect
    static var scaleBlur: AnyTransition {
        .scale(scale: 0.9).combined(with: .opacity)
    }
    
    /// Pop effect for modal presentations
    static var pop: AnyTransition {
        .scale(scale: 1.2).combined(with: .opacity)
    }
}

// MARK: - Animation Presets

enum AppAnimations {
    /// Quick spring animation for UI feedback
    static let quickSpring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    
    /// Smooth ease for general transitions
    static let smoothEase = Animation.easeInOut(duration: 0.25)
    
    /// Bouncy spring for playful interactions
    static let bouncySpring = Animation.spring(response: 0.4, dampingFraction: 0.6)
    
    /// Gentle ease for subtle changes
    static let gentleEase = Animation.easeInOut(duration: 0.4)
    
    /// Snappy response for immediate feedback
    static let snappy = Animation.spring(response: 0.2, dampingFraction: 0.8)
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    let duration: Double
    
    init(duration: Double = 1.5) {
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.3),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    /// Adds a shimmer loading effect
    func shimmer(duration: Double = 1.5) -> some View {
        self.modifier(ShimmerModifier(duration: duration))
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        // Bouncy tap example
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.blue)
            .frame(width: 150, height: 60)
            .overlay(Text("Tap Me").foregroundStyle(.white))
            .bouncyTap()
        
        // Press effect example
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.green)
            .frame(width: 150, height: 60)
            .overlay(Text("Press Me").foregroundStyle(.white))
            .pressEffect()
        
        // Shimmer example
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.3))
            .frame(width: 150, height: 60)
            .shimmer()
    }
    .padding()
}
