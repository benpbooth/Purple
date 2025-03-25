//
//  CacheService.swift
//  Purple
//
//  Created by Ben Booth on 3/20/25.
//
import Foundation
import SwiftUI

// MARK: - Caching Service
class CacheService {
    static let shared = CacheService()
    
    // Cache for AI processed content with expiration time
    private var contentCache: [String: (content: AIProcessedContent, timestamp: Date)] = [:]
    private let cacheExpirationTime: TimeInterval = 3600 // 1 hour
    
    // Structure to store all AI-generated content for an article
    struct AIProcessedContent {
        let headline: String
        let neutralSummary: String
        let democraticView: String
        let republicanView: String
    }
    
    // Get cached content if available and not expired
    func getCachedContent(for key: String) -> AIProcessedContent? {
        guard let (content, timestamp) = contentCache[key],
              Date().timeIntervalSince(timestamp) < cacheExpirationTime else {
            return nil
        }
        return content
    }
    
    // Save content to cache
    func cacheContent(for key: String, content: AIProcessedContent) {
        contentCache[key] = (content, Date())
    }
    
    // Clear expired cache entries
    func clearExpiredCache() {
        let now = Date()
        contentCache = contentCache.filter { (_, value) in
            now.timeIntervalSince(value.timestamp) < cacheExpirationTime
        }
    }
}
