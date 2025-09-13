import Foundation
import SwiftUI

// MARK: - Ninja Level System
enum NinjaLevel: String, CaseIterable {
    case novice = "Novice Ninja"
    case apprentice = "Apprentice Ninja"
    case master = "Master Ninja"
    
    var xpThreshold: Int {
        switch self {
        case .novice: return 0
        case .apprentice: return 200
        case .master: return 400
        }
    }
    
    var nextLevelXP: Int {
        switch self {
        case .novice: return 200
        case .apprentice: return 400
        case .master: return 600
        }
    }
    
    var color: Color {
        switch self {
        case .novice: return .gray
        case .apprentice: return .red
        case .master: return .black
        }
    }
}

// MARK: - Mission System
struct Mission: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let xpReward: Int
    let isCompleted: Bool
    let fixInstructions: String
}

// MARK: - Ninja Game Model
class NinjaGameModel: ObservableObject {
    @AppStorage("currentXP") var currentXP: Int = 0
    @AppStorage("currentLevel") var currentLevelRaw: String = NinjaLevel.novice.rawValue
    
    var currentLevel: NinjaLevel {
        get { NinjaLevel(rawValue: currentLevelRaw) ?? .novice }
        set { currentLevelRaw = newValue.rawValue }
    }
    
    var progressToNextLevel: Double {
        let currentLevelXP = currentLevel.xpThreshold
        let nextLevelXP = currentLevel.nextLevelXP
        let progressXP = currentXP - currentLevelXP
        let totalXPNeeded = nextLevelXP - currentLevelXP
        
        return totalXPNeeded > 0 ? Double(progressXP) / Double(totalXPNeeded) : 1.0
    }
    
    func addXP(_ xp: Int) {
        currentXP += xp
        checkLevelUp()
    }
    
    private func checkLevelUp() {
        let newLevel = NinjaLevel.allCases.last { level in
            currentXP >= level.xpThreshold
        } ?? .novice
        
        if newLevel != currentLevel {
            currentLevel = newLevel
        }
    }
    
    func createMissions(from scanResults: [SecurityScanResult]) -> [Mission] {
        return scanResults.map { result in
            Mission(
                title: result.name,
                description: result.message,
                xpReward: result.passed ? 0 : 100,
                isCompleted: result.passed,
                fixInstructions: result.fixInstructions
            )
        }
    }
}