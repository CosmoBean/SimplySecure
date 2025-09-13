import Foundation
import SwiftData
import SwiftUI

@Model
class User {
    var id: UUID
    var username: String
    var currentXP: Int
    var currentLevel: String
    var createdAt: Date
    var lastLoginAt: Date
    
    init(username: String = "Security Ninja") {
        self.id = UUID()
        self.username = username
        self.currentXP = 0
        self.currentLevel = "Novice Ninja"
        self.createdAt = Date()
        self.lastLoginAt = Date()
    }
    
    // Computed property for level management
    var ninjaLevel: NinjaLevel {
        get { NinjaLevel(rawValue: currentLevel) ?? .novice }
        set { currentLevel = newValue.rawValue }
    }
    
    var progressToNextLevel: Double {
        let currentLevelXP = ninjaLevel.xpThreshold
        let nextLevelXP = ninjaLevel.nextLevelXP
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
        
        if newLevel != ninjaLevel {
            ninjaLevel = newLevel
        }
    }
    
    func updateLastLogin() {
        lastLoginAt = Date()
    }
}
