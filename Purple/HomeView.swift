//
//  HomeView.swift
//  Purple
//
//  Created by Ben Booth on 3/10/25.
//

import SwiftUI
import Foundation

struct HomeView: View {
    @StateObject private var newsService = NewsService()
    @State private var selectedIndex = 0
    @State private var rewrittenArticle: String?
    @State private var aiGeneratedHeadline: String?
    @State private var aiDemocraticView: String?
    @State private var aiRepublicanView: String?
    
    // ✅ Store AI-rewritten headlines to avoid redundant API calls
    @State private var aiHeadlinesCache: [Int: String] = [:]
    
    var body: some View {
        VStack {
            headerView
            newsCarousel
            selectedStoryView
            navigationArrows
        }
        .onAppear {
            newsService.fetchNews()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                print("News Stories Count: \(newsService.newsStories.count)")
                if !newsService.newsStories.isEmpty {
                    selectedIndex = 0
                    generateAIRewrite()
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Image("purpleLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 40)
            
            Spacer()
            
            Image("users")
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .overlay(Divider().padding(.top, 10), alignment: .bottom)
    }
    
    private var newsCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(newsService.newsStories.indices, id: \.self) { index in
                    newsCard(index)
                }
            }
            .padding(.top, 0)
        }
        .frame(height: 130)
    }
    
    /// ✅ **Updated `newsCard` function with AI-generated headlines**
    private func newsCard(_ index: Int) -> some View {
        @State var aiHeadline: String = aiHeadlinesCache[index] ?? newsService.newsStories[index].title // ✅ Default to cached AI title or original
        
        return ZStack {
            // Background Image
            AsyncImage(url: URL(string: newsService.newsStories[index].image_url ?? "https://via.placeholder.com/300")) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 100)
                    .clipped()
            } placeholder: {
                Color.gray.opacity(0.3).frame(width: 120, height: 100)
            }
            .cornerRadius(10)
            
            // ✅ Add a dark overlay to improve readability
            Color.black.opacity(0.5) // Dark tint
                .frame(width: 120, height: 100)
                .cornerRadius(10)
            
            // Headline Text
            Text(aiHeadline)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(5)
                .background(Color.black.opacity(0.7)) // Background behind text for even better contrast
                .cornerRadius(5)
        }
        .frame(width: 120)
        .onTapGesture {
            selectedIndex = index
            generateAIRewrite()
        }
        .onAppear {
            if let cachedHeadline = aiHeadlinesCache[index] {
                aiHeadline = cachedHeadline // ✅ Uses cached AI-generated headline
            } else {
                AIService.shared.rewriteHeadline(originalTitle: newsService.newsStories[index].title) { newHeadline in
                    DispatchQueue.main.async {
                        aiHeadlinesCache[index] = newHeadline // ✅ Cache AI headline
                        aiHeadline = newHeadline // ✅ Update state immediately
                    }
                }
            }
        }
    }
    
    /// ✅ **Calls AI API to generate rewritten article + headline**
    private func generateAIRewrite() {
        print("🚀 generateAIRewrite() triggered")

        guard newsService.newsStories.indices.contains(selectedIndex) else {
            print("❌ Invalid news index: \(selectedIndex)")
            return
        }

        let originalText = newsService.newsStories[selectedIndex].description ?? "No description available."
        print("📰 News Story Found: \(originalText)")

        // Clear previous AI-generated content
        rewrittenArticle = nil
        aiGeneratedHeadline = nil
        aiDemocraticView = nil
        aiRepublicanView = nil

        print("🚀 Calling OpenAI API now...")

        AIService.shared.rewriteArticle(originalText: originalText) { neutralSummary, democraticView, republicanView in
            DispatchQueue.main.async {
                self.rewrittenArticle = neutralSummary ?? "No summary generated."
                self.aiDemocraticView = democraticView ?? "No Democratic view generated."
                self.aiRepublicanView = republicanView ?? "No Republican view generated."

                print("✅ AI Neutral Summary: \(neutralSummary ?? "❌ No summary returned")")
                print("✅ AI Democratic View: \(democraticView ?? "❌ No view returned")")
                print("✅ AI Republican View: \(republicanView ?? "❌ No view returned")")

                print("🚀 OpenAI API Call Completed!")
            }
        }
    }
    
    @State private var selectedView: SummaryViewType = .neutral // ✅ Track current view
    
    enum SummaryViewType {
        case neutral
        case democratic
        case republican
    }
    
    
    private var selectedStoryView: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 8) {
                // ✅ Headline
                Text(
                    (newsService.newsStories.indices.contains(selectedIndex) ?
                    (aiHeadlinesCache[selectedIndex] ?? newsService.newsStories[selectedIndex].title) : "Loading...")
                )
                .font(.title3)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .foregroundColor(.black)
                
                // ✅ Show appropriate summary based on selectedView
                Text(getCurrentSummary())
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                
                // ✅ Show loading indicator if needed
                if getCurrentSummary() == "Generating..." {
                    ProgressView("Generating AI Summary...").padding(.top, 10)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 20)
        }
        .frame(minHeight: 450, maxHeight: .infinity)
    }
    
    // ✅ Helper function to return correct summary
    private func getCurrentSummary() -> String {
        switch selectedView {
        case .neutral:
            return rewrittenArticle ?? "Generating..."
        case .democratic:
            return aiDemocraticView ?? "Generating Democratic Perspective..."
        case .republican:
            return aiRepublicanView ?? "Generating Republican Perspective..."
        }
    }
    
    private var navigationArrows: some View {
        HStack {
            // ✅ Left Swipe → Democratic View
            Button(action: { selectedView = .democratic }) {
                Image(systemName: "arrow.left.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue) // ✅ Blue for Democratic
            }
            
            Spacer()
            
            // ✅ Reset to Neutral View (Tap in Center)
            Button(action: { selectedView = .neutral }) {
                Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .foregroundColor(.gray) // ✅ Neutral button
            }
            
            Spacer()
            
            // ✅ Right Swipe → Republican View
            Button(action: { selectedView = .republican }) {
                Image(systemName: "arrow.right.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.red) // ✅ Red for Republican
            }
        }
        .padding(.horizontal, 50)
        .padding(.bottom, 20)
    }
}
