import Foundation

// MARK: - Security Scan Results
struct SecurityScanResult: Equatable {
    let name: String
    let passed: Bool
    let message: String
    let points: Int
    let fixInstructions: String
    
    static func == (lhs: SecurityScanResult, rhs: SecurityScanResult) -> Bool {
        return lhs.name == rhs.name && lhs.passed == rhs.passed
    }
}

// MARK: - Security Scanner
class SecurityScanner: ObservableObject {
    @Published var scanResults: [SecurityScanResult] = []
    @Published var totalScore: Int = 0
    @Published var isScanning: Bool = false
    
    func performSecurityScan() {
        isScanning = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let results = [
                self.checkOSUpdates(),
                self.checkFileVault(),
                self.checkSafariSecurity()
            ]
            
            DispatchQueue.main.async {
                self.scanResults = results
                self.calculateTotalScore()
                self.isScanning = false
            }
        }
    }
    
    private func calculateTotalScore() {
        totalScore = scanResults.reduce(0) { $0 + ($1.passed ? $1.points : 0) }
    }
    
    // MARK: - OS Updates Check
    private func checkOSUpdates() -> SecurityScanResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/softwareupdate")
        process.arguments = ["--list"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            // If no updates are available, the output will be empty or contain "No new software available"
            let hasUpdates = !output.isEmpty && !output.contains("No new software available")
            
            if hasUpdates {
                return SecurityScanResult(
                    name: "OS Updates",
                    passed: false,
                    message: "System updates are available",
                    points: 40,
                    fixInstructions: "Run 'softwareupdate -i -a' in Terminal or go to System Settings > General > Software Update"
                )
            } else {
                return SecurityScanResult(
                    name: "OS Updates",
                    passed: true,
                    message: "System is up to date",
                    points: 40,
                    fixInstructions: "Keep checking for updates regularly"
                )
            }
        } catch {
            return SecurityScanResult(
                name: "OS Updates",
                passed: false,
                message: "Failed to check for updates",
                points: 40,
                fixInstructions: "Check System Settings > General > Software Update manually"
            )
        }
    }
    
    // MARK: - FileVault Check
    private func checkFileVault() -> SecurityScanResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/fdesetup")
        process.arguments = ["status"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            let isEnabled = output.contains("FileVault is On")
            
            if isEnabled {
                return SecurityScanResult(
                    name: "FileVault Encryption",
                    passed: true,
                    message: "FileVault is enabled and protecting your data",
                    points: 30,
                    fixInstructions: "FileVault is properly configured"
                )
            } else {
                return SecurityScanResult(
                    name: "FileVault Encryption",
                    passed: false,
                    message: "FileVault is disabled - your data is not encrypted",
                    points: 30,
                    fixInstructions: "Go to System Settings > Privacy & Security > FileVault to enable encryption"
                )
            }
        } catch {
            return SecurityScanResult(
                name: "FileVault Encryption",
                passed: false,
                message: "Failed to check FileVault status",
                points: 30,
                fixInstructions: "Check System Settings > Privacy & Security > FileVault manually"
            )
        }
    }
    
    // MARK: - Safari Security Check
    private func checkSafariSecurity() -> SecurityScanResult {
        // Check Safari's tracking prevention setting
        let trackingPrevention = UserDefaults.standard.object(forKey: "com.apple.Safari.ContentPageBlockerState") as? Int ?? 0
        
        // Check if Safari auto-updates are enabled (simplified check)
        let autoUpdates = UserDefaults.standard.bool(forKey: "com.apple.Safari.AutoUpdateEnabled")
        
        // For demo purposes, we'll assume Safari is secure if tracking prevention is enabled
        let isSecure = trackingPrevention > 0 || autoUpdates
        
        if isSecure {
            return SecurityScanResult(
                name: "Safari Security",
                passed: true,
                message: "Safari security settings are configured",
                points: 20,
                fixInstructions: "Keep Safari updated and maintain privacy settings"
            )
        } else {
            return SecurityScanResult(
                name: "Safari Security",
                passed: false,
                message: "Safari privacy settings need attention",
                points: 20,
                fixInstructions: "Go to Safari > Settings > Privacy and enable 'Prevent Cross-Site Tracking'"
            )
        }
    }
    
    // MARK: - Fix Actions
    func runOSUpdate() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/softwareupdate")
        process.arguments = ["-i", "-a"]
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try process.run()
                process.waitUntilExit()
                
                DispatchQueue.main.async {
                    // Re-scan after update
                    self.performSecurityScan()
                }
            } catch {
                print("Failed to run software update: \(error)")
            }
        }
    }
}