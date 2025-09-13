import Foundation

// MARK: - Privacy Policy Analyzer

class PrivacyPolicyAnalyzer: ObservableObject {
    private let geminiService: GeminiAPIService
    
    init(geminiService: GeminiAPIService) {
        self.geminiService = geminiService
    }
    
    // MARK: - Main Analysis Method
    
    func analyzePrivacyPolicy(url: String) async -> PrivacyPolicyAnalysis? {
        NSLog("🔍 PrivacyPolicyAnalyzer: Starting analysis for \(url)")
        
        do {
            // Fetch the privacy policy content
            NSLog("📥 PrivacyPolicyAnalyzer: Downloading privacy policy content...")
            guard let content = try await fetchPrivacyPolicyContent(from: url) else {
                NSLog("❌ PrivacyPolicyAnalyzer: Failed to fetch content from \(url)")
                return createFallbackAnalysis()
            }
            
            NSLog("✅ PrivacyPolicyAnalyzer: Successfully downloaded privacy policy (\(content.count) characters)")
            
            // Log first 3 lines of the privacy policy content
            NSLog("📄 Privacy Policy Content Preview:")
            let contentLines = content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            for (index, line) in contentLines.prefix(3).enumerated() {
                NSLog("   Line \(index + 1): \(line.trimmingCharacters(in: .whitespacesAndNewlines))")
            }
            
            // Analyze the content using AI
            NSLog("🤖 PrivacyPolicyAnalyzer: Analyzing content with AI...")
            let analysis = try await analyzeContentWithAI(content)
            
            NSLog("✅ PrivacyPolicyAnalyzer: Analysis completed with score \(analysis.overallScore)")
            return analysis
            
        } catch {
            NSLog("❌ PrivacyPolicyAnalyzer: Error during analysis: \(error)")
            return createFallbackAnalysis()
        }
    }
    
    // MARK: - Content Fetching
    
    private func fetchPrivacyPolicyContent(from url: String) async throws -> String? {
        guard let policyURL = URL(string: url) else {
            throw PrivacyPolicyError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: policyURL)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw PrivacyPolicyError.fetchFailed
        }
        
        // Try to extract text content from HTML
        let htmlContent = String(data: data, encoding: .utf8) ?? ""
        let textContent = extractTextFromHTML(htmlContent)
        
        return textContent.isEmpty ? htmlContent : textContent
    }
    
    private func extractTextFromHTML(_ html: String) -> String {
        // Simple HTML tag removal - in a production app, you'd use a proper HTML parser
        var text = html
        
        // Remove script and style tags and their content
        text = text.replacingOccurrences(of: "<script[^>]*>.*?</script>", with: "", options: [.regularExpression, .caseInsensitive])
        text = text.replacingOccurrences(of: "<style[^>]*>.*?</style>", with: "", options: [.regularExpression, .caseInsensitive])
        
        // Remove HTML tags
        text = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        // Decode HTML entities
        text = text.replacingOccurrences(of: "&amp;", with: "&")
        text = text.replacingOccurrences(of: "&lt;", with: "<")
        text = text.replacingOccurrences(of: "&gt;", with: ">")
        text = text.replacingOccurrences(of: "&quot;", with: "\"")
        text = text.replacingOccurrences(of: "&#39;", with: "'")
        
        // Clean up whitespace
        text = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return text
    }
    
    // MARK: - AI Analysis
    
    private func analyzeContentWithAI(_ content: String) async throws -> PrivacyPolicyAnalysis {
        let prompt = createAnalysisPrompt(for: content)
        
        // Use Gemini API for analysis
        await geminiService.generateText(prompt: prompt, temperature: 0.3, maxTokens: 2000)
        
        let aiResponse = geminiService.lastResponse
        if aiResponse.isEmpty {
            throw PrivacyPolicyError.aiAnalysisFailed
        }
        
        return parseAIAnalysis(aiResponse)
    }
    
    private func createAnalysisPrompt(for content: String) -> String {
        let truncatedContent = String(content.prefix(8000)) // Limit content size
        
        return """
        Analyze the following privacy policy and provide a structured assessment. Focus on data collection practices, third-party sharing, security measures, and overall privacy friendliness.

        Privacy Policy Content:
        \(truncatedContent)

        Please provide your analysis in the following JSON format:
        {
            "dataCollection": {
                "collectsPersonalData": true/false,
                "dataTypes": ["list of data types collected"],
                "purpose": "stated purpose for data collection",
                "consentRequired": true/false
            },
            "thirdPartySharing": {
                "sharesWithThirdParties": true/false,
                "thirdParties": ["list of third parties"],
                "purpose": "purpose of sharing",
                "optOutAvailable": true/false
            },
            "dataRetention": {
                "retentionPeriod": "how long data is kept",
                "deletionPolicy": "data deletion policy",
                "userControl": true/false
            },
            "securityMeasures": {
                "encryption": true/false,
                "securityStandards": ["list of security measures"],
                "breachNotification": true/false
            },
            "overallScore": 85,
            "recommendation": "excellent/good/fair/poor/concerning",
            "concerns": ["list of privacy concerns"],
            "positives": ["list of positive privacy practices"]
        }

        Base your assessment on:
        1. Transparency of data collection
        2. Necessity of data collection
        3. Third-party sharing practices
        4. Data retention policies
        5. Security measures
        6. User control and rights
        7. Clarity of language

        Provide a score from 0-100 where:
        - 90-100: Excellent privacy practices
        - 70-89: Good privacy practices
        - 50-69: Fair privacy practices
        - 30-49: Poor privacy practices
        - 0-29: Concerning privacy practices
        """
    }
    
    private func parseAIAnalysis(_ response: String) -> PrivacyPolicyAnalysis {
        // Try to extract JSON from the response
        let jsonPattern = "\\{[\\s\\S]*\\}"
        let regex = try? NSRegularExpression(pattern: jsonPattern)
        let range = NSRange(response.startIndex..., in: response)
        
        var jsonString = response
        if let match = regex?.firstMatch(in: response, range: range) {
            jsonString = String(response[Range(match.range, in: response)!])
        }
        
        // Try to parse the JSON
        if let data = jsonString.data(using: .utf8) {
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(PrivacyPolicyAnalysis.self, from: data)
            } catch {
                NSLog("🔍 PrivacyPolicyAnalyzer: Failed to parse AI response as JSON: \(error)")
            }
        }
        
        // Fallback: parse the response text manually
        return parseTextualAnalysis(response)
    }
    
    private func parseTextualAnalysis(_ response: String) -> PrivacyPolicyAnalysis {
        // Extract key information from the text response
        let lines = response.components(separatedBy: .newlines)
        
        let dataTypes: [String] = []
        let thirdParties: [String] = []
        var concerns: [String] = []
        var positives: [String] = []
        var overallScore = 50 // Default neutral score
        var recommendation = PolicyRecommendation.fair
        
        for line in lines {
            let lowercased = line.lowercased()
            
            // Extract score
            if let scoreMatch = lowercased.range(of: "score.*?(\\d+)", options: .regularExpression) {
                let scoreText = String(lowercased[scoreMatch])
                if let score = Int(scoreText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                    overallScore = score
                }
            }
            
            // Extract recommendation
            if lowercased.contains("excellent") {
                recommendation = .excellent
            } else if lowercased.contains("good") {
                recommendation = .good
            } else if lowercased.contains("poor") || lowercased.contains("concerning") {
                recommendation = lowercased.contains("concerning") ? .concerning : .poor
            }
            
            // Extract concerns
            if lowercased.contains("concern") || lowercased.contains("risk") || lowercased.contains("problem") {
                concerns.append(line.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            
            // Extract positives
            if lowercased.contains("good") || lowercased.contains("positive") || lowercased.contains("secure") {
                positives.append(line.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        
        return PrivacyPolicyAnalysis(
            dataCollection: DataCollectionInfo(
                collectsPersonalData: true,
                dataTypes: dataTypes.isEmpty ? ["Usage data", "Device information"] : dataTypes,
                purpose: "App functionality and analytics",
                consentRequired: true
            ),
            thirdPartySharing: ThirdPartySharingInfo(
                sharesWithThirdParties: thirdParties.count > 0,
                thirdParties: thirdParties.isEmpty ? ["Analytics providers"] : thirdParties,
                purpose: "Analytics and advertising",
                optOutAvailable: true
            ),
            dataRetention: DataRetentionInfo(
                retentionPeriod: "As specified in policy",
                deletionPolicy: "User can request deletion",
                userControl: true
            ),
            securityMeasures: SecurityMeasuresInfo(
                encryption: true,
                securityStandards: ["HTTPS", "Data encryption"],
                breachNotification: true
            ),
            overallScore: overallScore,
            recommendation: recommendation,
            concerns: concerns.isEmpty ? ["Policy analysis incomplete"] : concerns,
            positives: positives.isEmpty ? ["Standard privacy practices"] : positives
        )
    }
    
    // MARK: - Fallback Analysis
    
    private func createFallbackAnalysis() -> PrivacyPolicyAnalysis {
        return PrivacyPolicyAnalysis(
            dataCollection: DataCollectionInfo(
                collectsPersonalData: true,
                dataTypes: ["Usage data", "Device information"],
                purpose: "App functionality",
                consentRequired: true
            ),
            thirdPartySharing: ThirdPartySharingInfo(
                sharesWithThirdParties: true,
                thirdParties: ["Unknown"],
                purpose: "Unknown",
                optOutAvailable: false
            ),
            dataRetention: DataRetentionInfo(
                retentionPeriod: "Unknown",
                deletionPolicy: "Unknown",
                userControl: false
            ),
            securityMeasures: SecurityMeasuresInfo(
                encryption: false,
                securityStandards: [],
                breachNotification: false
            ),
            overallScore: 30,
            recommendation: .concerning,
            concerns: ["Unable to analyze privacy policy", "Limited transparency"],
            positives: []
        )
    }
}

// MARK: - Error Handling

enum PrivacyPolicyError: LocalizedError {
    case invalidURL
    case fetchFailed
    case aiAnalysisFailed
    case parsingFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid privacy policy URL"
        case .fetchFailed:
            return "Failed to fetch privacy policy content"
        case .aiAnalysisFailed:
            return "AI analysis of privacy policy failed"
        case .parsingFailed:
            return "Failed to parse privacy policy analysis"
        }
    }
}
