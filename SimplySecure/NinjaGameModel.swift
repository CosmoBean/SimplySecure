import Foundation
import SwiftUI
import SwiftData

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
    
    var profileImageName: String {
        switch self {
        case .novice: return "1"
        case .apprentice: return "2"
        case .master: return "3"
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
    @Published var currentUser: User?
    private var modelContext: ModelContext?
    
    // Computed properties for backward compatibility
    var currentXP: Int {
        return currentUser?.currentXP ?? 0
    }
    
    var currentLevel: NinjaLevel {
        return currentUser?.ninjaLevel ?? .novice
    }
    
    var progressToNextLevel: Double {
        return currentUser?.progressToNextLevel ?? 0.0
    }
    
    func setup(with modelContext: ModelContext) {
        self.modelContext = modelContext
        loadOrCreateUser()
    }
    
    private func loadOrCreateUser() {
        guard let modelContext = modelContext else { return }
        
        // Try to fetch existing user
        let descriptor = FetchDescriptor<User>()
        
        do {
            let users = try modelContext.fetch(descriptor)
            if let existingUser = users.first {
                currentUser = existingUser
                currentUser?.updateLastLogin()
            } else {
                // Create new user
                let newUser = User()
                currentUser = newUser
                modelContext.insert(newUser)
                try modelContext.save()
            }
        } catch {
            print("Error loading user: \(error)")
            // Fallback: create new user
            let newUser = User()
            currentUser = newUser
            modelContext.insert(newUser)
            try? modelContext.save()
        }
    }
    
    func addXP(_ xp: Int) {
        guard let user = currentUser, let modelContext = modelContext else { return }
        
        user.addXP(xp)
        
        do {
            try modelContext.save()
            objectWillChange.send() // Notify UI of changes
        } catch {
            print("Error saving XP: \(error)")
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
    
    // MARK: - Demo Functions
    
    /// Resets the user's XP to 0 and level to Novice for demo purposes
    func resetUserXP() {
        guard let user = currentUser, let modelContext = modelContext else {
            print("⚠️ Demo: Cannot reset XP - no user or model context available")
            return
        }
        
        let oldXP = user.currentXP
        let oldLevel = user.currentLevel
        
        user.currentXP = 0
        user.currentLevel = "Novice Ninja"
        
        do {
            try modelContext.save()
            
            print("🎮 Demo Reset Complete:")
            print("   Previous XP: \(oldXP)")
            print("   Previous Level: \(oldLevel)")
            print("   New XP: \(user.currentXP)")
            print("   New Level: \(user.currentLevel)")
            print("   ✅ User profile has been reset for demo!")
            
            objectWillChange.send()
            
        } catch {
            print("❌ Demo: Failed to save reset changes: \(error)")
        }
    }
    
    /// Adds a specific amount of XP for demo purposes
    func addDemoXP(_ amount: Int) {
        guard let user = currentUser, let modelContext = modelContext else {
            print("⚠️ Demo: Cannot add XP - no user or model context available")
            return
        }
        
        let oldXP = user.currentXP
        let oldLevel = user.currentLevel
        
        user.addXP(amount)
        
        do {
            try modelContext.save()
            
            print("🎮 Demo XP Added:")
            print("   Added: \(amount) XP")
            print("   Previous XP: \(oldXP) → New XP: \(user.currentXP)")
            print("   Previous Level: \(oldLevel) → New Level: \(user.currentLevel)")
            
            objectWillChange.send()
            
        } catch {
            print("❌ Demo: Failed to save XP changes: \(error)")
        }
    }
    
    /// Sets the user to a specific level for demo purposes
    func setDemoLevel(_ targetLevel: String) {
        guard let user = currentUser, let modelContext = modelContext else {
            print("⚠️ Demo: Cannot set level - no user or model context available")
            return
        }
        
        guard let level = NinjaLevel(rawValue: targetLevel) else {
            print("❌ Demo: Invalid level '\(targetLevel)'. Valid levels are:")
            for validLevel in NinjaLevel.allCases {
                print("   - \(validLevel.rawValue)")
            }
            return
        }
        
        let oldXP = user.currentXP
        let oldLevel = user.currentLevel
        
        user.currentXP = level.xpThreshold
        user.currentLevel = targetLevel
        
        do {
            try modelContext.save()
            
            print("🎮 Demo Level Set:")
            print("   Target Level: \(targetLevel)")
            print("   Previous XP: \(oldXP) → New XP: \(user.currentXP)")
            print("   Previous Level: \(oldLevel) → New Level: \(user.currentLevel)")
            print("   ✅ User level has been set for demo!")
            
            objectWillChange.send()
            
        } catch {
            print("❌ Demo: Failed to save level changes: \(error)")
        }
    }
}