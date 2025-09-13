import Foundation

// MARK: - Quiz Models
struct QuizQuestion: Codable, Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String
    let difficulty: QuizDifficulty
    let category: QuizCategory
    let points: Int
    
    enum CodingKeys: String, CodingKey {
        case question, options, correctAnswer, explanation, difficulty, category, points
    }
}

enum QuizDifficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var color: String {
        switch self {
        case .easy: return "green"
        case .medium: return "orange"
        case .hard: return "red"
        }
    }
    
    var points: Int {
        switch self {
        case .easy: return 10
        case .medium: return 20
        case .hard: return 30
        }
    }
}

enum QuizCategory: String, Codable, CaseIterable {
    case general = "General Security"
    case filevault = "FileVault"
    case firewall = "Firewall"
    case privacy = "Privacy"
    case encryption = "Encryption"
    case authentication = "Authentication"
    case networking = "Networking"
    case system = "System Security"
    
    var icon: String {
        switch self {
        case .general: return "shield.checkered"
        case .filevault: return "lock.fill"
        case .firewall: return "network"
        case .privacy: return "eye.slash.fill"
        case .encryption: return "key.fill"
        case .authentication: return "person.badge.key.fill"
        case .networking: return "wifi"
        case .system: return "gear"
        }
    }
}

struct QuizSession: Codable {
    let id = UUID()
    let questions: [QuizQuestion]
    let answers: [Int?]
    let score: Int
    let totalPoints: Int
    let completedAt: Date
    let timeSpent: TimeInterval
    
    enum CodingKeys: String, CodingKey {
        case questions, answers, score, totalPoints, completedAt, timeSpent
    }
    
    var percentage: Double {
        guard totalPoints > 0 else { return 0 }
        return Double(score) / Double(totalPoints) * 100
    }
    
    var grade: QuizGrade {
        switch percentage {
        case 90...100: return .excellent
        case 80..<90: return .good
        case 70..<80: return .satisfactory
        case 60..<70: return .needsImprovement
        default: return .poor
        }
    }
}

enum QuizGrade: String, CaseIterable {
    case excellent = "Excellent"
    case good = "Good"
    case satisfactory = "Satisfactory"
    case needsImprovement = "Needs Improvement"
    case poor = "Poor"
    
    var emoji: String {
        switch self {
        case .excellent: return "🥷"
        case .good: return "👍"
        case .satisfactory: return "👌"
        case .needsImprovement: return "📚"
        case .poor: return "💪"
        }
    }
    
    var color: String {
        switch self {
        case .excellent: return "green"
        case .good: return "blue"
        case .satisfactory: return "orange"
        case .needsImprovement: return "yellow"
        case .poor: return "red"
        }
    }
    
    var message: String {
        switch self {
        case .excellent: return "Outstanding! You're a security master!"
        case .good: return "Great job! You have solid security knowledge."
        case .satisfactory: return "Good work! Keep learning to improve."
        case .needsImprovement: return "Keep studying! You're on the right track."
        case .poor: return "Don't give up! Practice makes perfect."
        }
    }
}

// MARK: - Quiz Generation Request
struct QuizGenerationRequest: Codable {
    let topic: String
    let difficulty: QuizDifficulty
    let category: QuizCategory
    let numberOfQuestions: Int
}

// MARK: - AI Response Models for Structured Output
struct QuizGenerationResponse: Codable {
    let questions: [GeneratedQuestion]
}

struct GeneratedQuestion: Codable {
    let question: String
    let options: [String]
    let correctAnswer: Int // 0-based index
    let explanation: String
    let difficulty: String
    let category: String
    let points: Int
}
