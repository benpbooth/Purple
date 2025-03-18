//
//  NewsService.swift
//  Purple
//
//  Created by Ben Booth on 3/13/25.
//
import Foundation

// ✅ Struct for each news story
struct NewsStory: Identifiable, Codable {
    var id: UUID? = UUID()
    let title: String
    let description: String?
    let url: String
    let image_url: String?

    enum CodingKeys: String, CodingKey {
        case title, description, url, image_url
    }
}

// ✅ Fixed `NewsResponse` Struct
struct NewsResponse: Codable {
    let data: [NewsStory] // ✅ Extracts news stories
    let warnings: [String]? // ✅ Fixes the decoding issue
    let meta: Meta?
}
struct Meta: Codable {
    let found: Int?
    let returned: Int?
    let limit: Int?
    let page: Int?
}

// ✅ News Service Class
class NewsService: ObservableObject {
    @Published var newsStories: [NewsStory] = []
    
    func fetchNews() {
        let apiKey = ProcessInfo.processInfo.environment["NEWS_API_KEY"] ?? ""
        let urlString = "https://api.thenewsapi.com/v1/news/top?api_token=\(apiKey)&locale=us&limit=3&categories=politics"
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error fetching news: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            // ✅ Debugging - Print Raw JSON Response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("🌐 Raw JSON Response: \(jsonString)")
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
                DispatchQueue.main.async { [weak self] in
                    self?.newsStories = decodedResponse.data // ✅ Use weak self to avoid retain cycle
                    print("✅ Successfully fetched \(decodedResponse.data.count) news stories.")
                }
            } catch {
                print("❌ Error decoding news: \(error)")
            }
        }.resume()
    }
}



