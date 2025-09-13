import Foundation

// MARK: - Security Task Models
struct SecurityTask: Codable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let detailedInstructions: String
    let learningMaterials: LearningMaterials?
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
        case title, description, detailedInstructions, learningMaterials, category, difficulty, estimatedTimeMinutes, xpReward, prerequisites, verificationCommand, verificationDescription, day, order
    }
}

struct LearningMaterials: Codable {
    let overview: String
    let whyImportant: String
    let stepByStepGuide: [String]
    let commonMistakes: [String]
    let securityBenefits: [String]
    let troubleshootingTips: [String]
    let relatedConcepts: [String]
    let additionalResources: [String]
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
    
    // Storage keys for UserDefaults
    private let taskProgressKey = "SimplySecure_TaskProgress"
    private let achievementsKey = "SimplySecure_Achievements"
    private let currentDayKey = "SimplySecure_CurrentDay"
    
    init() {
        loadDailyChallenges()
        loadAchievements()
        loadPersistentData()
    }
    
    // Helper function to create basic learning materials
    private func createBasicLearningMaterials(
        overview: String,
        whyImportant: String,
        benefits: [String],
        mistakes: [String],
        concepts: [String]
    ) -> LearningMaterials {
        return LearningMaterials(
            overview: overview,
            whyImportant: whyImportant,
            stepByStepGuide: ["Follow the detailed instructions provided"],
            commonMistakes: mistakes,
            securityBenefits: benefits,
            troubleshootingTips: ["Refer to system documentation if issues arise"],
            relatedConcepts: concepts,
            additionalResources: ["Apple Security Documentation", "macOS Security Best Practices"]
        )
    }
    
    func setGameModel(_ gameModel: NinjaGameModel) {
        self.gameModel = gameModel
    }
    
    // MARK: - Persistent Storage Methods
    
    private func loadPersistentData() {
        loadTaskProgress()
        loadAchievementsFromStorage()
        loadCurrentDay()
    }
    
    private func loadTaskProgress() {
        if let data = UserDefaults.standard.data(forKey: taskProgressKey),
           let decoded = try? JSONDecoder().decode([String: TaskProgress].self, from: data) {
            // Convert string keys back to UUIDs
            taskProgress = Dictionary(uniqueKeysWithValues: decoded.compactMap { key, value in
                guard let uuid = UUID(uuidString: key) else { return nil }
                return (uuid, value)
            })
        }
    }
    
    private func saveTaskProgress() {
        // Convert UUID keys to strings for JSON encoding
        let stringKeyedProgress = Dictionary(uniqueKeysWithValues: taskProgress.map { ($0.key.uuidString, $0.value) })
        
        if let encoded = try? JSONEncoder().encode(stringKeyedProgress) {
            UserDefaults.standard.set(encoded, forKey: taskProgressKey)
        }
    }
    
    private func loadAchievementsFromStorage() {
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([SecurityAchievement].self, from: data) {
            achievements = decoded
        }
    }
    
    private func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: achievementsKey)
        }
    }
    
    private func loadCurrentDay() {
        let savedDay = UserDefaults.standard.integer(forKey: currentDayKey)
        if savedDay > 0 {
            currentDay = savedDay
        }
    }
    
    private func saveCurrentDay() {
        UserDefaults.standard.set(currentDay, forKey: currentDayKey)
    }
    
    func setCurrentDay(_ day: Int) {
        currentDay = day
        saveCurrentDay()
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
                learningMaterials: LearningMaterials(
                    overview: """
                    FileVault is macOS's built-in full-disk encryption feature that provides comprehensive protection for all data on your startup disk. It uses industry-standard XTS-AES-128 encryption with a 256-bit key, ensuring that your personal files, documents, photos, and system files are protected from unauthorized access.
                    
                    When enabled, FileVault encrypts your entire startup disk, including:
                    • All user files and documents
                    • System files and applications
                    • Browser data and passwords
                    • Email and messaging data
                    • Any data stored locally on your Mac
                    
                    The encryption process is transparent to the user - once set up, you'll use your Mac normally while all data is automatically encrypted and decrypted as needed. FileVault integrates seamlessly with macOS features like Time Machine, iCloud, and system updates.
                    """,
                    whyImportant: """
                    Physical security is often overlooked but represents one of the most significant threats to your data. Without encryption, anyone who gains physical access to your Mac can:
                    
                    🔓 **Bypass your login password** by booting from external media
                    🔓 **Access all your files directly** by mounting your disk
                    🔓 **Steal your personal data** including photos, documents, and passwords
                    🔓 **Install malicious software** or backdoors on your system
                    🔓 **Access your browser data** including saved passwords and browsing history
                    
                    FileVault prevents these attacks by ensuring that even if someone steals your Mac or gains physical access, they cannot read your data without your password or recovery key. This is especially important for:
                    • Laptops that can be easily stolen
                    • Shared workspaces where devices might be left unattended
                    • Travel scenarios where your Mac might be searched or confiscated
                    • Compliance with data protection regulations (GDPR, HIPAA, etc.)
                    
                    Real-world example: In 2019, a security researcher demonstrated how easy it is to access data on unencrypted Macs. Using a simple USB drive with specialized software, they could bypass login screens and access all files in under 5 minutes.
                    """,
                    stepByStepGuide: [
                        "**Preparation Phase**: Ensure your Mac is plugged into power and has sufficient battery life, as encryption can take several hours for large drives.",
                        "**Access Settings**: Open System Preferences (System Settings on macOS Ventura+) and navigate to Security & Privacy > FileVault.",
                        "**Authentication**: Click the lock icon in the bottom-left corner and enter your administrator password to make changes.",
                        "**Enable FileVault**: Click 'Turn On FileVault' button. You'll see a dialog explaining what will happen.",
                        "**Recovery Key Choice**: Choose how to store your recovery key:",
                        "  • **Apple ID**: Recovery key is stored securely with Apple (recommended for most users)",
                        "  • **Local Recovery Key**: You'll need to write down and store the key securely",
                        "**User Authentication**: Select which users can unlock the disk. Typically, this includes all administrator accounts.",
                        "**Restart Process**: Click 'Restart' when prompted. Your Mac will restart and begin the encryption process.",
                        "**Encryption Progress**: You'll see a progress bar during the initial encryption. This can take 1-4 hours depending on disk size.",
                        "**Verification**: Once complete, verify encryption is working by checking the FileVault status in System Preferences."
                    ],
                    commonMistakes: [
                        "⚠️ **Losing the recovery key** - This is the #1 mistake. Without both your password AND recovery key, your data is permanently lost.",
                        "⚠️ **Interrupting the encryption process** - Don't shut down or restart during initial encryption as this can corrupt your data.",
                        "⚠️ **Not testing the setup** - Always test that you can unlock your Mac with both your password and recovery key.",
                        "⚠️ **Ignoring performance impact** - While minimal, encryption does use CPU resources. Older Macs may notice slight performance changes.",
                        "⚠️ **Not backing up before enabling** - Always ensure you have a recent backup before enabling FileVault.",
                        "⚠️ **Forgetting about other users** - Make sure all user accounts that need access are added to the unlock list.",
                        "⚠️ **Not updating firmware** - Ensure your Mac's firmware is up to date before enabling FileVault for optimal security."
                    ],
                    securityBenefits: [
                        "🛡️ **Complete Data Protection**: Every file on your startup disk is encrypted, including system files, applications, and user data.",
                        "🛡️ **Hardware Integration**: FileVault uses the T2 Security Chip (on supported Macs) for hardware-accelerated encryption with no performance impact.",
                        "🛡️ **Transparent Operation**: Once enabled, FileVault works invisibly in the background without affecting normal computer use.",
                        "🛡️ **Regulatory Compliance**: Helps meet requirements for GDPR, HIPAA, SOX, and other data protection regulations.",
                        "🛡️ **Theft Protection**: Protects against data theft even if your Mac is stolen or lost.",
                        "🛡️ **Forensic Resistance**: Makes it extremely difficult for forensic tools to recover data without proper authentication.",
                        "🛡️ **Multi-User Support**: Allows multiple authorized users to access the encrypted disk while maintaining security."
                    ],
                    troubleshootingTips: [
                        "🔧 **Recovery Key Lost**: If you lose your recovery key but remember your password, you can still access your Mac. However, you should generate a new recovery key immediately.",
                        "🔧 **Slow Performance**: If you notice slower performance, check Activity Monitor for high CPU usage. Encryption should complete within a few hours.",
                        "🔧 **Boot Issues**: If your Mac won't start after enabling FileVault, try holding Option during startup to access the recovery key prompt.",
                        "🔧 **Verification Commands**: Use 'sudo fdesetup status' in Terminal to check encryption status and progress.",
                        "🔧 **Multiple Users**: If other users can't access the Mac, ensure they're added to the FileVault user list in System Preferences.",
                        "🔧 **Time Machine Integration**: FileVault works seamlessly with Time Machine - your backups will also be encrypted.",
                        "🔧 **Disabling FileVault**: If you need to disable FileVault, plan for several hours of decryption time, especially for large drives."
                    ],
                    relatedConcepts: [
                        "**Full-Disk Encryption (FDE)**: A security method that encrypts all data on a storage device.",
                        "**XTS-AES Encryption**: The Advanced Encryption Standard used by FileVault with XTS mode for disk encryption.",
                        "**Recovery Keys**: Special keys that allow access to encrypted data when the primary password is forgotten.",
                        "**Hardware Security Modules (HSM)**: Dedicated hardware for managing encryption keys securely.",
                        "**Data at Rest Protection**: Security measures for protecting stored data from unauthorized access.",
                        "**Key Derivation Functions**: Mathematical processes used to create encryption keys from passwords.",
                        "**Secure Boot**: Process that ensures only trusted software can start the system."
                    ],
                    additionalResources: [
                        "📚 **Apple's Official FileVault Documentation**: Comprehensive guide from Apple with latest features and troubleshooting.",
                        "📚 **NIST Special Publication 800-111**: Guide to Storage Encryption Technologies for End User Devices.",
                        "📚 **OWASP Mobile Security Testing Guide**: Best practices for mobile and laptop encryption.",
                        "📚 **SANS Security Awareness Training**: Educational materials on encryption and data protection.",
                        "📚 **CIS Controls**: Center for Internet Security guidelines for data protection.",
                        "📚 **ISO 27001**: International standard for information security management systems."
                    ]
                ),
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
                learningMaterials: LearningMaterials(
                    overview: """
                    The macOS Application Firewall is a sophisticated network security feature that acts as a gatekeeper between your Mac and the internet. Unlike traditional firewalls that block ports, the macOS firewall controls which applications can accept incoming network connections, providing more granular and intelligent protection.
                    
                    **How it Works:**
                    • **Application-Based Filtering**: Instead of blocking ports, it controls which apps can listen for incoming connections
                    • **Automatic Allow/Block**: Uses code signing to automatically allow trusted Apple and App Store applications
                    • **Stealth Mode**: Makes your Mac invisible to network discovery tools and port scanners
                    • **Connection Logging**: Tracks and logs firewall activity for security monitoring
                    
                    **Key Features:**
                    • Blocks unauthorized incoming connections while allowing legitimate traffic
                    • Automatically manages rules for signed applications
                    • Provides detailed logging of blocked connections
                    • Integrates with macOS security architecture
                    • Supports both IPv4 and IPv6 traffic
                    
                    The firewall operates at the application layer, making it more intelligent than traditional network firewalls. It understands the context of network requests and can make informed decisions about which applications should be allowed to accept incoming connections.
                    """,
                    whyImportant: """
                    Network-based attacks are among the most common security threats facing Mac users today. Without a properly configured firewall, your Mac is vulnerable to several serious security risks:
                    
                    🚨 **Backdoor Creation**: Malicious software can open network ports and create hidden backdoors that allow attackers to:
                       • Remotely control your Mac
                       • Steal your personal data
                       • Use your Mac as part of a botnet
                       • Monitor your activities
                    
                    🚨 **Port Scanning Attacks**: Attackers constantly scan the internet for open ports. Without a firewall:
                       • Your Mac responds to connection attempts
                       • Attackers can identify vulnerable services
                       • Your system appears as an easy target
                       • Automated attacks can target your Mac
                    
                    🚨 **Ransomware and Malware**: Many modern threats rely on network connectivity to:
                       • Download additional payloads
                       • Communicate with command & control servers
                       • Spread to other devices on your network
                       • Exfiltrate stolen data
                    
                    🚨 **Privacy Violations**: Unauthorized network access can lead to:
                       • Monitoring of your internet activity
                       • Theft of sensitive information
                       • Identity theft and financial fraud
                       • Corporate espionage (for business users)
                    
                    **Real-World Impact**: In 2021, security researchers found that Macs without firewalls were 3x more likely to be compromised by network-based attacks. The macOS firewall has prevented millions of potential intrusions by blocking suspicious connection attempts.
                    """,
                    stepByStepGuide: [
                        "**Access Firewall Settings**: Open System Preferences (System Settings on macOS Ventura+) and navigate to Security & Privacy > Firewall tab.",
                        "**Authenticate**: Click the lock icon in the bottom-left corner and enter your administrator password to make security changes.",
                        "**Enable Firewall**: Click the 'Turn On Firewall' button. You'll see the status change to 'Firewall: On'.",
                        "**Configure Advanced Options**: Click 'Firewall Options' to access advanced settings:",
                        "  • **Block all incoming connections**: Enable this for maximum security (blocks all apps except essential services)",
                        "  • **Automatically allow signed software**: Keep this enabled to allow trusted applications",
                        "  • **Enable Stealth Mode**: This hides your Mac from network discovery",
                        "**Review Application Rules**: The firewall will show you which applications have requested network access. Review and remove any you don't recognize.",
                        "**Test Configuration**: Use online port scanners to verify your Mac is properly protected and not responding to connection attempts.",
                        "**Monitor Logs**: Regularly check firewall logs to identify any blocked connection attempts or suspicious activity.",
                        "**Update Rules**: As you install new applications, review and approve their network access requests through the firewall interface."
                    ],
                    commonMistakes: [
                        "❌ **Leaving Firewall Disabled**: Many users assume macOS is secure by default and don't enable the firewall, leaving their Mac vulnerable to network attacks.",
                        "❌ **Overly Permissive Rules**: Allowing too many applications through the firewall defeats the purpose of having one. Only approve applications you trust and understand.",
                        "❌ **Ignoring Stealth Mode**: Not enabling Stealth Mode makes your Mac visible to network scanners and increases the likelihood of targeted attacks.",
                        "❌ **Not Reviewing Logs**: Firewall logs contain valuable security information. Ignoring them means missing potential security threats.",
                        "❌ **Blocking Essential Services**: Being too restrictive and blocking system services can break functionality like AirPlay, file sharing, or remote access.",
                        "❌ **Not Testing Configuration**: Many users set up the firewall but never verify it's actually working by testing with port scanners.",
                        "❌ **Forgetting About VPN**: When using VPN software, firewall rules may need adjustment to allow VPN traffic while maintaining security."
                    ],
                    securityBenefits: [
                        "🔒 **Application-Level Protection**: Unlike traditional firewalls, macOS firewall understands applications and can make intelligent decisions about network access.",
                        "🔒 **Automatic Rule Management**: Uses code signing to automatically allow trusted applications while blocking unsigned or suspicious software.",
                        "🔒 **Stealth Mode**: Makes your Mac invisible to network discovery tools, reducing the likelihood of targeted attacks.",
                        "🔒 **Detailed Logging**: Provides comprehensive logs of blocked connections, helping identify potential security threats.",
                        "🔒 **Zero Configuration**: Works effectively with default settings while allowing customization for advanced users.",
                        "🔒 **Integration with macOS Security**: Works seamlessly with other macOS security features like Gatekeeper and System Integrity Protection.",
                        "🔒 **Protection Against Zero-Day Exploits**: Can block network-based attacks even for vulnerabilities that haven't been patched yet."
                    ],
                    troubleshootingTips: [
                        "🔧 **App Can't Connect**: If a legitimate application can't make network connections, check firewall rules and ensure it's allowed through the firewall.",
                        "🔧 **VPN Issues**: VPN software often needs special firewall permissions. Check with your VPN provider for specific configuration requirements.",
                        "🔧 **File Sharing Problems**: If file sharing stops working, ensure the firewall isn't blocking necessary services like SMB or AFP.",
                        "🔧 **AirPlay/AirDrop Issues**: Apple's wireless features may need firewall exceptions. Try temporarily disabling Stealth Mode to test.",
                        "🔧 **Gaming Problems**: Online games often need specific port access. Check game documentation for required firewall exceptions.",
                        "🔧 **Development Tools**: If you're a developer, tools like local servers or debugging interfaces may need firewall exceptions.",
                        "🔧 **Log Analysis**: Use Console.app to view detailed firewall logs and identify what's being blocked."
                    ],
                    relatedConcepts: [
                        "**Network Security**: Comprehensive approach to protecting network infrastructure and data.",
                        "**Application Firewall**: Firewall technology that controls access based on applications rather than ports.",
                        "**Code Signing**: Digital signature system that verifies software authenticity and integrity.",
                        "**Stealth Mode**: Network security technique that hides devices from network discovery.",
                        "**Intrusion Prevention**: Security technology that actively blocks malicious network activity.",
                        "**Port Scanning**: Technique used to discover open network ports on target systems.",
                        "**Network Access Control (NAC)**: Security approach that controls network access based on device compliance."
                    ],
                    additionalResources: [
                        "📖 **Apple's Firewall Documentation**: Official guide to macOS firewall configuration and troubleshooting.",
                        "📖 **SANS Network Security Essentials**: Comprehensive training on network security fundamentals.",
                        "📖 **NIST Cybersecurity Framework**: Government guidelines for network security implementation.",
                        "📖 **OWASP Network Security Guide**: Open source security practices for network protection.",
                        "📖 **CIS Controls for Network Security**: Industry-standard network security controls.",
                        "📖 **Network Security Monitoring Tools**: Guide to tools for monitoring network security posture."
                    ]
                ),
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
                learningMaterials: LearningMaterials(
                    overview: """
                    macOS Privacy Settings represent one of the most comprehensive privacy control systems available in any operating system. These settings give you granular control over which applications can access your personal data, hardware components, and system resources.
                    
                    **Privacy Categories Include:**
                    • **Location Services**: Control which apps can access your geographic location
                    • **Contacts**: Manage access to your address book and contact information
                    • **Calendars**: Control access to your calendar events and scheduling data
                    • **Reminders**: Manage access to your to-do lists and reminders
                    • **Photos**: Control which apps can access your photo library
                    • **Camera**: Manage camera access for video calls and photo capture
                    • **Microphone**: Control audio recording permissions for apps
                    • **Screen Recording**: Manage which apps can capture your screen
                    • **Accessibility**: Control access to assistive features and system functions
                    • **Full Disk Access**: Manage apps that can access all files on your Mac
                    • **System Events**: Control access to system-level events and notifications
                    
                    **Key Privacy Features:**
                    • **Granular Control**: Each category can be configured independently
                    • **Transparency**: Clear indication of which apps have access to what data
                    • **Easy Management**: Simple interface for granting and revoking permissions
                    • **System Integration**: Works seamlessly with macOS security architecture
                    • **Privacy Reports**: Detailed reports on app data access patterns
                    
                    The privacy system operates on the principle of least privilege - apps only get access to the data they absolutely need to function, and you maintain complete control over these permissions.
                    """,
                    whyImportant: """
                    Privacy violations have become one of the most significant threats to personal security in the digital age. Poor privacy configuration can lead to serious consequences:
                    
                    🚨 **Data Harvesting**: Apps can collect vast amounts of personal information:
                       • Your exact location history (where you live, work, travel)
                       • Your complete contact list and social connections
                       • All your photos including metadata (when/where taken)
                       • Your calendar events and daily routines
                       • Your browsing history and online behavior
                    
                    🚨 **Identity Theft**: Collected data can be used for:
                       • Creating detailed profiles for targeted attacks
                       • Social engineering attacks using personal information
                       • Financial fraud using location and behavioral data
                       • Corporate espionage and competitive intelligence
                    
                    🚨 **Surveillance and Tracking**: Without proper controls:
                       • Apps can track your movements in real-time
                       • Companies can build detailed behavioral profiles
                       • Your activities can be monitored without your knowledge
                       • Data can be shared with third parties without consent
                    
                    🚨 **Malicious Use**: Poorly configured permissions enable:
                       • Ransomware that encrypts your photos and documents
                       • Spyware that monitors your communications
                       • Apps that steal your contacts for spam campaigns
                       • Software that accesses your camera/microphone secretly
                    
                    **Real-World Impact**: A 2022 study found that the average smartphone app requests access to 20+ different types of personal data, with 60% of users granting unnecessary permissions. Proper privacy configuration can reduce your digital footprint by 80% and significantly lower your risk of privacy violations.
                    """,
                    stepByStepGuide: [
                        "**Access Privacy Settings**: Open System Preferences (System Settings on macOS Ventura+) and navigate to Security & Privacy > Privacy tab.",
                        "**Authenticate**: Click the lock icon and enter your administrator password to make privacy changes.",
                        "**Review Location Services**: Go to Location Services and:",
                        "  • Turn off location access for apps that don't need it (games, social media)",
                        "  • Keep it enabled only for essential apps (Maps, Weather, Find My)",
                        "  • Review 'System Services' and disable unnecessary location features",
                        "**Configure Camera Access**: In Camera settings:",
                        "  • Only allow camera access for video calling apps and photo apps",
                        "  • Remove access for games, social media, or other non-essential apps",
                        "  • Test that your camera still works for legitimate apps",
                        "**Manage Microphone Permissions**: In Microphone settings:",
                        "  • Allow access only for communication apps (Zoom, Teams, FaceTime)",
                        "  • Remove access for apps that don't need audio recording",
                        "  • Be especially careful with social media apps requesting microphone access",
                        "**Review Photo Library Access**: In Photos settings:",
                        "  • Limit access to only photo editing and backup apps",
                        "  • Remove access for games, productivity apps, and social media",
                        "  • Consider using 'Selected Photos' instead of 'All Photos' when possible",
                        "**Configure Contacts Access**: In Contacts settings:",
                        "  • Only allow access for messaging and communication apps",
                        "  • Remove access for games, social media, and other non-essential apps",
                        "  • Be cautious about apps that request contact access for 'sharing' features",
                        "**Set Up Screen Lock**: In Security & Privacy > General:",
                        "  • Set 'Require password' to 'immediately' after sleep or screen saver",
                        "  • Enable 'Show a message when the screen is locked' with contact info",
                        "  • Consider enabling 'Disable automatic login' for additional security"
                    ],
                    commonMistakes: [
                        "❌ **Granting Permissions Without Reading**: Many users click 'Allow' without understanding what access they're granting, leading to unnecessary data exposure.",
                        "❌ **Never Reviewing Permissions**: Once granted, users rarely revisit permissions, allowing apps to accumulate access to sensitive data over time.",
                        "❌ **Over-Permitting Social Media Apps**: Social media apps often request excessive permissions that they don't actually need for core functionality.",
                        "❌ **Ignoring System Services**: Not reviewing system-level location and privacy services can leave unnecessary tracking enabled.",
                        "❌ **Not Using Selective Photo Access**: Granting 'All Photos' access when 'Selected Photos' would suffice exposes your entire photo library.",
                        "❌ **Allowing Games Unnecessary Access**: Games often request camera, microphone, or location access that they don't need for gameplay.",
                        "❌ **Not Testing After Changes**: Making privacy changes without testing can break legitimate app functionality, leading users to revert to less secure settings."
                    ],
                    securityBenefits: [
                        "🔐 **Data Minimization**: Only essential apps get access to your personal data, reducing your digital footprint significantly.",
                        "🔐 **Attack Surface Reduction**: Fewer apps with access to sensitive data means fewer potential attack vectors for malicious actors.",
                        "🔐 **Compliance with Privacy Laws**: Proper configuration helps meet GDPR, CCPA, and other privacy regulation requirements.",
                        "🔐 **Transparency and Control**: You know exactly which apps have access to what data and can change these permissions at any time.",
                        "🔐 **Protection Against Data Breaches**: If an app is compromised, the damage is limited by the permissions you've granted.",
                        "🔐 **Prevention of Data Harvesting**: Reduces the amount of personal data available for collection and profiling.",
                        "🔐 **Enhanced Privacy Posture**: Creates a strong foundation for overall privacy protection across your digital life."
                    ],
                    troubleshootingTips: [
                        "🔧 **App Not Working**: If an app stops working after removing permissions, check what specific access it needs and grant only the minimum required permissions.",
                        "🔧 **Location-Based Features**: If location-dependent features stop working, check if you've accidentally disabled location services for essential apps.",
                        "🔧 **Video Calls Not Working**: Ensure camera and microphone permissions are granted for your video calling applications.",
                        "🔧 **Photo Sharing Issues**: If you can't share photos from an app, check if it has photo library access permissions.",
                        "🔧 **Contact Sync Problems**: If contacts aren't syncing with an app, verify that the app has contacts access permissions.",
                        "🔧 **Screen Recording Issues**: If screen recording apps aren't working, check the Screen Recording permissions in Privacy settings.",
                        "🔧 **Privacy Reports**: Use the Privacy Reports feature in macOS to see which apps are accessing your data and when."
                    ],
                    relatedConcepts: [
                        "**Data Privacy**: The practice of handling personal data in compliance with privacy principles and regulations.",
                        "**Application Permissions**: System-level controls that determine what resources an app can access.",
                        "**Data Minimization**: The principle of collecting and processing only the minimum amount of data necessary.",
                        "**User Consent**: The informed agreement of users to data collection and processing activities.",
                        "**Privacy by Design**: The approach of building privacy protections into systems from the ground up.",
                        "**Data Subject Rights**: Legal rights that individuals have regarding their personal data under privacy laws.",
                        "**Privacy Impact Assessment**: Process of evaluating how data processing activities affect individual privacy."
                    ],
                    additionalResources: [
                        "📚 **Apple's Privacy Documentation**: Comprehensive guide to macOS privacy features and configuration.",
                        "📚 **GDPR Compliance Guide**: European Union's General Data Protection Regulation compliance resources.",
                        "📚 **CCPA Privacy Rights**: California Consumer Privacy Act guidelines and best practices.",
                        "📚 **Privacy Engineering Guidelines**: Technical approaches to building privacy-preserving systems.",
                        "📚 **Digital Privacy Best Practices**: General guidelines for protecting personal information online.",
                        "📚 **Privacy-Focused App Alternatives**: Recommendations for apps that respect user privacy."
                    ]
                ),
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
                learningMaterials: LearningMaterials(
                    overview: """
                    Automatic updates represent one of the most critical security features in modern operating systems. macOS Software Update provides a comprehensive system for keeping your Mac secure, stable, and performing optimally by automatically downloading and installing security patches, system updates, and application updates.
                    
                    **Types of Updates:**
                    • **Security Updates**: Critical patches that fix security vulnerabilities and protect against known threats
                    • **System Updates**: Major macOS version updates with new features and improvements
                    • **App Store Updates**: Updates for applications downloaded from the Mac App Store
                    • **System Data Files**: Updates to security definitions, fonts, and other system components
                    • **Firmware Updates**: Updates to hardware-level software for enhanced security and compatibility
                    
                    **Update Delivery System:**
                    • **Differential Updates**: Only downloads changed portions of files, reducing bandwidth usage
                    • **Background Download**: Updates download automatically when connected to Wi-Fi
                    • **Intelligent Scheduling**: Updates install at convenient times to minimize disruption
                    • **Rollback Protection**: Ability to revert problematic updates if issues arise
                    • **Verification**: All updates are cryptographically signed and verified before installation
                    
                    **Security Features:**
                    • **Code Signing**: All updates are digitally signed by Apple to ensure authenticity
                    • **Secure Boot**: Updates maintain system integrity through secure boot processes
                    • **Sandboxing**: Update processes run in isolated environments for security
                    • **Automatic Verification**: System verifies update integrity before and after installation
                    
                    The automatic update system operates transparently in the background, ensuring your Mac stays protected without requiring constant user intervention or technical expertise.
                    """,
                    whyImportant: """
                    Software vulnerabilities represent one of the most significant security threats in the digital landscape. Without automatic updates, your Mac becomes increasingly vulnerable to a wide range of security threats:
                    
                    🚨 **Known Vulnerability Exploitation**: Attackers actively exploit known vulnerabilities:
                       • Security researchers publicly disclose vulnerabilities after patches are released
                       • Attackers reverse-engineer patches to create exploits
                       • Unpatched systems become immediate targets for automated attacks
                       • Exploit kits are sold on the dark web targeting specific vulnerabilities
                    
                    🚨 **Zero-Day vs. N-Day Attacks**: The difference between protected and vulnerable systems:
                       • **Zero-Day**: Attacks using unknown vulnerabilities (rare, sophisticated)
                       • **N-Day**: Attacks using known vulnerabilities with available patches (common, preventable)
                       • Unpatched systems are vulnerable to both, but N-Day attacks are far more common
                       • Automatic updates protect against 95% of real-world attacks
                    
                    🚨 **Malware and Ransomware**: Outdated software enables:
                       • Ransomware that encrypts your files and demands payment
                       • Banking trojans that steal financial information
                       • Cryptocurrency miners that hijack your system resources
                       • Botnet participation that uses your Mac for criminal activities
                    
                    🚨 **Data Breaches and Identity Theft**: Vulnerabilities can lead to:
                       • Unauthorized access to personal files and documents
                       • Theft of passwords and authentication credentials
                       • Compromise of financial and banking information
                       • Exposure of private communications and photos
                    
                    **Real-World Impact**: The 2021 Colonial Pipeline ransomware attack was caused by an unpatched vulnerability in a VPN system. The attack shut down a major fuel pipeline for days, causing gas shortages across the eastern United States. This demonstrates how a single unpatched vulnerability can have catastrophic consequences.
                    
                    **Statistics**: Studies show that 99% of exploited vulnerabilities have patches available for more than a year before being exploited, meaning most attacks are completely preventable with proper update management.
                    """,
                    stepByStepGuide: [
                        "**Access Software Update Settings**: Open System Preferences (System Settings on macOS Ventura+) and navigate to Software Update.",
                        "**Enable Automatic Updates**: Check the box next to 'Automatically keep my Mac up to date' to enable automatic downloading and installation.",
                        "**Configure Advanced Options**: Click 'Advanced...' to access detailed update configuration:",
                        "  • **Check for updates**: Automatically check for available updates",
                        "  • **Download new updates when available**: Download updates in the background",
                        "  • **Install macOS updates**: Automatically install system updates",
                        "  • **Install app updates from the App Store**: Update App Store applications automatically",
                        "  • **Install system data files and security updates**: Install critical security patches",
                        "**Set Update Schedule**: Configure when updates should be installed:",
                        "  • Choose times when you're least likely to be using your Mac",
                        "  • Consider your work schedule and internet usage patterns",
                        "  • Allow time for system restarts if required",
                        "**Verify Update Sources**: Ensure you're receiving updates from Apple's official servers:",
                        "  • Updates should come from Apple's CDN (content delivery network)",
                        "  • Verify update authenticity through System Information",
                        "  • Check that updates are digitally signed by Apple",
                        "**Test Update Process**: Verify that automatic updates are working:",
                        "  • Check 'Last checked' timestamp in Software Update preferences",
                        "  • Look for pending updates in the Software Update interface",
                        "  • Monitor system activity during scheduled update times",
                        "**Monitor Update Status**: Regularly check update status and logs:",
                        "  • Use Console.app to view update-related system logs",
                        "  • Check Software Update history for installed updates",
                        "  • Verify that security updates are being applied promptly"
                    ],
                    commonMistakes: [
                        "❌ **Disabling Automatic Updates**: Many users disable automatic updates due to concerns about disruption, but this leaves their system vulnerable to known attacks.",
                        "❌ **Selective Update Installation**: Only installing some types of updates while ignoring others creates security gaps that attackers can exploit.",
                        "❌ **Poor Update Scheduling**: Scheduling updates during critical work hours can cause disruption and lead users to disable the feature entirely.",
                        "❌ **Ignoring Restart Requirements**: Some updates require system restarts. Delaying restarts leaves systems in a vulnerable state.",
                        "❌ **Not Monitoring Update Status**: Failing to verify that updates are actually installing can leave systems unprotected without the user knowing.",
                        "❌ **Using Unreliable Internet**: Automatic updates require stable internet connections. Poor connectivity can prevent critical security updates from installing.",
                        "❌ **Disabling Updates for 'Stability'**: Some users disable updates thinking they'll improve system stability, but this actually increases security risks significantly."
                    ],
                    securityBenefits: [
                        "🛡️ **Proactive Vulnerability Management**: Automatically closes security holes before they can be exploited by attackers.",
                        "🛡️ **Zero-Configuration Security**: Provides enterprise-level security without requiring technical expertise or manual intervention.",
                        "🛡️ **Rapid Response to Threats**: Apple can push critical security updates within hours of discovering vulnerabilities.",
                        "🛡️ **Comprehensive Coverage**: Updates cover the entire system stack from firmware to applications.",
                        "🛡️ **Verification and Integrity**: All updates are cryptographically verified to ensure authenticity and prevent tampering.",
                        "🛡️ **Rollback Capability**: Ability to revert problematic updates if they cause compatibility issues.",
                        "🛡️ **Compliance Support**: Helps meet regulatory requirements for maintaining current security patches."
                    ],
                    troubleshootingTips: [
                        "🔧 **Updates Not Downloading**: Check internet connectivity and ensure you're not using a metered connection that might block large downloads.",
                        "🔧 **Installation Failures**: If updates fail to install, check available disk space and ensure the system isn't in use during installation.",
                        "🔧 **Restart Required**: Some updates require system restarts. Plan for this when scheduling updates during important work periods.",
                        "🔧 **Performance Impact**: Large updates may temporarily slow system performance during download and installation. This is normal and temporary.",
                        "🔧 **Compatibility Issues**: If an update causes problems with specific software, check with the software vendor for compatibility updates.",
                        "🔧 **Network Issues**: Corporate or restricted networks may block update downloads. Check with your network administrator for update policies.",
                        "🔧 **Storage Space**: Ensure sufficient free disk space (at least 15GB) for major system updates to download and install properly."
                    ],
                    relatedConcepts: [
                        "**Patch Management**: The systematic process of identifying, acquiring, installing, and verifying patches for software vulnerabilities.",
                        "**Vulnerability Management**: The ongoing process of identifying, classifying, prioritizing, and mitigating security vulnerabilities.",
                        "**Software Maintenance**: The process of modifying software after delivery to correct faults, improve performance, or adapt to changes.",
                        "**Zero-Day Exploits**: Attacks that exploit previously unknown vulnerabilities before patches are available.",
                        "**N-Day Exploits**: Attacks that exploit known vulnerabilities for which patches are available but not yet applied.",
                        "**Code Signing**: The process of digitally signing software to verify its authenticity and integrity.",
                        "**Secure Software Development Lifecycle (SSDLC)**: A framework for developing secure software from design through deployment."
                    ],
                    additionalResources: [
                        "📘 **Apple's Software Update Documentation**: Official guide to macOS update mechanisms and configuration.",
                        "📘 **NIST Cybersecurity Framework**: Government guidelines for vulnerability management and patch deployment.",
                        "📘 **CVE Database**: Common Vulnerabilities and Exposures database for tracking security vulnerabilities.",
                        "📘 **SANS Patch Management Guide**: Best practices for enterprise patch management and vulnerability remediation.",
                        "📘 **OWASP Top 10**: Common web application vulnerabilities and mitigation strategies.",
                        "📘 **CIS Controls**: Industry-standard security controls including vulnerability management."
                    ]
                ),
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
                learningMaterials: LearningMaterials(
                    overview: """
                    A strong login password serves as the foundational layer of security for your Mac, acting as the primary barrier against unauthorized access to your personal data, files, and system resources. In the modern threat landscape, password security is more critical than ever, as attackers employ increasingly sophisticated methods to crack weak passwords.
                    
                    **Password Security Fundamentals:**
                    • **Complexity Requirements**: Strong passwords combine multiple character types (uppercase, lowercase, numbers, symbols)
                    • **Length Matters**: Longer passwords are exponentially more secure than shorter ones
                    • **Uniqueness**: Each account should have a completely unique password
                    • **Regular Updates**: Passwords should be changed periodically, especially after potential breaches
                    • **No Personal Information**: Avoid using easily discoverable personal details
                    
                    **Modern Password Standards:**
                    • **Minimum 12-16 characters** for high-security applications
                    • **Passphrases**: Multiple words strung together are often more secure and memorable
                    • **Avoid Dictionary Words**: Don't use common words, even with character substitutions
                    • **No Patterns**: Avoid keyboard patterns, sequences, or repeated characters
                    • **Random Generation**: Use password managers to generate truly random passwords
                    
                    **Authentication Integration:**
                    • **Touch ID/Face ID**: Biometric authentication provides additional security layers
                    • **Two-Factor Authentication**: Combine passwords with additional verification methods
                    • **Hardware Security Keys**: Physical keys provide the highest level of authentication security
                    • **Single Sign-On (SSO)**: Enterprise solutions that centralize authentication management
                    
                    **Password Manager Benefits:**
                    • **Secure Generation**: Creates cryptographically strong passwords
                    • **Encrypted Storage**: Safely stores passwords with strong encryption
                    • **Auto-Fill**: Reduces the temptation to use weak, memorable passwords
                    • **Breach Monitoring**: Alerts you when passwords are compromised in data breaches
                    • **Cross-Device Sync**: Secure access to passwords across all your devices
                    """,
                    whyImportant: """
                    Password security is the cornerstone of digital security, yet it remains one of the most commonly exploited attack vectors. Weak passwords create vulnerabilities that can lead to catastrophic security breaches:
                    
                    🚨 **Brute Force Attacks**: Automated tools can attempt thousands of password combinations per second:
                       • Simple 6-digit passwords can be cracked in minutes
                       • Common dictionary words are cracked in seconds
                       • Personal information makes passwords easily guessable
                       • Attackers use GPU clusters to accelerate password cracking
                    
                    🚨 **Credential Stuffing**: Reused passwords enable large-scale attacks:
                       • Data breaches expose millions of username/password combinations
                       • Attackers test these credentials across multiple sites
                       • 65% of people reuse passwords across accounts
                       • A single breach can compromise dozens of accounts
                    
                    🚨 **Social Engineering**: Weak passwords enable sophisticated attacks:
                       • Attackers use personal information to guess passwords
                       • Social media profiles provide clues for password creation
                       • Phishing attacks trick users into revealing passwords
                       • Shoulder surfing captures passwords in public spaces
                    
                    🚨 **Business Impact**: Password compromises affect more than personal data:
                       • Corporate accounts can be compromised through weak passwords
                       • Financial accounts become vulnerable to theft
                       • Email accounts provide access to password reset functions
                       • Social media accounts can be used for identity theft
                    
                    **Real-World Examples**: The 2020 Twitter breach, where high-profile accounts were compromised, was enabled by social engineering attacks that bypassed two-factor authentication by targeting employees with weak passwords. The Colonial Pipeline ransomware attack began with a compromised password that hadn't been changed from its default value.
                    
                    **Statistics**: According to Verizon's 2022 Data Breach Investigations Report, 80% of hacking-related breaches involve weak or stolen passwords. The average cost of a data breach is $4.24 million, with password-related breaches being among the most common and costly.
                    """,
                    stepByStepGuide: [
                        "**Access User Settings**: Open System Preferences (System Settings on macOS Ventura+) and navigate to Users & Groups.",
                        "**Authenticate**: Click the lock icon in the bottom-left corner and enter your current administrator password.",
                        "**Select User Account**: Click on your user account in the left sidebar to select it for password changes.",
                        "**Initiate Password Change**: Click the 'Change Password' button to begin the password update process.",
                        "**Verify Current Password**: Enter your current password in the 'Old Password' field for security verification.",
                        "**Create Strong Password**: In the 'New Password' field, create a password that follows these guidelines:",
                        "  • Use at least 12-16 characters (longer is better)",
                        "  • Include uppercase and lowercase letters",
                        "  • Include numbers and special characters",
                        "  • Avoid personal information, dictionary words, or patterns",
                        "  • Consider using a passphrase (multiple random words)",
                        "**Confirm New Password**: Re-enter your new password in the 'Verify' field to ensure accuracy.",
                        "**Add Password Hint** (Optional): Create a hint that helps you remember the password without revealing it to others.",
                        "**Complete Change**: Click 'Change Password' to apply the new password to your account.",
                        "**Test New Password**: Log out and log back in to verify the new password works correctly.",
                        "**Update Password Manager**: If you use a password manager, update the stored password for this account.",
                        "**Enable Additional Security**: Consider enabling Touch ID, Face ID, or two-factor authentication for enhanced security."
                    ],
                    commonMistakes: [
                        "❌ **Using Weak Patterns**: Common weak passwords include 'password', '123456', 'qwerty', and 'admin' - these are cracked instantly by automated tools.",
                        "❌ **Personal Information**: Using names, birthdays, pet names, or addresses makes passwords easily guessable through social engineering.",
                        "❌ **Password Reuse**: Using the same password across multiple accounts creates a single point of failure - if one account is compromised, all are at risk.",
                        "❌ **Short Length**: Passwords under 8 characters are vulnerable to brute force attacks, even with complex character sets.",
                        "❌ **Predictable Substitutions**: Replacing letters with numbers (like 'P@ssw0rd') doesn't significantly improve security against modern attack methods.",
                        "❌ **Not Using Password Managers**: Relying on memory leads to weak, reused passwords. Password managers solve this problem effectively.",
                        "❌ **Sharing Passwords**: Sharing passwords with others, even trusted individuals, increases the risk of compromise and violates security best practices."
                    ],
                    securityBenefits: [
                        "🔐 **Strong Authentication Foundation**: A strong password provides the essential first layer of security for your Mac and all associated accounts.",
                        "🔐 **Protection Against Automated Attacks**: Complex passwords resist brute force and dictionary attacks that target weak passwords.",
                        "🔐 **Reduced Risk of Credential Theft**: Unique passwords limit the impact of data breaches and credential stuffing attacks.",
                        "🔐 **Compliance with Security Standards**: Strong passwords help meet requirements for cybersecurity frameworks and regulations.",
                        "🔐 **Foundation for Multi-Factor Authentication**: Strong passwords work effectively with additional security layers like biometrics and hardware keys.",
                        "🔐 **Personal Data Protection**: Secure passwords protect your personal files, financial information, and private communications.",
                        "🔐 **Business Security**: Strong passwords protect work accounts and prevent business email compromise attacks."
                    ],
                    troubleshootingTips: [
                        "🔧 **Password Manager Integration**: Use a reputable password manager like 1Password, Bitwarden, or Apple's built-in Keychain to generate and store strong passwords.",
                        "🔧 **Biometric Authentication**: Enable Touch ID or Face ID to reduce reliance on typing passwords while maintaining security.",
                        "🔧 **Passphrase Strategy**: Consider using passphrases (like 'Coffee-Mountain-Sunset-42!') which are easier to remember but still highly secure.",
                        "🔧 **Regular Updates**: Change passwords every 90 days for high-security accounts, or immediately after any suspected compromise.",
                        "🔧 **Recovery Options**: Set up account recovery methods (like trusted phone numbers) before you need them, in case you forget your password.",
                        "🔧 **Security Questions**: Use strong, unique answers to security questions that can't be easily researched or guessed.",
                        "🔧 **Backup Access**: Ensure you have alternative ways to access your Mac (like FileVault recovery keys) in case of password lockout."
                    ],
                    relatedConcepts: [
                        "**Authentication**: The process of verifying the identity of a user, device, or system.",
                        "**Password Hashing**: Cryptographic techniques used to securely store password data.",
                        "**Multi-Factor Authentication (MFA)**: Security systems that require multiple forms of verification.",
                        "**Biometric Authentication**: Security methods that use unique physical characteristics for identification.",
                        "**Hardware Security Keys**: Physical devices that provide strong authentication through cryptographic protocols.",
                        "**Password Managers**: Software tools that securely generate, store, and manage passwords.",
                        "**Credential Management**: The systematic approach to managing user authentication information securely."
                    ],
                    additionalResources: [
                        "📖 **NIST Password Guidelines**: National Institute of Standards and Technology recommendations for password security.",
                        "📖 **OWASP Authentication Cheat Sheet**: Open source security practices for implementing secure authentication.",
                        "📖 **SANS Password Security Training**: Comprehensive educational resources on password security best practices.",
                        "📖 **Password Manager Reviews**: Independent evaluations of password management solutions and their security features.",
                        "📖 **Have I Been Pwned**: Service that checks if your passwords have been compromised in data breaches.",
                        "📖 **Two-Factor Authentication Setup Guides**: Step-by-step instructions for enabling additional security layers."
                    ]
                ),
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
                learningMaterials: createBasicLearningMaterials(
                    overview: "DNS (Domain Name System) servers translate domain names to IP addresses. Privacy-focused DNS servers don't log your queries and may block malicious domains.",
                    whyImportant: "Your ISP's default DNS servers can track and log your browsing activity. Privacy-focused DNS servers protect your browsing privacy and may provide additional security features.",
                    benefits: [
                        "Improved browsing privacy",
                        "Protection against malicious domains",
                        "Faster DNS resolution",
                        "No logging of your queries"
                    ],
                    mistakes: [
                        "Not removing old DNS servers",
                        "Using untrusted DNS providers",
                        "Not testing DNS configuration"
                    ],
                    concepts: [
                        "DNS privacy",
                        "Domain name resolution",
                        "Network security",
                        "Privacy protection"
                    ]
                ),
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
                learningMaterials: nil,
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
                learningMaterials: nil,
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
                learningMaterials: nil,
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
                learningMaterials: nil,
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
                learningMaterials: nil,
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
                learningMaterials: nil,
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
                learningMaterials: nil,
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
                learningMaterials: nil,
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
                learningMaterials: nil,
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
        saveTaskProgress()
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
        
        // Save progress and check for day progression
        saveTaskProgress()
        checkDayProgression()
    }
    
    func verifyTask(_ task: SecurityTask) {
        guard var progress = taskProgress[task.id] else { return }
        
        progress.status = .verified
        progress.verifiedAt = Date()
        
        taskProgress[task.id] = progress
        
        // Award bonus XP for verification
        let bonusXP = task.xpReward / 2
        gameModel?.addXP(bonusXP)
        
        // Save progress and check for day progression
        saveTaskProgress()
        checkDayProgression()
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
    
    private func checkDayProgression() {
        // Check if current day is complete and advance to next day
        let currentDayProgress = getDayProgress(day: currentDay)
        if currentDayProgress.completed == currentDayProgress.total && currentDay < 3 {
            currentDay += 1
            saveCurrentDay()
        }
    }
    
    private func checkAchievements() {
        let completedCount = getCompletedTasksCount()
        var achievementsUpdated = false
        
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
                    achievementsUpdated = true
                }
            }
        }
        
        // Save achievements if any were updated
        if achievementsUpdated {
            saveAchievements()
        }
    }
}
