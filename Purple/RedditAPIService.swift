//
//  RedditAPIService.swift
//  Purple
//
//  Created by Ben Booth on 3/20/25.
//
import Foundation

class RedditAPIService: ObservableObject {
    @Published var topStories: [RedditPost] = []
    
    private let clientID = "94Rg_NF8QjGKBERA6lLdhg"  // Your Client ID
    private let redirectURI = "http://localhost:8080"   
    
    // ✅ Get Reddit OAuth Access Token
    func getRedditAccessToken(completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://www.reddit.com/api/v1/access_token")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Add required User-Agent header
        request.addValue("iOS:com.yourcompany.purple:v1.0 (by /u/YOUR_REDDIT_USERNAME)", forHTTPHeaderField: "User-Agent")

        // Generate a unique device ID if needed
        let deviceId = UUID().uuidString
        let body = "grant_type=https://oauth.reddit.com/grants/installed_client&device_id=\(deviceId)"
        request.httpBody = body.data(using: .utf8)

        // Properly format the auth header - include client ID and empty secret
        let authString = "\(clientID):"
        if let authData = authString.data(using: .utf8) {
            let base64Auth = authData.base64EncodedString()
            request.addValue("Basic \(base64Auth)", forHTTPHeaderField: "Authorization")
        }

        // Add debug logging
        print("🔑 Making Reddit Auth Request to: \(url.absoluteString)")
        print("🔑 Auth Header: Basic \(authString.data(using: .utf8)!.base64EncodedString())")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Log HTTP status if available
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Reddit Auth Response Status: \(httpResponse.statusCode)")
            }
            
            guard let data = data, error == nil else {
                print("❌ Auth Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            // Log raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Raw Auth Response: \(responseString)")
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let errorMessage = json?["error"] as? String {
                    print("❌ Reddit Error: \(errorMessage)")
                }
                let accessToken = json?["access_token"] as? String
                DispatchQueue.main.async {
                    completion(accessToken)
                }
            } catch {
                print("❌ JSON Error: \(error)")
                completion(nil)
            }
        }.resume()
    }

    // ✅ Fetch Trending Political News from r/politics
    func fetchRedditPoliticsNews() {
        getRedditAccessToken { token in
            guard let token = token else {
                print("❌ Failed to get Reddit Access Token")
                return
            }

            let url = URL(string: "https://oauth.reddit.com/r/politics/top.json?limit=5&t=day")!

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("bearer \(token)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            // Add User-Agent header to this request too
            request.addValue("iOS:com.yourcompany.purple:v1.0 (by /u/YOUR_REDDIT_USERNAME)", forHTTPHeaderField: "User-Agent")

            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("❌ Error fetching news: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                do {
                    let decodedResponse = try JSONDecoder().decode(RedditResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.topStories = decodedResponse.data.children.map { $0.data }
                        print("✅ Successfully fetched \(self.topStories.count) top stories from r/politics")
                    }
                } catch {
                    print("❌ JSON Parsing Error: \(error)")
                }
            }.resume()
        }
    }
}

// ✅ Reddit Post Data Model
struct RedditResponse: Codable {
    let data: RedditData
}

struct RedditData: Codable {
    let children: [RedditPostWrapper]
}

struct RedditPostWrapper: Codable {
    let data: RedditPost
}

struct RedditPost: Identifiable, Codable {
    let id: String
    let title: String
    let url: String
    let thumbnail: String? // Some posts may not have a thumbnail
}
