import Foundation

// MARK: - Perplexity API Models

struct PerplexityMessage: Codable {
    let role: String
    let content: String
}

struct PerplexityRequest: Codable {
    let model: String
    let messages: [PerplexityMessage]
    let maxTokens: Int?
    let temperature: Double?
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

struct PerplexityResponse: Codable {
    let choices: [PerplexityChoice]
    let usage: PerplexityUsage?
}

struct PerplexityChoice: Codable {
    let message: PerplexityMessage
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case message
        case finishReason = "finish_reason"
    }
}

struct PerplexityUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

// MARK: - Perplexity Service

class PerplexityService: ObservableObject {
    @Published var isLoading = false
    @Published var lastResponse: String = ""
    @Published var errorMessage: String = ""
    
    private let apiKey: String
    private let baseURL = "https://api.perplexity.ai/chat/completions"
    
    init(apiKey: String) {
        self.apiKey = apiKey
        NSLog("🔑 PerplexityService: Initialized with API key: \(apiKey.prefix(8))...")
        NSLog("🔑 PerplexityService: API key length: \(apiKey.count) characters")
    }
    
    // MARK: - Public Methods
    
    func findPrivacyPolicyURL(for appName: String, bundleIdentifier: String) async -> String? {
        NSLog("🔍 PerplexityService: Searching for privacy policy URL for '\(appName)' (Bundle: \(bundleIdentifier))")
        
        let prompt = """
        Find the privacy policy URL for the iOS/macOS app: "\(appName)" with bundle identifier "\(bundleIdentifier)".
        
        Please search for the official privacy policy URL and return ONLY the direct URL to the privacy policy page.
        If you find multiple URLs, return the most official one (usually from the company's main website).
        If no privacy policy is found, return "NOT_FOUND".
        
        Format your response as just the URL or "NOT_FOUND".
        """
        
        do {
            NSLog("📡 PerplexityService: Making API request to find privacy policy URL...")
            let response = try await makeAPIRequest(prompt: prompt, maxTokens: 200, temperature: 0.1)
            NSLog("📡 PerplexityService: Received response: \(response)")
            
            // Clean up the response to extract just the URL
            let cleanedResponse = response.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if cleanedResponse.lowercased().contains("not_found") || cleanedResponse.isEmpty {
                NSLog("❌ PerplexityService: No privacy policy URL found")
                return nil
            }
            
            // Extract URL from response
            if let url = extractURL(from: cleanedResponse) {
                NSLog("✅ PerplexityService: Successfully extracted privacy policy URL: \(url)")
                return url
            }
            
            NSLog("❌ PerplexityService: Could not extract valid URL from response")
            return nil
            
        } catch {
            NSLog("❌ PerplexityService: Error finding privacy policy URL: \(error)")
            return nil
        }
    }
    
    func analyzeAppPrivacy(for appName: String, bundleIdentifier: String, permissions: [String]) async -> String? {
        NSLog("🔍 PerplexityService: Analyzing privacy for '\(appName)' with permissions: \(permissions)")
        
        let permissionsList = permissions.joined(separator: ", ")
        
        let prompt = """
        Analyze the privacy implications of the iOS/macOS app: "\(appName)" (Bundle ID: \(bundleIdentifier)).
        
        The app requests these permissions: \(permissionsList)
        
        Please provide a brief privacy analysis covering:
        1. What data this app likely collects based on its permissions
        2. Potential privacy risks
        3. Whether this app is generally privacy-friendly
        4. Any red flags to watch out for
        
        Keep the response concise but informative (max 300 words).
        """
        
        do {
            NSLog("📡 PerplexityService: Making API request for privacy analysis...")
            let response = try await makeAPIRequest(prompt: prompt, maxTokens: 500, temperature: 0.3)
            NSLog("📡 PerplexityService: Received privacy analysis response")
            return response
        } catch {
            NSLog("❌ PerplexityService: Error analyzing app privacy: \(error)")
            return nil
        }
    }
    
    func getAppStoreInfo(for bundleIdentifier: String) async -> (name: String, developer: String, privacyPolicyURL: String?)? {
        NSLog("🔍 PerplexityService: Getting app store info for bundle: \(bundleIdentifier)")
        
        // Check if this is a generic Electron bundle ID
        let isGenericBundle = bundleIdentifier.hasPrefix("com.todesktop.") || bundleIdentifier.hasPrefix("com.electron.")
        
        let prompt = """
        Get information about the iOS/macOS app with bundle identifier: "\(bundleIdentifier)".
        
        \(isGenericBundle ? "NOTE: This appears to be a generic Electron app bundle ID. Please search for the actual app name instead." : "")
        
        Please provide:
        1. The official app name
        2. The developer/company name
        3. The privacy policy URL (if available)
        
        Format your response as JSON:
        {
            "name": "App Name",
            "developer": "Developer Name",
            "privacyPolicyURL": "https://example.com/privacy" or null
        }
        """
        
        do {
            NSLog("📡 PerplexityService: Making API request for app store info...")
            let response = try await makeAPIRequest(prompt: prompt, maxTokens: 300, temperature: 0.1)
            NSLog("📡 PerplexityService: Received app store info response")
            
            // Try to parse JSON response
            if let data = response.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                
                let name = json["name"] as? String ?? "Unknown App"
                let developer = json["developer"] as? String ?? "Unknown Developer"
                let privacyPolicyURL = json["privacyPolicyURL"] as? String
                
                NSLog("✅ PerplexityService: Successfully parsed app info - \(name) by \(developer)")
                return (name: name, developer: developer, privacyPolicyURL: privacyPolicyURL)
            }
            
            NSLog("❌ PerplexityService: Could not parse JSON response")
            return nil
            
        } catch {
            NSLog("❌ PerplexityService: Error getting app store info: \(error)")
            return nil
        }
    }
    
    func getAppStoreInfoByName(_ appName: String) async -> (name: String, developer: String, privacyPolicyURL: String?)? {
        NSLog("🔍 PerplexityService: Getting app store info by name: \(appName)")
        
        let prompt = """
        Get information about the desktop application: "\(appName)".
        
        This is likely a desktop app (Windows/Mac/Linux) that may also have mobile versions.
        Please provide:
        1. The official app name
        2. The developer/company name  
        3. The privacy policy URL (if available)
        
        Format your response as JSON:
        {
            "name": "App Name",
            "developer": "Developer Name",
            "privacyPolicyURL": "https://example.com/privacy" or null
        }
        """
        
        do {
            NSLog("📡 PerplexityService: Making API request for app info by name...")
            let response = try await makeAPIRequest(prompt: prompt, maxTokens: 300, temperature: 0.1)
            NSLog("📡 PerplexityService: Received app info by name response")
            
            // Try to parse JSON response
            if let data = response.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                
                let name = json["name"] as? String ?? appName
                let developer = json["developer"] as? String ?? "Unknown Developer"
                let privacyPolicyURL = json["privacyPolicyURL"] as? String
                
                NSLog("✅ PerplexityService: Successfully parsed app info by name - \(name) by \(developer)")
                return (name: name, developer: developer, privacyPolicyURL: privacyPolicyURL)
            }
            
            NSLog("❌ PerplexityService: Could not parse JSON response for app name")
            return nil
            
        } catch {
            NSLog("❌ PerplexityService: Error getting app info by name: \(error)")
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    private func makeAPIRequest(prompt: String, maxTokens: Int = 1000, temperature: Double = 0.7) async throws -> String {
        await MainActor.run {
            isLoading = true
            errorMessage = ""
        }
        
        NSLog("🔍 PerplexityService: Making API request to: \(baseURL)")
        NSLog("🔑 PerplexityService: Using API key: \(apiKey.prefix(8))...")
        
        guard let url = URL(string: baseURL) else {
            NSLog("❌ PerplexityService: Invalid URL: \(baseURL)")
            throw PerplexityError.invalidURL
        }
        
        let request = PerplexityRequest(
            model: "sonar",
            messages: [PerplexityMessage(role: "user", content: prompt)],
            maxTokens: maxTokens,
            temperature: temperature
        )
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        NSLog("📡 PerplexityService: Request headers:")
        NSLog("   - Content-Type: application/json")
        NSLog("   - Authorization: Bearer \(apiKey.prefix(8))...")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
            NSLog("✅ PerplexityService: Request body encoded successfully")
        } catch {
            NSLog("❌ PerplexityService: Failed to encode request body: \(error)")
            throw PerplexityError.encodingError(error)
        }
        
        NSLog("📤 PerplexityService: Sending request...")
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            NSLog("❌ PerplexityService: Invalid response type")
            throw PerplexityError.invalidResponse
        }
        
        NSLog("📥 PerplexityService: Received response with status code: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            NSLog("❌ PerplexityService: API error \(httpResponse.statusCode): \(errorMessage)")
            NSLog("📄 PerplexityService: Response headers: \(httpResponse.allHeaderFields)")
            throw PerplexityError.apiError(httpResponse.statusCode, errorMessage)
        }
        
        let perplexityResponse = try JSONDecoder().decode(PerplexityResponse.self, from: data)
        
        guard let content = perplexityResponse.choices.first?.message.content else {
            throw PerplexityError.noContent
        }
        
        await MainActor.run {
            isLoading = false
            lastResponse = content
        }
        
        return content
    }
    
    private func extractURL(from text: String) -> String? {
        // Simple URL extraction - look for http/https URLs
        let urlPattern = "https?://[^\\s]+"
        let regex = try? NSRegularExpression(pattern: urlPattern)
        let range = NSRange(text.startIndex..., in: text)
        
        if let match = regex?.firstMatch(in: text, range: range) {
            return String(text[Range(match.range, in: text)!])
        }
        
        return nil
    }
}

// MARK: - Error Handling

enum PerplexityError: LocalizedError {
    case invalidURL
    case encodingError(Error)
    case invalidResponse
    case apiError(Int, String)
    case noContent
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let code, let message):
            return "API Error \(code): \(message)"
        case .noContent:
            return "No content generated"
        }
    }
}

// MARK: - Configuration Manager

class PerplexityConfig {
    static let shared = PerplexityConfig()
    
    private init() {}
    
    var apiKey: String {
        // First try environment variable
        if let envVar = ProcessInfo.processInfo.environment["PERPLEXITY_API_KEY"], !envVar.isEmpty {
            NSLog("🔑 PerplexityConfig: Found API key in environment variable")
            return envVar
        }
        
        // Try to read from .env file as fallback
        if let envKey = readFromEnvFile() {
            NSLog("🔑 PerplexityConfig: Found API key in .env file")
            return envKey
        }
        
        // Log that no API key was found
        NSLog("❌ PerplexityConfig: No API key found in environment or .env file")
        return "xxxxx"
    }
    
    var isConfigured: Bool {
        let key = apiKey
        let configured = key != "xxxxx" && !key.isEmpty
        NSLog("🔑 PerplexityConfig: API key configured: \(configured)")
        return configured
    }
    
    private func readFromEnvFile() -> String? {
        // Look for .env file in multiple possible locations
        let possiblePaths = [
            // Current working directory
            FileManager.default.currentDirectoryPath + "/.env",
            // Project root directory (where the script is run from)
            "/Users/sridatta.bandreddi/Desktop/code/hackCMU2025/.env",
            // Home directory
            NSHomeDirectory() + "/.env",
            // Bundle resource path (if running from Xcode)
            Bundle.main.resourcePath?.appending("/.env") ?? ""
        ]
        
        for envPath in possiblePaths {
            NSLog("🔍 PerplexityConfig: Looking for .env file at: \(envPath)")
            
            if FileManager.default.fileExists(atPath: envPath) {
                NSLog("✅ PerplexityConfig: Found .env file at: \(envPath)")
                return readEnvFile(at: envPath)
            }
        }
        
        NSLog("❌ PerplexityConfig: .env file not found in any expected location")
        return nil
    }
    
    private func readEnvFile(at path: String) -> String? {
        
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            
            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Skip empty lines and comments
                if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") {
                    continue
                }
                
                // Look for PERPLEXITY_API_KEY=
                if trimmedLine.hasPrefix("PERPLEXITY_API_KEY=") {
                    let key = String(trimmedLine.dropFirst(20)) // Remove "PERPLEXITY_API_KEY="
                    let cleanKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Return the key if it's not empty and not a placeholder
                    if !cleanKey.isEmpty && !cleanKey.contains("your_") {
                        NSLog("✅ PerplexityConfig: Found valid API key in .env file")
                        return cleanKey
                    }
                }
            }
        } catch {
            NSLog("❌ PerplexityConfig: Error reading .env file at \(path): \(error)")
        }
        
        NSLog("❌ PerplexityConfig: No valid API key found in .env file")
        return nil
    }
}
