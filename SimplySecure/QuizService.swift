import Foundation
import Combine

// MARK: - Quiz Service
class QuizService: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var currentQuiz: [QuizQuestion] = []
    @Published var currentSession: QuizSession?
    
    private let geminiService: GeminiAPIService
    private let securityContent = """
    # macOS Security and Privacy Guide
    
    ## FileVault
    FileVault 2 provides full-disk encryption for macOS. It uses XTS-AES-128 encryption with a 256-bit key to help prevent unauthorized access to information on your startup disk. FileVault 2 is available in OS X Lion or later and is enabled through System Preferences > Security & Privacy > FileVault.
    
    ## Firewall
    The macOS firewall is designed to prevent unauthorized network connections. It can be configured to block incoming connections entirely or allow connections only for specific applications. The firewall should be enabled and configured to "Block all incoming connections" for maximum security.
    
    ## Privacy Settings
    macOS includes comprehensive privacy controls that let you control which apps can access your personal information, including:
    - Location Services
    - Contacts
    - Calendars
    - Reminders
    - Photos
    - Camera
    - Microphone
    - Speech Recognition
    - Accessibility
    - Analytics & Improvements
    - Advertising
    
    ## System Integrity Protection (SIP)
    SIP is a security technology that helps prevent potentially malicious software from modifying protected files and folders on your Mac. It protects system files, processes, and directories from being modified, even by users with administrator privileges.
    
    ## Gatekeeper
    Gatekeeper is a security feature that helps protect your Mac from malicious software by ensuring that only trusted software runs on your Mac. It can be configured to allow apps downloaded from:
    - Mac App Store only
    - Mac App Store and identified developers
    - Anywhere (not recommended)
    
    ## Automatic Updates
    Keeping macOS up to date is crucial for security. macOS can automatically download and install updates, including security updates. This should be enabled to ensure your system receives the latest security patches.
    
    ## Strong Passwords and Authentication
    - Use strong, unique passwords for all accounts
    - Enable two-factor authentication where available
    - Consider using a password manager
    - Use Touch ID or Face ID when available
    
    ## Network Security
    - Use a VPN when connecting to public Wi-Fi
    - Configure DNS settings for better privacy (e.g., Cloudflare DNS: 1.1.1.1)
    - Disable unnecessary network services
    - Use HTTPS whenever possible
    
    ## Encryption
    - Enable FileVault for full-disk encryption
    - Use encrypted external drives
    - Consider using encrypted messaging apps
    - Store sensitive documents in encrypted containers
    
    ## Backup Security
    - Use Time Machine with encryption
    - Store backups securely
    - Test backup restoration regularly
    - Consider offsite backup solutions
    """
    
    init(apiKey: String) {
        self.geminiService = GeminiAPIService(apiKey: apiKey)
        print("🔧 QuizService initialized with API key: \(apiKey.prefix(10))...")
    }
    
    // MARK: - Public Methods
    func generateQuiz(
        topic: String = "macOS Security",
        difficulty: QuizDifficulty = .medium,
        category: QuizCategory = .general,
        numberOfQuestions: Int = 5
    ) async {
        await MainActor.run {
            isLoading = true
            errorMessage = ""
        }
        
        do {
            let prompt = createQuizPrompt(topic: topic, difficulty: difficulty, category: category, numberOfQuestions: numberOfQuestions)
            let response = try await generateQuizWithAI(prompt: prompt)
            
            await MainActor.run {
                self.currentQuiz = response
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func submitAnswer(questionIndex: Int, answer: Int) {
        // This will be used to track answers during the quiz
    }
    
    func completeQuiz(answers: [Int?], timeSpent: TimeInterval) -> QuizSession {
        let score = calculateScore(answers: answers)
        let totalPoints = currentQuiz.reduce(0) { $0 + $1.points }
        
        let session = QuizSession(
            questions: currentQuiz,
            answers: answers,
            score: score,
            totalPoints: totalPoints,
            completedAt: Date(),
            timeSpent: timeSpent
        )
        
        currentSession = session
        return session
    }
    
    func resetQuiz() {
        currentQuiz = []
        currentSession = nil
        errorMessage = ""
    }
    
    // MARK: - Private Methods
    private func createQuizPrompt(topic: String, difficulty: QuizDifficulty, category: QuizCategory, numberOfQuestions: Int) -> String {
        return """
        Based on the following macOS security and privacy information, create exactly \(numberOfQuestions) multiple choice questions.
        
        Topic Focus: \(topic)
        Difficulty Level: \(difficulty.rawValue)
        Category: \(category.rawValue)
        
        Security Content:
        \(securityContent)
        
        Please create questions that are:
        1. Based specifically on the provided macOS security information
        2. Appropriate for \(difficulty.rawValue.lowercased()) difficulty level
        3. Focused on \(category.rawValue) topics
        4. Clear and concise with 4 answer options each
        5. Include detailed explanations for the correct answers
        
        IMPORTANT: Return ONLY a valid JSON object with this exact structure. Do not include any explanatory text before or after the JSON:
        
        {
            "questions": [
                {
                    "question": "Your question text here?",
                    "options": ["Option A", "Option B", "Option C", "Option D"],
                    "correctAnswer": 0,
                    "explanation": "Detailed explanation of why this answer is correct",
                    "difficulty": "\(difficulty.rawValue)",
                    "category": "\(category.rawValue)",
                    "points": \(difficulty.points)
                }
            ]
        }
        
        CRITICAL REQUIREMENTS:
        1. Return ONLY the JSON object, no markdown formatting, no code blocks
        2. The correctAnswer must be 0, 1, 2, or 3 (0-based index)
        3. Each question must have exactly 4 options
        4. Difficulty must be exactly: "Easy", "Medium", or "Hard"
        5. Category must be exactly: "General Security", "FileVault", "Firewall", "Privacy", "Encryption", "Authentication", "Networking", or "System Security"
        6. Points must match the difficulty: Easy=10, Medium=20, Hard=30
        """
    }
    
    private func generateQuizWithAI(prompt: String) async throws -> [QuizQuestion] {
        await geminiService.generateText(prompt: prompt, temperature: 0.3, maxTokens: 2000)
        
        // Check for API errors first
        if !geminiService.errorMessage.isEmpty {
            print("❌ Gemini API Error: \(geminiService.errorMessage)")
            throw QuizError.parsingError("API Error: \(geminiService.errorMessage)")
        }
        
        guard !geminiService.lastResponse.isEmpty else {
            print("❌ No response from Gemini API")
            throw QuizError.noResponse
        }
        
        print("✅ Received response from Gemini API: \(geminiService.lastResponse.prefix(100))...")
        
        // Try to parse the JSON response
        let jsonString = extractJSONFromResponse(geminiService.lastResponse)
        print("📄 Extracted JSON: \(jsonString.prefix(200))...")
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("❌ Failed to convert JSON string to data")
            throw QuizError.invalidJSON
        }
        
        do {
            let response = try JSONDecoder().decode(QuizGenerationResponse.self, from: jsonData)
            print("✅ Successfully parsed \(response.questions.count) questions")
            
            let validQuestions: [QuizQuestion] = response.questions.compactMap { generatedQuestion -> QuizQuestion? in
                guard let difficulty = QuizDifficulty(rawValue: generatedQuestion.difficulty),
                      let category = QuizCategory(rawValue: generatedQuestion.category) else {
                    print("❌ Invalid difficulty or category: \(generatedQuestion.difficulty), \(generatedQuestion.category)")
                    return nil
                }
                
                // Validate question structure
                guard !generatedQuestion.question.isEmpty,
                      generatedQuestion.options.count == 4,
                      generatedQuestion.correctAnswer >= 0 && generatedQuestion.correctAnswer < 4,
                      !generatedQuestion.explanation.isEmpty else {
                    print("❌ Invalid question structure: \(generatedQuestion.question.prefix(50))...")
                    return nil
                }
                
                return QuizQuestion(
                    question: generatedQuestion.question,
                    options: generatedQuestion.options,
                    correctAnswer: generatedQuestion.correctAnswer,
                    explanation: generatedQuestion.explanation,
                    difficulty: difficulty,
                    category: category,
                    points: generatedQuestion.points
                )
            }
            
            guard !validQuestions.isEmpty else {
                throw QuizError.parsingError("No valid questions found in AI response")
            }
            
            print("✅ Created \(validQuestions.count) valid questions")
            return validQuestions
            
        } catch {
            print("❌ JSON parsing error: \(error)")
            print("❌ Raw JSON: \(jsonString)")
            print("❌ JSON Data length: \(jsonData.count) bytes")
            
            // Try to provide more specific error information
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("❌ Missing key: \(key) at path: \(context.codingPath)")
                case .valueNotFound(let type, let context):
                    print("❌ Missing value of type: \(type) at path: \(context.codingPath)")
                case .typeMismatch(let type, let context):
                    print("❌ Type mismatch for type: \(type) at path: \(context.codingPath)")
                case .dataCorrupted(let context):
                    print("❌ Data corrupted at path: \(context.codingPath)")
                @unknown default:
                    print("❌ Unknown decoding error")
                }
            }
            
            throw QuizError.parsingError("Failed to parse quiz response: \(error.localizedDescription)")
        }
    }
    
    private func extractJSONFromResponse(_ response: String) -> String {
        print("🔍 Extracting JSON from response: \(response.prefix(300))...")
        
        // Method 1: Look for JSON in markdown code blocks
        let jsonPattern = "```(?:json)?\\s*([\\s\\S]*?)```"
        if let regex = try? NSRegularExpression(pattern: jsonPattern, options: [.caseInsensitive]),
           let match = regex.firstMatch(in: response, options: [], range: NSRange(location: 0, length: response.utf16.count)),
           let jsonRange = Range(match.range(at: 1), in: response) {
            let extracted = String(response[jsonRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            print("✅ Found JSON in code block: \(extracted.prefix(200))...")
            return extracted
        }
        
        // Method 2: Look for JSON object directly
        if let startIndex = response.range(of: "{\"questions\""),
           let endIndex = response.range(of: "}", range: startIndex.upperBound..<response.endIndex) {
            let extracted = String(response[startIndex.lowerBound...endIndex.upperBound])
            print("✅ Found JSON object directly: \(extracted.prefix(200))...")
            return extracted
        }
        
        // Method 3: Find first { and last } and extract everything between
        if let firstBrace = response.firstIndex(of: "{"),
           let lastBrace = response.lastIndex(of: "}"),
           firstBrace < lastBrace {
            let extracted = String(response[firstBrace...lastBrace])
            print("✅ Extracted JSON from braces: \(extracted.prefix(200))...")
            return extracted
        }
        
        // Method 4: Try to clean up the response and use as-is
        let cleaned = response
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("⚠️ Using cleaned response as JSON: \(cleaned.prefix(200))...")
        return cleaned
    }
    
    private func calculateScore(answers: [Int?]) -> Int {
        var score = 0
        
        for (index, answer) in answers.enumerated() {
            guard index < currentQuiz.count,
                  let userAnswer = answer,
                  userAnswer == currentQuiz[index].correctAnswer else {
                continue
            }
            
            score += currentQuiz[index].points
        }
        
        return score
    }
}

// MARK: - Quiz Errors
enum QuizError: LocalizedError {
    case noResponse
    case invalidJSON
    case parsingError(String)
    
    var errorDescription: String? {
        switch self {
        case .noResponse:
            return "No response received from AI service"
        case .invalidJSON:
            return "Invalid JSON response from AI service"
        case .parsingError(let message):
            return "Error parsing quiz data: \(message)"
        }
    }
}
