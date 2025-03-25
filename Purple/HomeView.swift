//
//  HomeView.swift
//  Purple
//
//  Created by Ben Booth on 3/10/25.
//
import SwiftUI
import Foundation

struct HomeView: View {
    @StateObject private var redditAPIService = RedditAPIService()
    @StateObject private var sortingService = ArticleSortingService()
    @State private var selectedIndex = 0
    @State private var rewrittenArticle: String?
    @State private var aiGeneratedHeadline: String?
    @State private var aiDemocraticView: String?
    @State private var aiRepublicanView: String?
    @State private var showSortOptions = false
    @State private var aiHeadlines: [Int: String] = [:]
    @State private var aiHeadlinesCache: [String: String] = [:]
    @State private var selectedTimePeriod: String = "This Month"

    private var filteredStories: [RedditPost] {
        return redditAPIService.topStories
    }

    var body: some View {
        VStack {
            headerView
            newsCarousel
                .overlay(Divider().padding(.top, -78), alignment: .bottom)
            selectedStoryView
            navigationArrows
        }
        .onAppear {
            redditAPIService.fetchRedditPoliticsNews()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                print("🔍 Reddit Stories Count: \(redditAPIService.topStories.count)")
                
                if !redditAPIService.topStories.isEmpty {
                    print("📰 First Story Title: \(redditAPIService.topStories.first?.title ?? "No title")")
                    selectedIndex = 0
                    generateAIRewrite()
                } else {
                    print("⚠️ No news stories loaded.")
                }
            }
        }
    }

    private var headerView: some View {
        HStack {
            Text("Purple")
                .font(.custom("Jomhuria-Regular", size: 66))
                .foregroundColor(Color(red: 187/255, green: 149/255, blue: 189/255))
            
            Spacer()
            
            Menu {
                ForEach(SortingPeriod.allCases, id: \.self) { period in
                    Button(period.rawValue) {
                        selectedTimePeriod = period.rawValue
                        refreshNewsForTimePeriod()
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image("trendingUp")
                        .resizable()
                        .frame(width: 14, height: 14)
                    
                    Text(selectedTimePeriod)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.black)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 10)
                .padding(.top, 3)
            }
            
            NavigationLink(destination: SettingsView()) {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .overlay(Divider().padding(.top, -15), alignment: .bottom)
    }

    private func refreshNewsForTimePeriod() {
        // Don't clear the entire cache anymore - we're using a different caching approach
        
        if let period = SortingPeriod(rawValue: selectedTimePeriod) {
            // Update API call to use the selected time period
            redditAPIService.getRedditAccessToken { token in
                guard let token = token else {
                    print("❌ Failed to get Reddit Access Token")
                    return
                }
                
                let redditPeriod = period.toRedditParameter()
                let url = URL(string: "https://oauth.reddit.com/r/politics/top.json?limit=5&t=\(redditPeriod)")!
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.addValue("bearer \(token)", forHTTPHeaderField: "Authorization")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        print("❌ Error fetching news: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    do {
                        let decodedResponse = try JSONDecoder().decode(RedditResponse.self, from: data)
                        DispatchQueue.main.async {
                            redditAPIService.topStories = decodedResponse.data.children.map { $0.data }
                            print("✅ Successfully fetched \(redditAPIService.topStories.count) top stories from r/politics for period: \(period.rawValue)")
                            
                            // Reset selected index and regenerate AI content
                            if !redditAPIService.topStories.isEmpty {
                                selectedIndex = 0
                                generateAIRewrite()
                            }
                        }
                    } catch {
                        print("❌ JSON Parsing Error: \(error)")
                    }
                }.resume()
            }
            
            sortingService.setLastFetchedPeriod(period)
        } else {
            print("❌ Invalid time period: \(selectedTimePeriod)")
        }
    }

    var sortDropdown: some View {
        VStack {
            Button(action: {
                withAnimation {
                    showSortOptions.toggle()
                }
            }) {
                HStack {
                    Text(sortingService.selectedPeriod.rawValue)
                        .foregroundColor(.primary)
                    
                    Image(systemName: showSortOptions ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            if showSortOptions {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(SortingPeriod.allCases) { period in
                        Button(action: {
                            sortingService.selectedPeriod = period
                            showSortOptions = false
                        }) {
                            Text(period.rawValue)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(sortingService.selectedPeriod == period ? Color.gray.opacity(0.2) : Color.clear)
                        }
                        .foregroundColor(.primary)
                    }
                }
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 5)
                .transition(.scale)
                .zIndex(1)
            }
        }
    }

    var newsCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(filteredStories.indices, id: \.self) { index in
                    newsCard(index)
                }
            }
            .padding(.horizontal, 6)
        }
        .frame(height: 130)
        .offset(y: -72)
    }
        
    private func newsCard(_ index: Int) -> some View {
        let post = redditAPIService.topStories[index]
        let cacheKey = "\(selectedTimePeriod)-\(post.id)"
        
        // Check if AI headline exists, if not generate it
        if aiHeadlinesCache[cacheKey] == nil {
            // Generate it immediately
            generateAIHeadline(for: post, cacheKey: cacheKey)
        }
        
        return ZStack(alignment: .bottomLeading) {
            // Background Image - Using thumbnail from Reddit
            AsyncImage(url: URL(string: post.thumbnail ?? "https://via.placeholder.com/300")) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 100)
                    .clipped()
            } placeholder: {
                Color.gray.opacity(0.3).frame(width: 120, height: 100)
            }
            .cornerRadius(10)
            
            Color.black.opacity(0.5)
                .frame(width: 120, height: 100)
                .cornerRadius(10)
            
            // Only show content if we have an AI headline
            if let headline = aiHeadlinesCache[cacheKey] {
                Text(headline)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(5)
                    .frame(maxWidth: 100, alignment: .leading)
                    .shadow(radius: 3)
            } else {
                // Show loading indicator instead of original title
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(width: 100, height: 80)
            }
        }
        .frame(width: 120, height: 100)
        .cornerRadius(10)
        .onTapGesture {
            selectedIndex = index
            generateAIRewrite()
        }
        .onAppear {
            // Ensure we have an AI headline
            if aiHeadlinesCache[cacheKey] == nil {
                generateAIHeadline(for: post, cacheKey: cacheKey)
            }
        }
    }
    
    private func getHeadlineForCard(post: RedditPost, cacheKey: String) -> String {
        // Return the cached AI headline if available, otherwise the original title
        return aiHeadlinesCache[cacheKey] ?? post.title
    }
    
    private func generateAIHeadline(for post: RedditPost, cacheKey: String) {
        AIService.shared.rewriteArticle(originalText: post.title) { headline, _, _, _ in
            DispatchQueue.main.async {
                if let headline = headline {
                    aiHeadlinesCache[cacheKey] = headline
                    print("✅ AI Headline Cached for \(cacheKey): \(headline)")
                } else {
                    print("❌ AI Headline generation failed for \(cacheKey)")
                }
            }
        }
    }
    
    func generateAIRewrite() {
        guard redditAPIService.topStories.indices.contains(selectedIndex) else {
            return
        }
        
        let post = redditAPIService.topStories[selectedIndex]
        let cacheKey = "\(selectedTimePeriod)-\(post.id)"
        
        // Get detailed content by fetching the URL for the Reddit post
        let postURL = post.url
        
        // Clear previous AI-generated content - but don't use placeholder text
        rewrittenArticle = ""
        aiDemocraticView = ""
        aiRepublicanView = ""
        
        // First, use the title as fallback
        let originalText = post.title
        
        // Process with AI using the available text
        AIService.shared.rewriteArticle(originalText: originalText) { shortHeadline, neutralSummary, democraticView, republicanView in
            DispatchQueue.main.async {
                self.aiGeneratedHeadline = shortHeadline
                self.rewrittenArticle = neutralSummary
                self.aiDemocraticView = democraticView
                self.aiRepublicanView = republicanView
                
                // Cache the headline if we got one
                if let headline = shortHeadline {
                    self.aiHeadlinesCache[cacheKey] = headline
                }
                
                print("✅ AI Short Headline: \(shortHeadline ?? "❌ No headline returned")")
                print("✅ AI Neutral Summary: \(neutralSummary ?? "❌ No summary returned")")
                print("✅ AI Democratic View: \(democraticView ?? "❌ No view returned")")
                print("✅ AI Republican View: \(republicanView ?? "❌ No view returned")")
                
                print("🚀 OpenAI API Call Completed!")
            }
        }
    }
    
    @State var selectedView: SummaryViewType = .neutral
    
    enum SummaryViewType {
        case neutral
        case democratic
        case republican
    }
    
    var selectedStoryView: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 8) {
                Spacer()
                // Headline - Show original if AI isn't ready
                if selectedIndex < redditAPIService.topStories.count {
                    let post = redditAPIService.topStories[selectedIndex]
                    let cacheKey = "\(selectedTimePeriod)-\(post.id)"
                    
                    Text(aiHeadlinesCache[cacheKey] ?? post.title)
                        .font(.custom("Inter-Regular", size: 20))
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                } else {
                    Text("")
                        .font(.custom("Inter-Regular", size: 20))
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Body Text - Show empty string instead of "Generating..."
                Text(getCurrentSummary())
                    .font(.custom("InterVariable-Light", size: 18))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                
                // Removed loading indicator entirely
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 20)
        }
        .frame(minHeight: 450, maxHeight: .infinity)
        .offset(y: -86)
    }
    
    func getCurrentSummary() -> String {
        switch selectedView {
        case .neutral:
            return rewrittenArticle ?? ""
        case .democratic:
            return aiDemocraticView ?? ""
        case .republican:
            return aiRepublicanView ?? ""
        }
    }
    
    var navigationArrows: some View {
        VStack {
            HStack {
                // Left Button (Democratic View)
                Button(action: {
                    if selectedView == .neutral {
                        selectedView = .democratic
                    } else if selectedView == .republican {
                        selectedView = .neutral
                    }
                }) {
                    Image("Donkey")
                        .resizable()
                        .frame(width: 50, height: 40)
                }
                
                // Scroll Indicator
                HStack(spacing: 12) {
                    Circle()
                        .fill(selectedView == .democratic ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                    
                    Circle()
                        .fill(selectedView == .neutral ? Color(red: 187/255, green: 149/255, blue: 189/255) : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                    
                    Circle()
                        .fill(selectedView == .republican ? Color.red : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                }
                
                // Right Button (Republican View)
                Button(action: {
                    if selectedView == .neutral {
                        selectedView = .republican
                    } else if selectedView == .democratic {
                        selectedView = .neutral
                    }
                }) {
                    Image("Elephant")
                        .resizable()
                        .frame(width: 50, height: 40)
                }
            }
            .padding(.horizontal, 50)
            .padding(.bottom, 20)
        }
    }
}

