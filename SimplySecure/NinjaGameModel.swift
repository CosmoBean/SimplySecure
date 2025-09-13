import Foundation

// MARK: - Ninja Level System
enum NinjaLevel: String, CaseIterable {
    case novice = "Novice Ninja"
    case apprentice = "Apprentice Ninja"
    case master = "Master Ninja"
    
    var levelNumber: Int {
        switch self {
        case .novice: return 1
        case .apprentice: return 2
        case .master: return 3
        }
    }
    
    var requiredXP: Int {
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
    
    var color: String {
        switch self {
        case .novice: return "gray"
        case .apprentice: return "red"
        case .master: return "black"
        }
    }
}

// MARK: - Mission Model
struct Mission {
    let id: String
    let title: String
    let description: String
    let xpReward: Int
    let isCompleted: Bool
    let fixInstructions: String
}

// MARK: - Ninja Game Model
class NinjaGameModel: ObservableObject {
    @Published var currentXP: Int = 0
    @Published var currentLevel: NinjaLevel = .novice
    @Published var missions: [Mission] = []
    
    init() {
        loadGameData()
    }
    
    // MARK: - XP and Level Management
    func addXP(_ points: Int) {
        currentXP += points
        checkLevelUp()
        saveGameData()
    }
    
    private func checkLevelUp() {
        let newLevel = NinjaLevel.allCases.last { level in
            currentXP >= level.requiredXP
        } ?? .novice
        
        if newLevel != currentLevel {
            currentLevel = newLevel
        }
    }
    
    func getXPProgress() -> Double {
        let currentLevelXP = currentXP - currentLevel.requiredXP
        let nextLevelXP = currentLevel.nextLevelXP - currentLevel.requiredXP
        return Double(currentLevelXP) / Double(nextLevelXP)
    }
    
    // MARK: - Mission Management
    func updateMissions(from scanResults: [SecurityScanResult]) {
        missions = scanResults.map { result in
            Mission(
                id: result.name,
                title: result.name,
                description: result.message,
                xpReward: result.points,
                isCompleted: result.passed,
                fixInstructions: result.fixInstructions
            )
        }
    }
    
    func completeMission(_ missionId: String) {
        if let index = missions.firstIndex(where: { $0.id == missionId }) {
            let mission = missions[index]
            if !mission.isCompleted {
                addXP(mission.xpReward)
                missions[index] = Mission(
                    id: mission.id,
                    title: mission.title,
                    description: mission.description,
                    xpReward: mission.xpReward,
                    isCompleted: true,
                    fixInstructions: mission.fixInstructions
                )
            }
        }
    }
    
    // MARK: - Data Persistence
    private func saveGameData() {
        UserDefaults.standard.set(currentXP, forKey: "ninjaXP")
        UserDefaults.standard.set(currentLevel.rawValue, forKey: "ninjaLevel")
    }
    
    private func loadGameData() {
        currentXP = UserDefaults.standard.integer(forKey: "ninjaXP")
        let levelString = UserDefaults.standard.string(forKey: "ninjaLevel") ?? NinjaLevel.novice.rawValue
        currentLevel = NinjaLevel(rawValue: levelString) ?? .novice
    }
    
    // MARK: - Reset Game (for demo purposes)
    func resetGame() {
        currentXP = 0
        currentLevel = .novice
        missions = []
        saveGameData()
    }
}