//
//  AIService.swift
//  Purple
//
//  Created by Ben Booth on 3/18/25.
//
import Foundation

class AIService {
    static let shared = AIService()

    // ✅ Load the API key securely from an environment variable
    private let openAIKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""

    private let endpoint = "https://api.openai.com/v1/chat/completions"

    func rewriteArticle(originalText: String, completion: @escaping (String?, String?, String?, String?) -> Void) {
        guard let url = URL(string: endpoint) else {
            print("❌ Invalid OpenAI URL")
            completion(nil, nil, nil, nil) // ✅ Matches four parameters
            return
        }
        
        let requestData: [String: Any] = [
            "model": "gpt-4-turbo",
            "messages": [
                ["role": "system", "content": """
                You are a professional news summarizer. Given a news article, generate in no less than 3 paragraphs for each:
                1️⃣ **HEADLINE:** (Short and engaging, **max 6 words**)
                2️⃣ **NEUTRAL SUMMARY:** (3-6 paragraphs)
                3️⃣ **DEMOCRATIC VIEW:** (2-4 paragraphs)
                4️⃣ **REPUBLICAN VIEW:** (2-4 paragraphs)
                
                Respond **only in this format**, no extra text:
                
                **HEADLINE:** [Your short headline]
                **NEUTRAL SUMMARY:** [Your neutral summary]
                **DEMOCRATIC VIEW:** [Your democratic view]
                **REPUBLICAN VIEW:** [Your republican view]
                """],
                ["role": "user", "content": "Here is the news article: \(originalText)"]
            ],
            "temperature": 0.5,
            "max_tokens": 2500,
        ]

        sendOpenAIRequest(requestData: requestData) { responseText in
            if let response = responseText?.trimmingCharacters(in: .whitespacesAndNewlines) {
                print("🌍 Raw AI Response:\n\(response)")

                // ✅ Extracting individual sections
                let shortHeadline = self.extractSection(response, tag: "**HEADLINE:**")
                let neutralSummary = self.extractSection(response, tag: "**NEUTRAL SUMMARY:**")
                let democraticView = self.extractSection(response, tag: "**DEMOCRATIC VIEW:**")
                let republicanView = self.extractSection(response, tag: "**REPUBLICAN VIEW:**")

                print("🟢 Short Headline: \(shortHeadline ?? "Not found")")
                print("📰 Neutral Summary: \(neutralSummary ?? "Not found")")
                print("🔵 Democratic View: \(democraticView ?? "Not found")")
                print("🔴 Republican View: \(republicanView ?? "Not found")")

                // ✅ Ensure `completion` matches function signature
                completion(shortHeadline, neutralSummary, democraticView, republicanView)
            } else {
                print("❌ No valid response extracted.")
                completion(nil, nil, nil, nil) // ✅ Matches four parameters
            }
        }
    }
    private func sendOpenAIRequest(requestData: [String: Any], completion: @escaping (String?) -> Void) {
        guard let url = URL(string: endpoint) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestData)
        } catch {
            print("❌ Error encoding request data: \(error)")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ OpenAI API Request Error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ No data received from OpenAI API")
                completion(nil)
                return
            }

            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let choices = jsonResponse?["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(content)
                } else {
                    print("❌ Unexpected OpenAI API Response Format")
                    completion(nil)
                }
            } catch {
                print("❌ Error decoding OpenAI response: \(error)")
                completion(nil)
            }
        }.resume()
    }

    // ✅ **Extract section based on tag**
    private func extractSection(_ text: String, tag: String) -> String {
        let range = text.range(of: tag)
        guard let start = range?.upperBound else {
            print("⚠️ Tag '\(tag)' not found in response.")
            return "Not Available."
        }

        let extracted = text[start...].split(separator: "**", maxSplits: 1).first?.trimmingCharacters(in: .whitespacesAndNewlines)

        if let result = extracted, !result.isEmpty {
            return result
        } else {
            print("⚠️ Failed to extract valid content for '\(tag)'")
            return "Not Available."
        }
    }
}
