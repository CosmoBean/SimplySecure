import Foundation

// MARK: - Gemini API Models
struct GeminiRequest: Codable {
    let contents: [Content]
    let generationConfig: GenerationConfig?
    
    init(prompt: String, temperature: Double = 0.7, maxTokens: Int = 1000) {
        self.contents = [Content(parts: [Part(text: prompt)])]
        self.generationConfig = GenerationConfig(
            temperature: temperature,
            maxOutputTokens: maxTokens
        )
    }
}

struct Content: Codable {
    let parts: [Part]
}

struct Part: Codable {
    let text: String
}

struct GenerationConfig: Codable {
    let temperature: Double
    let maxOutputTokens: Int
}

struct GeminiResponse: Codable {
    let candidates: [Candidate]?
    let error: GeminiError?
}

struct Candidate: Codable {
    let content: Content
    let finishReason: String?
    let safetyRatings: [SafetyRating]?
}

struct SafetyRating: Codable {
    let category: String
    let probability: String
}

struct GeminiError: Codable {
    let code: Int?
    let message: String?
    let status: String?
}

// MARK: - Gemini API Service
class GeminiAPIService: ObservableObject {
    @Published var isLoading = false
    @Published var lastResponse: String = ""
    @Published var errorMessage: String = ""
    
    private let apiKey: String
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: - Public Methods
    func generateText(prompt: String, temperature: Double = 0.7, maxTokens: Int = 1000) async {
        print("🚀 Starting Gemini API request...")
        print("🔑 API Key configured: \(apiKey.prefix(10))...")
        print("📝 Prompt length: \(prompt.count) characters")
        
        await MainActor.run {
            isLoading = true
            errorMessage = ""
        }
        
        do {
            let response = try await makeAPIRequest(prompt: prompt, temperature: temperature, maxTokens: maxTokens)
            
            await MainActor.run {
                isLoading = false
                lastResponse = response
                print("✅ API request successful, response length: \(response.count)")
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
                print("❌ API request failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private Methods
    private func makeAPIRequest(prompt: String, temperature: Double, maxTokens: Int) async throws -> String {
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            throw GeminiAPIError.invalidURL
        }
        
        let request = GeminiRequest(prompt: prompt, temperature: temperature, maxTokens: maxTokens)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            throw GeminiAPIError.encodingError(error)
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiAPIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorResponse = try? JSONDecoder().decode(GeminiResponse.self, from: data)
            let errorMessage = errorResponse?.error?.message ?? "Unknown error"
            throw GeminiAPIError.apiError(httpResponse.statusCode, errorMessage)
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        
        guard let candidate = geminiResponse.candidates?.first,
              let text = candidate.content.parts.first?.text else {
            throw GeminiAPIError.noContent
        }
        
        return text
    }
}

// MARK: - Error Handling
enum GeminiAPIError: LocalizedError {
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
class GeminiConfig {
    static let shared = GeminiConfig()
    
    private init() {}
    
    var apiKey: String {
        // Simple approach: try to read from .env file first
        if let envKey = readFromEnvFile() {
            return envKey
        }
        
        // Fallback to environment variable
        if let envVar = ProcessInfo.processInfo.environment["GEMINI_API_KEY"], !envVar.isEmpty {
            return envVar
        }
        
        // Fallback to placeholder
        return "xxxxx"
    }
    
    var isConfigured: Bool {
        let key = apiKey
        return key != "xxxxx" && !key.isEmpty
    }
    
    private func readFromEnvFile() -> String? {
        // Look for .env file in current directory
        let currentDir = FileManager.default.currentDirectoryPath
        let envPath = "\(currentDir)/.env"
        
        guard FileManager.default.fileExists(atPath: envPath) else {
            return nil
        }
        
        do {
            let content = try String(contentsOfFile: envPath, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            
            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Skip empty lines and comments
                if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") {
                    continue
                }
                
                // Look for GEMINI_API_KEY=
                if trimmedLine.hasPrefix("GEMINI_API_KEY=") {
                    let key = String(trimmedLine.dropFirst(16)) // Remove "GEMINI_API_KEY="
                    let cleanKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Return the key if it's not empty and not a placeholder
                    if !cleanKey.isEmpty && !cleanKey.contains("your_") {
                        return cleanKey
                    }
                }
            }
        } catch {
            print("Error reading .env file: \(error)")
        }
        
        return nil
    }
}
