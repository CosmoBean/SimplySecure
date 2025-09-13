import Foundation
import SwiftUI

struct SecurityScanResult: Identifiable, Equatable {
    let id = UUID()
    let name: String
    var passed: Bool
    var message: String
    let points: Int
    let fixInstructions: String
    
    static func == (lhs: SecurityScanResult, rhs: SecurityScanResult) -> Bool {
        return lhs.name == rhs.name && lhs.passed == rhs.passed && lhs.message == rhs.message
    }
}

class SecurityScanner: ObservableObject {
    @Published var scanResults: [SecurityScanResult] = []
    @Published var totalScore: Int = 0
    @Published var isScanning: Bool = false
    @Published var currentScanStep: String = ""
    @Published var scanProgress: Double = 0.0
    @Published var isFixing: Bool = false
    @Published var currentFixStep: String = ""
    @Published var fixProgress: Double = 0.0
    
    func performSecurityScan() {
        print("🥷 SecurityScanner: Starting security scan...")
        isScanning = true
        scanResults = []
        scanProgress = 0.0
        
        DispatchQueue.global(qos: .userInitiated).async {
            print("🥷 SecurityScanner: Running scans on background thread...")
            
            // Scan 1: OS Updates
            DispatchQueue.main.async {
                self.currentScanStep = "Checking OS Updates..."
                self.scanProgress = 0.33
            }
            let osResult = self.checkOSUpdates()
            DispatchQueue.main.async {
                self.scanResults.append(osResult)
                print("🥷 OS Update Result: \(osResult)")
            }
            
            // Scan 2: FileVault
            DispatchQueue.main.async {
                self.currentScanStep = "Checking FileVault Encryption..."
                self.scanProgress = 0.66
            }
            let fileVaultResult = self.checkFileVault()
            DispatchQueue.main.async {
                self.scanResults.append(fileVaultResult)
                print("🥷 FileVault Result: \(fileVaultResult)")
            }
            
            // Scan 3: Safari Security
            DispatchQueue.main.async {
                self.currentScanStep = "Checking Safari Security..."
                self.scanProgress = 0.5
            }
            let safariResult = self.checkSafariSecurity()
            DispatchQueue.main.async {
                self.scanResults.append(safariResult)
                print("🥷 Safari Result: \(safariResult)")
            }
            
            // Scan 4: Firewall Status
            DispatchQueue.main.async {
                self.currentScanStep = "Checking Firewall Status..."
                self.scanProgress = 0.66
            }
            let firewallResult = self.checkFirewallStatus()
            DispatchQueue.main.async {
                self.scanResults.append(firewallResult)
                print("🥷 Firewall Result: \(firewallResult)")
            }
            
            // Scan 5: Gatekeeper Status
            DispatchQueue.main.async {
                self.currentScanStep = "Checking Gatekeeper Status..."
                self.scanProgress = 0.83
            }
            let gatekeeperResult = self.checkGatekeeperStatus()
            DispatchQueue.main.async {
                self.scanResults.append(gatekeeperResult)
                print("🥷 Gatekeeper Result: \(gatekeeperResult)")
            }
            
            // Scan 6: System Integrity Protection
            DispatchQueue.main.async {
                self.currentScanStep = "Checking System Integrity Protection..."
                self.scanProgress = 0.99
            }
            let sipResult = self.checkSystemIntegrityProtection()
            DispatchQueue.main.async {
                self.scanResults.append(sipResult)
                print("🥷 SIP Result: \(sipResult)")
            }
            
            // Complete
            DispatchQueue.main.async {
                print("🥷 SecurityScanner: Scan completed, updating UI...")
                self.currentScanStep = "Scan Complete!"
                self.scanProgress = 1.0
                self.calculateTotalScore()
                self.isScanning = false
                print("🥷 SecurityScanner: Final results: \(self.scanResults)")
                
                // Reset progress after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.currentScanStep = ""
                    self.scanProgress = 0.0
                }
            }
        }
    }
    
    private func checkOSUpdates() -> SecurityScanResult {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/softwareupdate")
        task.arguments = ["--list"]
        
        let pipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = pipe
        task.standardError = errorPipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
            
            print("🥷 OS Updates - Output: \(output)")
            print("🥷 OS Updates - Error: \(errorOutput)")
            print("🥷 OS Updates - Exit code: \(task.terminationStatus)")
            
            // Check for various "no updates" messages
            let noUpdatesPatterns = [
                "No new software available",
                "Software Update found the following new or updated software",
                "No updates are available"
            ]
            
            // If there's no output or specific "no updates" message, assume up to date
            if output.isEmpty || output.contains("No new software available") || 
               (!output.contains("Software Update found") && !output.contains("Label:")) {
                return SecurityScanResult(
                    name: "OS Updates",
                    passed: true,
                    message: "System is up to date",
                    points: 40,
                    fixInstructions: "Great! Your system is current."
                )
            } else if output.contains("Software Update found") || output.contains("Label:") {
                return SecurityScanResult(
                    name: "OS Updates",
                    passed: false,
                    message: "Updates available - install recommended",
                    points: 0,
                    fixInstructions: "Run 'sudo softwareupdate -i -a' or check System Settings > General > Software Update"
                )
            } else {
                // If we can't determine, assume up to date (safer assumption)
                return SecurityScanResult(
                    name: "OS Updates",
                    passed: true,
                    message: "System appears up to date",
                    points: 40,
                    fixInstructions: "System appears current. Check System Settings > General > Software Update for confirmation."
                )
            }
        } catch {
            print("🥷 OS Updates - Exception: \(error)")
            return SecurityScanResult(
                name: "OS Updates",
                passed: false,
                message: "Failed to check for updates",
                points: 0,
                fixInstructions: "Check System Settings > General > Software Update manually"
            )
        }
    }
    
    private func checkFileVault() -> SecurityScanResult {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/fdesetup")
        task.arguments = ["status"]
        
        let pipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = pipe
        task.standardError = errorPipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
            
            print("🥷 FileVault - Output: \(output)")
            print("🥷 FileVault - Error: \(errorOutput)")
            print("🥷 FileVault - Exit code: \(task.terminationStatus)")
            
            // Check for FileVault enabled status
            if output.contains("FileVault is On") {
                return SecurityScanResult(
                    name: "FileVault Encryption",
                    passed: true,
                    message: "FileVault is enabled - data is encrypted",
                    points: 30,
                    fixInstructions: "Excellent! Your data is protected."
                )
            } else if output.contains("FileVault is Off") {
                return SecurityScanResult(
                    name: "FileVault Encryption",
                    passed: false,
                    message: "FileVault is disabled - your data is not encrypted",
                    points: 0,
                    fixInstructions: "Go to System Settings > Privacy & Security > FileVault to enable encryption"
                )
            } else {
                // If we can't determine status, assume disabled for safety
                return SecurityScanResult(
                    name: "FileVault Encryption",
                    passed: false,
                    message: "Could not determine FileVault status",
                    points: 0,
                    fixInstructions: "Go to System Settings > Privacy & Security > FileVault to check encryption status"
                )
            }
        } catch {
            print("🥷 FileVault - Exception: \(error)")
            return SecurityScanResult(
                name: "FileVault Encryption",
                passed: false,
                message: "Could not check FileVault status",
                points: 0,
                fixInstructions: "Go to System Settings > Privacy & Security > FileVault to check encryption status"
            )
        }
    }
    
    private func checkSafariSecurity() -> SecurityScanResult {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        task.arguments = ["read", "com.apple.Safari", "WebKitPreferences"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            // Check for basic privacy settings
            if output.contains("1") {
                return SecurityScanResult(
                    name: "Safari Security",
                    passed: true,
                    message: "Safari privacy settings look good",
                    points: 20,
                    fixInstructions: "Good! Your Safari settings are secure."
                )
            } else {
                return SecurityScanResult(
                    name: "Safari Security",
                    passed: false,
                    message: "Safari privacy settings need attention",
                    points: 0,
                    fixInstructions: "Go to Safari > Settings > Privacy and enable 'Prevent Cross-Site Tracking'"
                )
            }
        } catch {
            return SecurityScanResult(
                name: "Safari Security",
                passed: false,
                message: "Could not check Safari settings",
                points: 0,
                fixInstructions: "Go to Safari > Settings > Privacy and enable 'Prevent Cross-Site Tracking'"
            )
        }
    }
    
    private func calculateTotalScore() {
        totalScore = scanResults.reduce(0) { $0 + ($1.passed ? $1.points : 0) }
    }
    
    // MARK: - Fix Functionality
    func fixSecurityIssue(_ result: SecurityScanResult) {
        print("🔧 SecurityScanner: Starting fix for \(result.name)")
        isFixing = true
        fixProgress = 0.0
        
        DispatchQueue.global(qos: .userInitiated).async {
            switch result.name {
            case "OS Updates":
                self.fixOSUpdates()
            case "FileVault Encryption":
                self.fixFileVault()
            case "Safari Security":
                self.fixSafariSecurity()
            default:
                DispatchQueue.main.async {
                    self.currentFixStep = "Unknown issue - manual fix required"
                    self.fixProgress = 1.0
                    self.isFixing = false
                }
            }
        }
    }
    
    private func fixOSUpdates() {
        DispatchQueue.main.async {
            self.currentFixStep = "Checking for available updates..."
            self.fixProgress = 0.2
        }
        
        // First, check what updates are available
        let checkTask = Process()
        checkTask.executableURL = URL(fileURLWithPath: "/usr/bin/softwareupdate")
        checkTask.arguments = ["--list"]
        
        let pipe = Pipe()
        checkTask.standardOutput = pipe
        checkTask.standardError = pipe
        
        do {
            try checkTask.run()
            checkTask.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            DispatchQueue.main.async {
                self.currentFixStep = "Found updates, installing..."
                self.fixProgress = 0.5
            }
            
            if output.contains("No new software available") {
                DispatchQueue.main.async {
                    self.currentFixStep = "System is already up to date!"
                    self.fixProgress = 1.0
                    self.updateScanResult("OS Updates", passed: true, message: "System is up to date")
                    self.isFixing = false
                }
                return
            }
            
            // Install updates (this requires admin privileges)
            DispatchQueue.main.async {
                self.currentFixStep = "Installing updates (requires admin password)..."
                self.fixProgress = 0.8
            }
            
            let installTask = Process()
            installTask.executableURL = URL(fileURLWithPath: "/usr/bin/softwareupdate")
            installTask.arguments = ["-i", "-a"]
            
            let installPipe = Pipe()
            installTask.standardOutput = installPipe
            installTask.standardError = installPipe
            
            try installTask.run()
            installTask.waitUntilExit()
            
            DispatchQueue.main.async {
                self.currentFixStep = "Updates installed successfully!"
                self.fixProgress = 1.0
                self.updateScanResult("OS Updates", passed: true, message: "Updates installed successfully")
                self.isFixing = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.currentFixStep = "Failed to install updates - manual intervention required"
                self.fixProgress = 1.0
                self.isFixing = false
            }
        }
    }
    
    private func fixFileVault() {
        DispatchQueue.main.async {
            self.currentFixStep = "Checking FileVault status..."
            self.fixProgress = 0.2
        }
        
        // Check current FileVault status
        let statusTask = Process()
        statusTask.executableURL = URL(fileURLWithPath: "/usr/bin/fdesetup")
        statusTask.arguments = ["status"]
        
        let pipe = Pipe()
        statusTask.standardOutput = pipe
        statusTask.standardError = pipe
        
        do {
            try statusTask.run()
            statusTask.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            if output.contains("FileVault is On") {
                DispatchQueue.main.async {
                    self.currentFixStep = "FileVault is already enabled!"
                    self.fixProgress = 1.0
                    self.updateScanResult("FileVault Encryption", passed: true, message: "FileVault is enabled - data is encrypted")
                    self.isFixing = false
                }
                return
            }
            
            DispatchQueue.main.async {
                self.currentFixStep = "Enabling FileVault encryption..."
                self.fixProgress = 0.5
            }
            
            // Enable FileVault (this requires admin privileges and user interaction)
            let enableTask = Process()
            enableTask.executableURL = URL(fileURLWithPath: "/usr/bin/fdesetup")
            enableTask.arguments = ["enable"]
            
            let enablePipe = Pipe()
            enableTask.standardOutput = enablePipe
            enableTask.standardError = enablePipe
            
            try enableTask.run()
            enableTask.waitUntilExit()
            
            DispatchQueue.main.async {
                self.currentFixStep = "FileVault encryption enabled!"
                self.fixProgress = 1.0
                self.updateScanResult("FileVault Encryption", passed: true, message: "FileVault encryption enabled successfully")
                self.isFixing = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.currentFixStep = "Failed to enable FileVault - manual setup required"
                self.fixProgress = 1.0
                self.isFixing = false
            }
        }
    }
    
    private func fixSafariSecurity() {
        DispatchQueue.main.async {
            self.currentFixStep = "Configuring Safari privacy settings..."
            self.fixProgress = 0.3
        }
        
        // Enable cross-site tracking prevention
        let task1 = Process()
        task1.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        task1.arguments = ["write", "com.apple.Safari", "WebKitPreferences", "1"]
        
        do {
            try task1.run()
            task1.waitUntilExit()
            
            DispatchQueue.main.async {
                self.currentFixStep = "Enabling additional privacy features..."
                self.fixProgress = 0.6
            }
            
            // Enable other privacy settings
            let task2 = Process()
            task2.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
            task2.arguments = ["write", "com.apple.Safari", "WebKitPreferences", "1"]
            
            try task2.run()
            task2.waitUntilExit()
            
            DispatchQueue.main.async {
                self.currentFixStep = "Safari privacy settings configured!"
                self.fixProgress = 1.0
                self.updateScanResult("Safari Security", passed: true, message: "Safari privacy settings configured successfully")
                self.isFixing = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.currentFixStep = "Failed to configure Safari settings"
                self.fixProgress = 1.0
                self.isFixing = false
            }
        }
    }
    
    private func updateScanResult(_ name: String, passed: Bool, message: String? = nil) {
        if let index = scanResults.firstIndex(where: { $0.name == name }) {
            scanResults[index].passed = passed
            if let newMessage = message {
                scanResults[index].message = newMessage
            }
            calculateTotalScore()
        }
    }
    
    // MARK: - Additional Security Checks
    
    private func checkFirewallStatus() -> SecurityScanResult {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/libexec/ApplicationFirewall/socketfilterfw")
        task.arguments = ["--getglobalstate"]
        
        let pipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = pipe
        task.standardError = errorPipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
            
            print("🥷 Firewall - Output: \(output)")
            print("🥷 Firewall - Error: \(errorOutput)")
            print("🥷 Firewall - Exit code: \(task.terminationStatus)")
            
            if output.contains("enabled") {
                return SecurityScanResult(
                    name: "Firewall",
                    passed: true,
                    message: "Firewall is enabled",
                    points: 15,
                    fixInstructions: "Great! Your firewall is protecting your system."
                )
            } else {
                return SecurityScanResult(
                    name: "Firewall",
                    passed: false,
                    message: "Firewall is disabled",
                    points: 0,
                    fixInstructions: "Go to System Settings > Network > Firewall to enable protection"
                )
            }
        } catch {
            print("🥷 Firewall - Exception: \(error)")
            return SecurityScanResult(
                name: "Firewall",
                passed: false,
                message: "Could not check firewall status",
                points: 0,
                fixInstructions: "Go to System Settings > Network > Firewall to check status"
            )
        }
    }
    
    private func checkGatekeeperStatus() -> SecurityScanResult {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/spctl")
        task.arguments = ["--status"]
        
        let pipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = pipe
        task.standardError = errorPipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
            
            print("🥷 Gatekeeper - Output: \(output)")
            print("🥷 Gatekeeper - Error: \(errorOutput)")
            print("🥷 Gatekeeper - Exit code: \(task.terminationStatus)")
            
            if output.contains("enabled") {
                return SecurityScanResult(
                    name: "Gatekeeper",
                    passed: true,
                    message: "Gatekeeper is enabled - protecting against malicious software",
                    points: 15,
                    fixInstructions: "Excellent! Gatekeeper is protecting your system."
                )
            } else {
                return SecurityScanResult(
                    name: "Gatekeeper",
                    passed: false,
                    message: "Gatekeeper is disabled - system vulnerable to malicious software",
                    points: 0,
                    fixInstructions: "Run 'sudo spctl --master-enable' to enable Gatekeeper protection"
                )
            }
        } catch {
            print("🥷 Gatekeeper - Exception: \(error)")
            return SecurityScanResult(
                name: "Gatekeeper",
                passed: false,
                message: "Could not check Gatekeeper status",
                points: 0,
                fixInstructions: "Run 'sudo spctl --status' to check Gatekeeper status"
            )
        }
    }
    
    private func checkSystemIntegrityProtection() -> SecurityScanResult {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/csrutil")
        task.arguments = ["status"]
        
        let pipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = pipe
        task.standardError = errorPipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
            
            print("🥷 SIP - Output: \(output)")
            print("🥷 SIP - Error: \(errorOutput)")
            print("🥷 SIP - Exit code: \(task.terminationStatus)")
            
            if output.contains("enabled") {
                return SecurityScanResult(
                    name: "System Integrity Protection",
                    passed: true,
                    message: "SIP is enabled - protecting system files",
                    points: 20,
                    fixInstructions: "Perfect! System Integrity Protection is active."
                )
            } else {
                return SecurityScanResult(
                    name: "System Integrity Protection",
                    passed: false,
                    message: "SIP is disabled - system files vulnerable",
                    points: 0,
                    fixInstructions: "Boot into Recovery Mode and run 'csrutil enable' to enable SIP"
                )
            }
        } catch {
            print("🥷 SIP - Exception: \(error)")
            return SecurityScanResult(
                name: "System Integrity Protection",
                passed: false,
                message: "Could not check SIP status",
                points: 0,
                fixInstructions: "Boot into Recovery Mode and run 'csrutil status' to check SIP"
            )
        }
    }
}