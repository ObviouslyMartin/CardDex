//
//  ImageCacheService.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//


import UIKit
import SwiftUI

@MainActor
final class ImageCacheService {
    
    static let shared = ImageCacheService()
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        // Configure memory cache
        memoryCache.countLimit = AppConstants.Cache.maxMemoryCache
        memoryCache.totalCostLimit = 50_000_000 // 50MB in memory
        
        // Setup disk cache directory
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cacheDir.appendingPathComponent(AppConstants.Cache.cacheFolderName)
        
        // Create cache directory if needed
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Setup notifications for memory warnings
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearMemoryCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    // MARK: - Public Methods
    
    /// Load image from cache or download if not cached
    func loadImage(from urlString: String) async throws -> UIImage {
        let cacheKey = NSString(string: urlString)
        
        // Check memory cache first
        if let cachedImage = memoryCache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        // Check disk cache
        if let diskImage = loadFromDisk(urlString: urlString) {
            memoryCache.setObject(diskImage, forKey: cacheKey)
            return diskImage
        }
        
        // Download image
        guard let url = URL(string: urlString) else {
            throw ImageCacheError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ImageCacheError.downloadFailed
        }
        
        guard let image = UIImage(data: data) else {
            throw ImageCacheError.invalidImageData
        }
        
        // Cache the image
        memoryCache.setObject(image, forKey: cacheKey)
        saveToDisk(image: image, urlString: urlString)
        
        return image
    }
    
    /// Preload images in background
    func preloadImages(urls: [String]) {
        Task {
            for urlString in urls {
                try? await loadImage(from: urlString)
            }
        }
    }
    
    /// Clear all cached images
    func clearCache() {
        clearMemoryCache()
        clearDiskCache()
    }
    
    /// Get cache size in bytes
    func getCacheSize() -> Int64 {
        guard let urls = try? fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey]
        ) else {
            return 0
        }
        
        return urls.reduce(0) { total, url in
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            return total + Int64(size)
        }
    }
    
    /// Clear old cached images if cache is too large
    func cleanupOldCache() {
        let cacheSize = getCacheSize()
        
        guard cacheSize > AppConstants.Cache.maxDiskCacheSize else { return }
        
        guard let urls = try? fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey]
        ) else {
            return
        }
        
        // Sort by modification date (oldest first)
        let sortedUrls = urls.sorted { url1, url2 in
            let date1 = (try? url1.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
            let date2 = (try? url2.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
            return date1 < date2
        }
        
        // Delete oldest files until cache is under limit
        var currentSize = cacheSize
        for url in sortedUrls {
            guard currentSize > AppConstants.Cache.maxDiskCacheSize else { break }
            
            if let fileSize = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize {
                try? fileManager.removeItem(at: url)
                currentSize -= Int64(fileSize)
            }
        }
    }
    
    // MARK: - Private Methods
    
    @objc private func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }
    
    private func clearDiskCache() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    private func loadFromDisk(urlString: String) -> UIImage? {
        let fileURL = cacheFileURL(for: urlString)
        
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
    
    private func saveToDisk(image: UIImage, urlString: String) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        let fileURL = cacheFileURL(for: urlString)
        try? data.write(to: fileURL)
    }
    
    private func cacheFileURL(for urlString: String) -> URL {
        let filename = urlString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? UUID().uuidString
        return cacheDirectory.appendingPathComponent(filename)
    }
}

// MARK: - Error Types
enum ImageCacheError: LocalizedError {
    case invalidURL
    case downloadFailed
    case invalidImageData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid image URL"
        case .downloadFailed:
            return "Failed to download image"
        case .invalidImageData:
            return "Invalid image data"
        }
    }
}
