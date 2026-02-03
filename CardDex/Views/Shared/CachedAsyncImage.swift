//
//  CachedAsyncImage.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//


import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    
    let url: String
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var error: Error?
    
    init(
        url: String,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else if isLoading {
                placeholder()
            } else if error != nil {
                placeholder()
            } else {
                placeholder()
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard !url.isEmpty else { return }
        
        isLoading = true
        
        do {
            let loadedImage = try await ImageCacheService.shared.loadImage(from: url)
            image = loadedImage
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}

// MARK: - Convenience Initializer
extension CachedAsyncImage where Content == Image, Placeholder == Color {
    init(url: String) {
        self.init(
            url: url,
            content: { image in
                image
                    .resizable()
            },
            placeholder: {
                Color.gray.opacity(0.2)
            }
        )
    }
}
