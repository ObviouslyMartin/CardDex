//
//  View+Modifiers.swift
//  CardDex
//
//  Created by Martin Plut on 2/8/26.
//

import SwiftUI

extension View {
    
    // MARK: - Card Style
    
    /// Applies standard card styling with shadow and background
    func cardStyle(cornerRadius: CGFloat = 12) -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: Color.cardShadow, radius: 4, x: 0, y: 2)
    }
    
    /// Applies card style with custom background color
    func cardStyle(backgroundColor: Color, cornerRadius: CGFloat = 12) -> some View {
        self
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: Color.cardShadow, radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Navigation
    
    /// Hides the navigation bar
    func hideNavigationBar() -> some View {
        self
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Error Handling
    
    /// Shows an alert for errors
    func errorAlert(error: Binding<Error?>) -> some View {
        self.alert("Error", isPresented: Binding(
            get: { error.wrappedValue != nil },
            set: { if !$0 { error.wrappedValue = nil } }
        )) {
            Button("OK", role: .cancel) {
                error.wrappedValue = nil
            }
        } message: {
            if let error = error.wrappedValue {
                Text(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Loading Overlay
    
    /// Shows a loading overlay on top of the view
    func loadingOverlay(isLoading: Bool, message: String = "Loading...") -> some View {
        self.overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        
                        Text(message)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    }
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
                .transition(.opacity)
            }
        }
    }
    
    // MARK: - Placeholder
    
    /// Shows placeholder when condition is true
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
    
    // MARK: - Conditional Apply
    
    /// Applies a transformation conditionally
    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, transform: (Self) -> T) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        Text("Card with standard style")
            .padding()
            .cardStyle()
        
        Text("Card with custom background")
            .padding()
            .cardStyle(backgroundColor: Color.blue.opacity(0.2))
        
        Text("Card with loading overlay")
            .padding()
            .cardStyle()
            .loadingOverlay(isLoading: true, message: "Saving...")
    }
    .padding()
}
