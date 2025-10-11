import Foundation

// Responses API Response (for GPT-4.1 and GPT-5 models)
// Uses: gpt-4.1-nano for tagging, gpt-5-nano for answering
struct OpenAIResponsesAPIResponse: Codable {
    let id: String?
    let output: [OutputMessage]?
    let usage: Usage?
    
    struct OutputMessage: Codable {
        let id: String?
        let type: String
        let status: String?
        let content: [ContentItem]?  // Optional because reasoning type doesn't have content
        let role: String?
        
        // Extract the actual text from the first content item
        var actualContent: String? {
            return content?.first?.text
        }
    }
    
    struct ContentItem: Codable {
        let type: String
        let text: String
        let annotations: [String]?
        let logprobs: [String]?
        
        enum CodingKeys: String, CodingKey {
            case type
            case text
            case annotations
            case logprobs
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(String.self, forKey: .type)
            text = try container.decode(String.self, forKey: .text)
            annotations = try container.decodeIfPresent([String].self, forKey: .annotations)
            logprobs = try container.decodeIfPresent([String].self, forKey: .logprobs)
        }
    }
    
    struct Usage: Codable {
        let inputTokens: Int?
        let outputTokens: Int?
        let totalTokens: Int?
        
        enum CodingKeys: String, CodingKey {
            case inputTokens = "input_tokens"
            case outputTokens = "output_tokens"
            case totalTokens = "total_tokens"
        }
    }
}

@MainActor
class OpenAIService: ObservableObject {
    @Published var isProcessing = false
    @Published var lastError: String?
    
    private let apiKey: String
    private let responsesURL = "https://api.openai.com/v1/responses"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    /// Generate an answer based on user question and clipboard context
    func generateAnswer(
        question: String,
        clipboardContext: [(content: String, tags: [String])],
        appName: String?
    ) async -> String? {
        print("🤖 [OpenAIService] Generating answer...")
        print("   Question: \(question)")
        print("   Clipboard items: \(clipboardContext.count)")
        
        isProcessing = true
        defer { isProcessing = false }
        
        // Build the prompt
        let prompt = buildAnswerPrompt(question: question, clipboardContext: clipboardContext, appName: appName)
        
        // Make API call
        guard let answer = await callOpenAIForAnswer(prompt: prompt) else {
            print("   ❌ Failed to generate answer")
            return nil
        }
        
        print("   ✅ Generated answer: \(answer.prefix(100))...")
        return answer
    }
    
    /// Generate semantic tags for clipboard content to improve retrieval
    /// Returns tags like: ["terminal", "python", "code", "error_message"]
    func generateTags(
        content: String,
        appName: String?,
        context: String?
    ) async -> [String] {
        print("🏷️  [OpenAIService] Generating tags...")
        print("   Content: \(content.prefix(100))...")
        print("   App: \(appName ?? "Unknown")")
        
        isProcessing = true
        defer { isProcessing = false }
        
        // Build the prompt
        let prompt = buildTaggingPrompt(content: content, appName: appName, context: context)
        
        // Make API call
        guard let tags = await callOpenAI(prompt: prompt) else {
            print("   ❌ Failed to generate tags")
            return []
        }
        
        print("   ✅ Generated tags: \(tags)")
        return tags
    }
    
    private func buildAnswerPrompt(question: String, clipboardContext: [(content: String, tags: [String])], appName: String?) -> String {
        let contextText: String
        if clipboardContext.isEmpty {
            contextText = "No clipboard context available."
        } else {
            contextText = clipboardContext.enumerated().map { index, item in
                let tagsText = item.tags.isEmpty ? "" : " [Tags: \(item.tags.joined(separator: ", "))]"
                return "[\(index + 1)]\(tagsText)\n\(item.content)"
            }.joined(separator: "\n\n---\n\n")
        }
        
        let prompt = """
        You are a PastePup assistant. Answer the user's question based on their clipboard history.
        
        User Question: \(question)
        
        Clipboard Context (with semantic tags):
        \(contextText)
        
        App: \(appName ?? "Unknown")
        
        CRITICAL RULES:
        1. Answer ONLY the user's question directly
        2. Do NOT add ANY commentary about: API calls, processing, clipboard management, or system operations
        3. Do NOT mention "efficiency", "optimization", "wasted calls", or similar meta-topics
        4. If question is not about clipboard content, return empty string
        5. Keep answer concise and directly relevant
        
        OUTPUT FORMAT - Return ONLY this JSON structure, nothing else:
        {
          "A": "your direct answer here"
        }
        
        If not relevant to clipboard:
        {"A": ""}
        """
        
        return prompt
    }
    
    private func buildTaggingPrompt(content: String, appName: String?, context: String?) -> String {
        // Get time of day
        let hour = Calendar.current.component(.hour, from: Date())
        let timeOfDay = switch hour {
        case 5..<12: "morning"
        case 12..<17: "afternoon"
        case 17..<22: "evening"
        default: "night"
        }
        
        let prompt = """
        App: \(appName ?? "Unknown")
        Time: \(timeOfDay)
        Content: \(content.prefix(500))
        
        Generate 3-7 semantic tags for this clipboard item. Focus on content type, domain, and key topics.
        
        Return output in the form of JSON:
        {
          "tags": ["tag1", "tag2", "tag3"]
        }
        
        Return ONLY the JSON, nothing else.
        """
        
        return prompt
    }
    
    private func callOpenAIForAnswer(prompt: String) async -> String? {
        guard !apiKey.isEmpty, apiKey != "your-api-key-here" else {
            print("   ⚠️  No valid API key configured")
            return nil
        }
        
        print("   📤 Sending prompt to OpenAI for answer using Responses API:")
        print("   \(prompt)")
        
        // New Responses API format for gpt-5-nano (answering)
        let requestBody: [String: Any] = [
            "model": "gpt-5",
            "input": [
                [
                    "type": "message",
                    "role": "user",
                    "content": prompt
                ]
            ],
            "text": [
                "format": [
                    "type": "json_object"
                ]
            ],
            "reasoning": [
                "effort": "low",
                "summary": NSNull()
            ] as [String: Any],
            "tools": [],
            "max_output_tokens": 2048
        ]
        
        guard let url = URL(string: responsesURL) else {
            lastError = "Invalid URL"
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            // Print request body for debugging
            if let requestJSON = try? JSONSerialization.data(withJSONObject: requestBody),
               let requestString = String(data: requestJSON, encoding: .utf8) {
                print("   📤 Request Body: \(requestString)")
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                lastError = "Invalid response"
                return nil
            }
            
            print("   📡 OpenAI Response Status: \(httpResponse.statusCode)")
            
            // Print raw response for debugging
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("   📄 Raw Response: \(rawResponse)")
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                lastError = "API Error (\(httpResponse.statusCode)): \(errorMessage)"
                print("   ❌ API Error: \(errorMessage)")
                return nil
            }
            
            // Parse response using new Responses API structure
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(OpenAIResponsesAPIResponse.self, from: data)
            
            // Extract JSON content from response - find the message type output
            guard let output = apiResponse.output else {
                lastError = "No output in response"
                print("   ❌ No output found in response")
                return nil
            }
            
            // Find the first message type output (skip reasoning type)
            let messageOutput = output.first { $0.type == "message" }
            guard let jsonText = messageOutput?.actualContent else {
                lastError = "No message content in response"
                print("   ❌ No message content found in response")
                return nil
            }
            
            print("   📝 Extracted JSON: \(jsonText)")
            
            // Parse the JSON to extract the answer from "A" field
            if let jsonData = jsonText.data(using: .utf8),
               let jsonObject = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
               let answer = jsonObject["A"] as? String {
                let cleanAnswer = answer.trimmingCharacters(in: .whitespacesAndNewlines)
                print("   ✅ Parsed answer: \(cleanAnswer.prefix(200))...")
                return cleanAnswer
            }
            
            // Fallback if JSON parsing fails - return raw content
            print("   ⚠️ JSON parsing failed, returning raw content")
            return jsonText.trimmingCharacters(in: .whitespacesAndNewlines)
            
        } catch {
            lastError = error.localizedDescription
            print("   ❌ Error: \(error)")
            return nil
        }
    }
    
    private func callOpenAI(prompt: String) async -> [String]? {
        guard !apiKey.isEmpty, apiKey != "your-api-key-here" else {
            print("   ⚠️  No valid API key configured")
            return nil
        }
        
        print("   📤 Sending prompt to OpenAI for tagging using Responses API:")
        print("   \(prompt)")
        
        // New Responses API format for gpt-4.1-nano (tagging)
        let requestBody: [String: Any] = [
            "model": "gpt-4.1-nano",
            "input": [
                [
                    "type": "message",
                    "role": "user",
                    "content": prompt
                ]
            ],
            "text": [
                "format": [
                    "type": "json_object"
                ]
            ],
            "reasoning": [:],
            "tools": [],
            "temperature": 0.3,
            "max_output_tokens": 2048,
            "top_p": 1
        ]
        
        guard let url = URL(string: responsesURL) else {
            lastError = "Invalid URL"
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            // Print request body for debugging
            if let requestJSON = try? JSONSerialization.data(withJSONObject: requestBody),
               let requestString = String(data: requestJSON, encoding: .utf8) {
                print("   📤 Request Body: \(requestString)")
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                lastError = "Invalid response"
                return nil
            }
            
            print("   📡 OpenAI Response Status: \(httpResponse.statusCode)")
            
            // Print raw response for debugging
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("   📄 Raw Response: \(rawResponse)")
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                lastError = "API Error (\(httpResponse.statusCode)): \(errorMessage)"
                print("   ❌ API Error: \(errorMessage)")
                return nil
            }
            
            // Parse response using new Responses API structure
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(OpenAIResponsesAPIResponse.self, from: data)
            
            // Extract tags from response - find the message type output
            guard let output = apiResponse.output else {
                lastError = "No output in response"
                print("   ❌ No output found in response")
                return nil
            }
            
            // Find the first message type output (skip reasoning type)
            let messageOutput = output.first { $0.type == "message" }
            guard let tagsText = messageOutput?.actualContent else {
                lastError = "No message content in response"
                print("   ❌ No message content found in response")
                return nil
            }
            
            print("   📝 Extracted text: \(tagsText)")
            
            // Try parsing as JSON first
            if let jsonData = tagsText.data(using: .utf8),
               let jsonObject = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
               let tagsArray = jsonObject["tags"] as? [String] {
                let tags = tagsArray.map { $0.lowercased() }.filter { !$0.isEmpty }
                print("   ✅ Parsed JSON tags: \(tags)")
                return tags
            }
            
            // Fallback to comma-separated parsing
            print("   ⚠️ JSON parsing failed, trying comma-separated format")
            let tags = tagsText
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
                .filter { !$0.isEmpty }
            
            return tags
            
        } catch {
            lastError = error.localizedDescription
            print("   ❌ Error: \(error)")
            return nil
        }
    }
    
    /// Convenience method to get API key from environment
    static func fromEnvironment() -> OpenAIService? {
        if let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            return OpenAIService(apiKey: apiKey)
        }
        return nil
    }
}

