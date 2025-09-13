import Foundation

// MARK: - Security Task Models
struct SecurityTask: Codable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let detailedInstructions: String
    let category: SecurityTaskCategory
    let difficulty: SecurityTaskDifficulty
    let estimatedTimeMinutes: Int
    let xpReward: Int
    let prerequisites: [String]
    let verificationCommand: String?
    let verificationDescription: String?
    let day: Int // Which day this task belongs to (1, 2, or 3)
    let order: Int // Order within the day
    
    enum CodingKeys: String, CodingKey {
        case title, description, detailedInstructions, category, difficulty, estimatedTimeMinutes, xpReward, prerequisites, verificationCommand, verificationDescription, day, order
    }
}

enum SecurityTaskCategory: String, Codable, CaseIterable {
    case filevault = "FileVault Encryption"
    case firewall = "Firewall Configuration"
    case privacy = "Privacy Settings"
    case authentication = "Authentication"
    case networking = "Network Security"
    case system = "System Security"
    case updates = "System Updates"
    case backup = "Backup Security"
    case monitoring = "System Monitoring"
    case general = "General Security"
    
    var icon: String {
        switch self {
        case .filevault: return "lock.fill"
        case .firewall: return "network"
        case .privacy: return "eye.slash.fill"
        case .authentication: return "person.badge.key.fill"
        case .networking: return "wifi"
        case .system: return "gear"
        case .updates: return "arrow.clockwise"
        case .backup: return "externaldrive.fill"
        case .monitoring: return "chart.line.uptrend.xyaxis"
        case .general: return "shield.checkered"
        }
    }
    
    var color: String {
        switch self {
        case .filevault: return "blue"
        case .firewall: return "red"
        case .privacy: return "purple"
        case .authentication: return "green"
        case .networking: return "orange"
        case .system: return "gray"
        case .updates: return "cyan"
        case .backup: return "brown"
        case .monitoring: return "pink"
        case .general: return "indigo"
        }
    }
}

enum SecurityTaskDifficulty: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var color: String {
        switch self {
        case .beginner: return "green"
        case .intermediate: return "orange"
        case .advanced: return "red"
        }
    }
    
    var baseXP: Int {
        switch self {
        case .beginner: return 25
        case .intermediate: return 50
        case .advanced: return 100
        }
    }
}

// MARK: - Task Completion Status
enum TaskCompletionStatus: String, Codable {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case completed = "Completed"
    case verified = "Verified"
    case failed = "Failed"
    
    var color: String {
        switch self {
        case .notStarted: return "gray"
        case .inProgress: return "blue"
        case .completed: return "orange"
        case .verified: return "green"
        case .failed: return "red"
        }
    }
    
    var icon: String {
        switch self {
        case .notStarted: return "circle"
        case .inProgress: return "clock.fill"
        case .completed: return "checkmark.circle"
        case .verified: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        }
    }
}

// MARK: - Task Progress Tracking
struct TaskProgress: Codable, Identifiable {
    let id = UUID()
    let taskId: UUID
    var status: TaskCompletionStatus
    var startedAt: Date?
    var completedAt: Date?
    var verifiedAt: Date?
    var notes: String
    var xpEarned: Int
    
    enum CodingKeys: String, CodingKey {
        case taskId, status, startedAt, completedAt, verifiedAt, notes, xpEarned
    }
}

// MARK: - Daily Challenge Set
struct DailyChallengeSet: Codable, Identifiable {
    let id = UUID()
    let day: Int
    let title: String
    let description: String
    let theme: String
    let tasks: [SecurityTask]
    let totalXP: Int
    let estimatedTimeMinutes: Int
    let completionBadge: String
    
    enum CodingKeys: String, CodingKey {
        case day, title, description, theme, tasks, totalXP, estimatedTimeMinutes, completionBadge
    }
}

// MARK: - Achievement System
struct SecurityAchievement: Codable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let category: SecurityTaskCategory
    let requirement: String
    let xpReward: Int
    let isUnlocked: Bool
    let unlockedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case title, description, icon, category, requirement, xpReward, isUnlocked, unlockedAt
    }
}

// MARK: - Security Task Service
class SecurityTaskService: ObservableObject {
    @Published var dailyChallenges: [DailyChallengeSet] = []
    @Published var taskProgress: [UUID: TaskProgress] = [:]
    @Published var achievements: [SecurityAchievement] = []
    @Published var currentDay: Int = 1
    
    private var gameModel: NinjaGameModel?
    
    init() {
        loadDailyChallenges()
        loadAchievements()
    }
    
    func setGameModel(_ gameModel: NinjaGameModel) {
        self.gameModel = gameModel
    }
    
    // MARK: - Daily Challenges Creation
    private func loadDailyChallenges() {
        dailyChallenges = [
            createDay1Challenges(),
            createDay2Challenges(),
            createDay3Challenges()
        ]
    }
    
    private func createDay1Challenges() -> DailyChallengeSet {
        let tasks = [
            SecurityTask(
                title: "Enable FileVault Encryption",
                description: "Protect your data with full-disk encryption",
                detailedInstructions: """
                1. Open System Preferences (System Settings on macOS Ventura+)
                2. Go to Security & Privacy > FileVault
                3. Click "Turn On FileVault"
                4. Choose to store the recovery key with Apple or create a local key
                5. Restart your Mac when prompted
                
                This encrypts your entire startup disk using XTS-AES-128 encryption with a 256-bit key.
                """,
                category: .filevault,
                difficulty: .beginner,
                estimatedTimeMinutes: 15,
                xpReward: 50,
                prerequisites: [],
                verificationCommand: "sudo fdesetup status",
                verificationDescription: "Check if FileVault is enabled",
                day: 1,
                order: 1
            ),
            
            SecurityTask(
                title: "Enable macOS Firewall",
                description: "Block unauthorized network connections",
                detailedInstructions: """
                1. Open System Preferences (System Settings on macOS Ventura+)
                2. Go to Security & Privacy > Firewall
                3. Click the lock icon and enter your password
                4. Click "Turn On Firewall"
                5. Click "Firewall Options" and configure:
                   - Block all incoming connections
                   - Enable stealth mode
                   - Automatically allow signed software
                
                This prevents unauthorized applications from accepting incoming connections.
                """,
                category: .firewall,
                difficulty: .beginner,
                estimatedTimeMinutes: 10,
                xpReward: 40,
                prerequisites: [],
                verificationCommand: "sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate",
                verificationDescription: "Check firewall status",
                day: 1,
                order: 2
            ),
            
            SecurityTask(
                title: "Configure Privacy Settings",
                description: "Control which apps access your personal data",
                detailedInstructions: """
                1. Open System Preferences (System Settings on macOS Ventura+)
                2. Go to Security & Privacy > Privacy
                3. Review and configure access for:
                   - Location Services
                   - Contacts
                   - Calendars
                   - Photos
                   - Camera
                   - Microphone
                4. Remove unnecessary app permissions
                5. Enable "Require password immediately after sleep or screen saver begins"
                
                This gives you granular control over your personal data.
                """,
                category: .privacy,
                difficulty: .beginner,
                estimatedTimeMinutes: 20,
                xpReward: 35,
                prerequisites: [],
                verificationCommand: "defaults read com.apple.screensaver askForPassword",
                verificationDescription: "Check if password is required after screensaver",
                day: 1,
                order: 3
            ),
            
            SecurityTask(
                title: "Enable Automatic Updates",
                description: "Keep your system secure with automatic security patches",
                detailedInstructions: """
                1. Open System Preferences (System Settings on macOS Ventura+)
                2. Go to Software Update
                3. Check "Automatically keep my Mac up to date"
                4. Click "Advanced..." and enable:
                   - Check for updates
                   - Download new updates when available
                   - Install macOS updates
                   - Install app updates from the App Store
                   - Install system data files and security updates
                
                This ensures you receive critical security updates automatically.
                """,
                category: .updates,
                difficulty: .beginner,
                estimatedTimeMinutes: 5,
                xpReward: 25,
                prerequisites: [],
                verificationCommand: "defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled",
                verificationDescription: "Check if automatic updates are enabled",
                day: 1,
                order: 4
            ),
            
            SecurityTask(
                title: "Set Strong Login Password",
                description: "Create a secure password for your user account",
                detailedInstructions: """
                1. Open System Preferences (System Settings on macOS Ventura+)
                2. Go to Users & Groups
                3. Click the lock icon and enter your password
                4. Select your user account
                5. Click "Change Password"
                6. Create a strong password with:
                   - At least 12 characters
                   - Mix of uppercase, lowercase, numbers, and symbols
                   - No personal information
                7. Consider using a password manager
                
                A strong password is your first line of defense.
                """,
                category: .authentication,
                difficulty: .beginner,
                estimatedTimeMinutes: 10,
                xpReward: 30,
                prerequisites: [],
                verificationCommand: nil,
                verificationDescription: "Manual verification - ensure password meets requirements",
                day: 1,
                order: 5
            )
        ]
        
        return DailyChallengeSet(
            day: 1,
            title: "Foundation Security",
            description: "Build the fundamental security foundation for your Mac",
            theme: "Essential Security Basics",
            tasks: tasks,
            totalXP: tasks.reduce(0) { $0 + $1.xpReward },
            estimatedTimeMinutes: tasks.reduce(0) { $0 + $1.estimatedTimeMinutes },
            completionBadge: "🛡️"
        )
    }
    
    private func createDay2Challenges() -> DailyChallengeSet {
        let tasks = [
            SecurityTask(
                title: "Configure DNS for Privacy",
                description: "Use privacy-focused DNS servers",
                detailedInstructions: """
                1. Open System Preferences (System Settings on macOS Ventura+)
                2. Go to Network
                3. Select your active connection (Wi-Fi or Ethernet)
                4. Click "Advanced..."
                5. Go to the "DNS" tab
                6. Add these DNS servers:
                   - Primary: 1.1.1.1 (Cloudflare)
                   - Secondary: 1.0.0.1 (Cloudflare)
                   - Alternative: 8.8.8.8 (Google)
                7. Click "OK" and "Apply"
                
                This improves privacy and can speed up your internet connection.
                """,
                category: .networking,
                difficulty: .intermediate,
                estimatedTimeMinutes: 15,
                xpReward: 60,
                prerequisites: ["Enable macOS Firewall"],
                verificationCommand: "scutil --dns | grep nameserver",
                verificationDescription: "Check current DNS servers",
                day: 2,
                order: 1
            ),
            
            SecurityTask(
                title: "Enable Two-Factor Authentication",
                description: "Add an extra layer of security to your Apple ID",
                detailedInstructions: """
                1. Open System Preferences (System Settings on macOS Ventura+)
                2. Click on your Apple ID at the top
                3. Go to "Password & Security"
                4. Click "Turn On Two-Factor Authentication"
                5. Follow the setup process:
                   - Enter your phone number
                   - Verify with SMS code
                   - Set up trusted devices
                6. Test the setup by signing out and back in
                
                This prevents unauthorized access even if your password is compromised.
                """,
                category: .authentication,
                difficulty: .intermediate,
                estimatedTimeMinutes: 20,
                xpReward: 75,
                prerequisites: ["Set Strong Login Password"],
                verificationCommand: nil,
                verificationDescription: "Manual verification - check Apple ID security settings",
                day: 2,
                order: 2
            ),
            
            SecurityTask(
                title: "Configure Time Machine Backup",
                description: "Set up encrypted backups for data protection",
                detailedInstructions: """
                1. Connect an external drive (at least 2x your Mac's storage)
                2. Open System Preferences (System Settings on macOS Ventura+)
                3. Go to Time Machine
                4. Click "Select Backup Disk"
                5. Choose your external drive
                6. Enable "Encrypt backups" for security
                7. Set a strong encryption password
                8. Click "Use Disk" and wait for initial backup
                
                Encrypted backups protect your data even if the drive is stolen.
                """,
                category: .backup,
                difficulty: .intermediate,
                estimatedTimeMinutes: 30,
                xpReward: 80,
                prerequisites: ["Enable FileVault Encryption"],
                verificationCommand: "tmutil status",
                verificationDescription: "Check Time Machine backup status",
                day: 2,
                order: 3
            ),
            
            SecurityTask(
                title: "Disable Unnecessary Services",
                description: "Reduce attack surface by disabling unused services",
                detailedInstructions: """
                1. Open System Preferences (System Settings on macOS Ventura+)
                2. Go to Sharing
                3. Disable unnecessary services:
                   - Remote Login (unless needed)
                   - Remote Management
                   - Screen Sharing (unless needed)
                   - File Sharing (unless needed)
                   - Printer Sharing (unless needed)
                4. Go to General > Handoff and disable if not needed
                5. Go to General > AirDrop and set to "Contacts Only" or "No One"
                
                Fewer enabled services mean fewer potential attack vectors.
                """,
                category: .system,
                difficulty: .intermediate,
                estimatedTimeMinutes: 15,
                xpReward: 55,
                prerequisites: ["Enable macOS Firewall"],
                verificationCommand: "sudo launchctl list | grep -v com.apple",
                verificationDescription: "Check running system services",
                day: 2,
                order: 4
            ),
            
            SecurityTask(
                title: "Set Up Screen Lock",
                description: "Configure automatic screen locking for privacy",
                detailedInstructions: """
                1. Open System Preferences (System Settings on macOS Ventura+)
                2. Go to Security & Privacy > General
                3. Set "Require password" to "immediately" after sleep or screen saver
                4. Go to Desktop & Screen Saver
                5. Set screen saver to start after 5-10 minutes
                6. Go to Energy Saver and set display sleep to 10-15 minutes
                7. Test by pressing Command+Control+Q to lock screen
                
                This prevents unauthorized access when you step away from your Mac.
                """,
                category: .privacy,
                difficulty: .beginner,
                estimatedTimeMinutes: 10,
                xpReward: 40,
                prerequisites: ["Configure Privacy Settings"],
                verificationCommand: "defaults read com.apple.screensaver askForPasswordDelay",
                verificationDescription: "Check screen lock delay setting",
                day: 2,
                order: 5
            )
        ]
        
        return DailyChallengeSet(
            day: 2,
            title: "Advanced Protection",
            description: "Implement advanced security measures and monitoring",
            theme: "Enhanced Security Configuration",
            tasks: tasks,
            totalXP: tasks.reduce(0) { $0 + $1.xpReward },
            estimatedTimeMinutes: tasks.reduce(0) { $0 + $1.estimatedTimeMinutes },
            completionBadge: "🔒"
        )
    }
    
    private func createDay3Challenges() -> DailyChallengeSet {
        let tasks = [
            SecurityTask(
                title: "Enable System Integrity Protection",
                description: "Protect system files from modification",
                detailedInstructions: """
                System Integrity Protection (SIP) is enabled by default on modern macOS.
                To verify it's enabled:
                
                1. Open Terminal
                2. Run: csrutil status
                3. You should see "System Integrity Protection status: enabled"
                
                If disabled (not recommended):
                1. Boot into Recovery Mode (Command+R during startup)
                2. Open Terminal
                3. Run: csrutil enable
                4. Restart normally
                
                SIP prevents malicious software from modifying system files.
                """,
                category: .system,
                difficulty: .advanced,
                estimatedTimeMinutes: 20,
                xpReward: 100,
                prerequisites: ["Disable Unnecessary Services"],
                verificationCommand: "csrutil status",
                verificationDescription: "Check System Integrity Protection status",
                day: 3,
                order: 1
            ),
            
            SecurityTask(
                title: "Configure Gatekeeper Settings",
                description: "Control which applications can run on your Mac",
                detailedInstructions: """
                1. Open System Preferences (System Settings on macOS Ventura+)
                2. Go to Security & Privacy > General
                3. Under "Allow apps downloaded from", select:
                   - "App Store and identified developers" (recommended)
                   - Avoid "Anywhere" unless absolutely necessary
                4. If you see "Anywhere" selected, change it for better security
                5. Test by trying to run an unsigned app (it should be blocked)
                
                Gatekeeper prevents unsigned or malicious applications from running.
                """,
                category: .system,
                difficulty: .intermediate,
                estimatedTimeMinutes: 10,
                xpReward: 70,
                prerequisites: ["Enable System Integrity Protection"],
                verificationCommand: "spctl --status",
                verificationDescription: "Check Gatekeeper status",
                day: 3,
                order: 2
            ),
            
            SecurityTask(
                title: "Set Up Network Monitoring",
                description: "Monitor network connections for suspicious activity",
                detailedInstructions: """
                1. Open Terminal
                2. Install network monitoring tools:
                   brew install nmap wireshark (if using Homebrew)
                3. Create a simple monitoring script:
                   #!/bin/bash
                   echo "Active network connections:"
                   netstat -an | grep ESTABLISHED
                   echo "Listening ports:"
                   netstat -an | grep LISTEN
                4. Save as ~/network_monitor.sh
                5. Make executable: chmod +x ~/network_monitor.sh
                6. Run periodically to check for unusual activity
                
                Regular monitoring helps detect unauthorized network access.
                """,
                category: .monitoring,
                difficulty: .advanced,
                estimatedTimeMinutes: 25,
                xpReward: 90,
                prerequisites: ["Configure DNS for Privacy"],
                verificationCommand: "netstat -an | grep ESTABLISHED | wc -l",
                verificationDescription: "Count active network connections",
                day: 3,
                order: 3
            ),
            
            SecurityTask(
                title: "Create Security Audit Script",
                description: "Build a custom security monitoring script",
                detailedInstructions: """
                1. Open Terminal
                2. Create a security audit script:
                   #!/bin/bash
                   echo "=== macOS Security Audit ==="
                   echo "FileVault Status:"
                   fdesetup status
                   echo "Firewall Status:"
                   /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
                   echo "SIP Status:"
                   csrutil status
                   echo "Gatekeeper Status:"
                   spctl --status
                   echo "Recent Login Attempts:"
                   last -n 10
                3. Save as ~/security_audit.sh
                4. Make executable: chmod +x ~/security_audit.sh
                5. Run weekly: ./security_audit.sh
                
                This script helps you regularly check your security posture.
                """,
                category: .monitoring,
                difficulty: .advanced,
                estimatedTimeMinutes: 30,
                xpReward: 120,
                prerequisites: ["Set Up Network Monitoring"],
                verificationCommand: "ls -la ~/security_audit.sh",
                verificationDescription: "Check if security audit script exists",
                day: 3,
                order: 4
            ),
            
            SecurityTask(
                title: "Implement Security Best Practices",
                description: "Apply additional security hardening measures",
                detailedInstructions: """
                1. Disable automatic login:
                   System Preferences > Users & Groups > Login Options
                   Set "Automatic login" to "Off"
                
                2. Enable secure virtual memory:
                   sudo pmset -a destroyfvkeyonstandby 1
                   sudo pmset -a hibernatemode 25
                
                3. Disable remote access:
                   System Preferences > Sharing
                   Uncheck all sharing options unless needed
                
                4. Set secure file permissions:
                   sudo chmod 600 ~/.ssh/config
                   sudo chmod 700 ~/.ssh
                
                5. Enable secure keyboard entry in Terminal
                
                These measures provide additional layers of security.
                """,
                category: .general,
                difficulty: .advanced,
                estimatedTimeMinutes: 20,
                xpReward: 110,
                prerequisites: ["Create Security Audit Script"],
                verificationCommand: "defaults read com.apple.loginwindow SHOWFULLNAME",
                verificationDescription: "Check if automatic login is disabled",
                day: 3,
                order: 5
            )
        ]
        
        return DailyChallengeSet(
            day: 3,
            title: "Security Mastery",
            description: "Master advanced security techniques and monitoring",
            theme: "Expert-Level Security Hardening",
            tasks: tasks,
            totalXP: tasks.reduce(0) { $0 + $1.xpReward },
            estimatedTimeMinutes: tasks.reduce(0) { $0 + $1.estimatedTimeMinutes },
            completionBadge: "🥷"
        )
    }
    
    // MARK: - Achievement System
    private func loadAchievements() {
        achievements = [
            SecurityAchievement(
                title: "Security Novice",
                description: "Complete your first security task",
                icon: "shield.fill",
                category: .general,
                requirement: "Complete 1 task",
                xpReward: 50,
                isUnlocked: false,
                unlockedAt: nil
            ),
            SecurityAchievement(
                title: "Foundation Builder",
                description: "Complete all Day 1 tasks",
                icon: "building.2.fill",
                category: .general,
                requirement: "Complete all Day 1 tasks",
                xpReward: 200,
                isUnlocked: false,
                unlockedAt: nil
            ),
            SecurityAchievement(
                title: "Privacy Guardian",
                description: "Complete all privacy-related tasks",
                icon: "eye.slash.fill",
                category: .privacy,
                requirement: "Complete 3 privacy tasks",
                xpReward: 150,
                isUnlocked: false,
                unlockedAt: nil
            ),
            SecurityAchievement(
                title: "Network Defender",
                description: "Complete all networking tasks",
                icon: "network",
                category: .networking,
                requirement: "Complete 2 networking tasks",
                xpReward: 100,
                isUnlocked: false,
                unlockedAt: nil
            ),
            SecurityAchievement(
                title: "Security Master",
                description: "Complete all 15 security tasks",
                icon: "crown.fill",
                category: .general,
                requirement: "Complete all tasks across all days",
                xpReward: 500,
                isUnlocked: false,
                unlockedAt: nil
            )
        ]
    }
    
    // MARK: - Task Management
    func startTask(_ task: SecurityTask) {
        let progress = TaskProgress(
            taskId: task.id,
            status: .inProgress,
            startedAt: Date(),
            completedAt: nil,
            verifiedAt: nil,
            notes: "",
            xpEarned: 0
        )
        taskProgress[task.id] = progress
    }
    
    func completeTask(_ task: SecurityTask, notes: String = "") {
        guard var progress = taskProgress[task.id] else { return }
        
        progress.status = .completed
        progress.completedAt = Date()
        progress.notes = notes
        progress.xpEarned = task.xpReward
        
        taskProgress[task.id] = progress
        
        // Award XP to game model
        gameModel?.addXP(task.xpReward)
        
        // Check for achievements
        checkAchievements()
    }
    
    func verifyTask(_ task: SecurityTask) {
        guard var progress = taskProgress[task.id] else { return }
        
        progress.status = .verified
        progress.verifiedAt = Date()
        
        taskProgress[task.id] = progress
        
        // Award bonus XP for verification
        let bonusXP = task.xpReward / 2
        gameModel?.addXP(bonusXP)
    }
    
    func getTaskProgress(for taskId: UUID) -> TaskProgress? {
        return taskProgress[taskId]
    }
    
    func getCompletedTasksCount() -> Int {
        return taskProgress.values.filter { $0.status == .completed || $0.status == .verified }.count
    }
    
    func getDayProgress(day: Int) -> (completed: Int, total: Int) {
        let dayTasks = dailyChallenges.first { $0.day == day }?.tasks ?? []
        let completedCount = dayTasks.filter { task in
            guard let progress = taskProgress[task.id] else { return false }
            return progress.status == .completed || progress.status == .verified
        }.count
        
        return (completed: completedCount, total: dayTasks.count)
    }
    
    private func checkAchievements() {
        let completedCount = getCompletedTasksCount()
        
        for (index, achievement) in achievements.enumerated() {
            if !achievement.isUnlocked {
                var shouldUnlock = false
                
                switch achievement.title {
                case "Security Novice":
                    shouldUnlock = completedCount >= 1
                case "Foundation Builder":
                    shouldUnlock = getDayProgress(day: 1).completed == getDayProgress(day: 1).total
                case "Privacy Guardian":
                    let privacyTasks = dailyChallenges.flatMap { $0.tasks }.filter { $0.category == .privacy }
                    let completedPrivacyTasks = privacyTasks.filter { task in
                        guard let progress = taskProgress[task.id] else { return false }
                        return progress.status == .completed || progress.status == .verified
                    }.count
                    shouldUnlock = completedPrivacyTasks >= 3
                case "Network Defender":
                    let networkTasks = dailyChallenges.flatMap { $0.tasks }.filter { $0.category == .networking }
                    let completedNetworkTasks = networkTasks.filter { task in
                        guard let progress = taskProgress[task.id] else { return false }
                        return progress.status == .completed || progress.status == .verified
                    }.count
                    shouldUnlock = completedNetworkTasks >= 2
                case "Security Master":
                    shouldUnlock = completedCount >= 15
                default:
                    break
                }
                
                if shouldUnlock {
                    achievements[index] = SecurityAchievement(
                        title: achievement.title,
                        description: achievement.description,
                        icon: achievement.icon,
                        category: achievement.category,
                        requirement: achievement.requirement,
                        xpReward: achievement.xpReward,
                        isUnlocked: true,
                        unlockedAt: Date()
                    )
                    
                    // Award achievement XP
                    gameModel?.addXP(achievement.xpReward)
                }
            }
        }
    }
}
