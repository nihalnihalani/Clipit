#!/usr/bin/env swift

import Foundation

class LocalLLMTest {
    let endpoint = "http://10.0.0.138:1234/v1/chat/completions"
    
    func chat(userMessage: String, systemPrompt: String = "You are a helpful assistant. /no_think") {
        guard let url = URL(string: endpoint) else {
            print("❌ Invalid URL")
            return
        }
        
        let payload: [String: Any] = [
            "model": "qwen/qwen3-4b",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userMessage]
            ],
            "temperature": 0.7,
            "max_tokens": -1,
            "stream": true
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("❌ Failed to serialize JSON: \(error)")
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response")
                return
            }
            
            print("📡 Status code: \(httpResponse.statusCode)")
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            // Parse streaming response
            self.parseStreamingResponse(data: data)
        }
        
        task.resume()
    }
    
    func parseStreamingResponse(data: Data) {
        guard let responseString = String(data: data, encoding: .utf8) else {
            print("❌ Could not decode response")
            return
        }
        
        print("\n🤖 Assistant response:")
        print("─────────────────────")
        
        var fullResponse = ""
        
        // Split by lines (SSE format uses "data: " prefix)
        let lines = responseString.components(separatedBy: "\n")
        
        for line in lines {
            // Skip empty lines
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                continue
            }
            
            // Check if line starts with "data: "
            if line.hasPrefix("data: ") {
                let jsonString = String(line.dropFirst(6)) // Remove "data: " prefix
                
                // Check for [DONE] marker
                if jsonString.trimmingCharacters(in: .whitespaces) == "[DONE]" {
                    break
                }
                
                // Parse JSON
                if let jsonData = jsonString.data(using: .utf8) {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                           let choices = json["choices"] as? [[String: Any]],
                           let firstChoice = choices.first,
                           let delta = firstChoice["delta"] as? [String: Any],
                           let content = delta["content"] as? String {
                            print(content, terminator: "")
                            fflush(stdout)
                            fullResponse += content
                        }
                    } catch {
                        // Some lines might not be valid JSON, skip them
                        continue
                    }
                }
            }
        }
        
        print("\n─────────────────────")
        print("✅ Response complete!")
        print("\n📝 Full response length: \(fullResponse.count) characters")
    }
    
    func chatWithCallback(userMessage: String, systemPrompt: String = "You are a helpful assistant. /no_think", onChunk: @escaping (String) -> Void, onComplete: @escaping () -> Void) {
        guard let url = URL(string: endpoint) else {
            print("❌ Invalid URL")
            onComplete()
            return
        }
        
        let payload: [String: Any] = [
            "model": "qwen/qwen3-4b",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userMessage]
            ],
            "temperature": 0.7,
            "max_tokens": -1,
            "stream": true
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("❌ Failed to serialize JSON: \(error)")
            onComplete()
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request error: \(error.localizedDescription)")
                onComplete()
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                onComplete()
                return
            }
            
            // Parse streaming response with callback
            self.parseStreamingResponseWithCallback(data: data, onChunk: onChunk)
            onComplete()
        }
        
        task.resume()
    }
    
    func parseStreamingResponseWithCallback(data: Data, onChunk: (String) -> Void) {
        guard let responseString = String(data: data, encoding: .utf8) else {
            return
        }
        
        let lines = responseString.components(separatedBy: "\n")
        
        for line in lines {
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                continue
            }
            
            if line.hasPrefix("data: ") {
                let jsonString = String(line.dropFirst(6))
                
                if jsonString.trimmingCharacters(in: .whitespaces) == "[DONE]" {
                    break
                }
                
                if let jsonData = jsonString.data(using: .utf8) {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                           let choices = json["choices"] as? [[String: Any]],
                           let firstChoice = choices.first,
                           let delta = firstChoice["delta"] as? [String: Any],
                           let content = delta["content"] as? String {
                            onChunk(content)
                        }
                    } catch {
                        continue
                    }
                }
            }
        }
    }
}

// MARK: - Main Execution

print("🐶 PastePup - Local LLM Test")
print("═══════════════════════════════════════")
print("Testing connection to: http://10.0.0.138:1234")
print("Model: qwen/qwen3-4b")
print("═══════════════════════════════════════\n")

let llm = LocalLLMTest()

// Test 1: Simple question
print("📝 Test 1: Simple question")
print("Question: 'What is 2+2?'\n")

let semaphore1 = DispatchSemaphore(value: 0)
llm.chat(userMessage: "What is 2+2?")
DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    semaphore1.signal()
}
semaphore1.wait()

print("\n\n" + String(repeating: "─", count: 60) + "\n")

// Test 2: Creative prompt
print("📝 Test 2: Creative prompt (with rhymes)")
print("Question: 'Introduce yourself.'\n")

let semaphore2 = DispatchSemaphore(value: 0)
llm.chat(userMessage: "Introduce yourself.", systemPrompt: "Always answer in rhymes. /no_think")
DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    semaphore2.signal()
}
semaphore2.wait()

print("\n\n" + String(repeating: "─", count: 60) + "\n")

// Test 3: Using callback version
print("📝 Test 3: Using callback version")
print("Question: 'Tell me a very short joke.'\n")
print("🤖 Assistant response:")
print("─────────────────────")

let semaphore3 = DispatchSemaphore(value: 0)
var fullText = ""

llm.chatWithCallback(
    userMessage: "Tell me a very short joke.",
    systemPrompt: "You are a funny comedian. /no_think",
    onChunk: { chunk in
        print(chunk, terminator: "")
        fflush(stdout)
        fullText += chunk
    },
    onComplete: {
        print("\n─────────────────────")
        print("✅ Callback complete!")
        print("📝 Total length: \(fullText.count) characters")
        semaphore3.signal()
    }
)

semaphore3.wait()

print("\n\n═══════════════════════════════════════")
print("✅ All tests completed!")
print("═══════════════════════════════════════")

