import Foundation
import SwiftUI

// MARK: - App Permission Service

class AppPermissionService: ObservableObject {
    @Published var isMonitoring = false
    @Published var pendingInstallations: [AppInstallation] = []
    @Published var permissionOverlayVisible = false
    @Published var currentInstallation: AppInstallation?
    
    private var fileSystemWatcher: DispatchSourceFileSystemObject?
    private let applicationsPath = "/Applications"
    private let userApplicationsPath = NSHomeDirectory() + "/Applications"
    private let privacyAnalyzer: PrivacyPolicyAnalyzer
    private let perplexityService: PerplexityService
    
    // MARK: - Initialization
    
    init() {
        let geminiService = GeminiAPIService(apiKey: GeminiConfig.shared.apiKey)
        self.privacyAnalyzer = PrivacyPolicyAnalyzer(geminiService: geminiService)
        self.perplexityService = PerplexityService(apiKey: PerplexityConfig.shared.apiKey)
        setupFileSystemMonitoring()
        
        // Automatically start tracking all existing apps on initialization
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.startAutomaticTracking()
        }
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Monitoring
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        NSLog("🔍 AppPermissionService: Starting app installation monitoring")
        isMonitoring = true
        setupFileSystemMonitoring()
    }
    
    private func startAutomaticTracking() {
        NSLog("🚀 AppPermissionService: Starting automatic app tracking on initialization")
        isMonitoring = true
        
        // Scan all existing apps immediately
        checkForNewApplications(forceRescan: true)
        
        NSLog("✅ AppPermissionService: Automatic tracking started - all existing apps will be processed")
    }
    
    func stopMonitoring() {
        guard isMonitoring else { return }
        
        NSLog("🔍 AppPermissionService: Stopping app installation monitoring")
        isMonitoring = false
        fileSystemWatcher?.cancel()
        fileSystemWatcher = nil
    }
    
    func clearPendingInstallations() {
        NSLog("🔍 AppPermissionService: Clearing pending installations cache")
        pendingInstallations.removeAll()
        currentInstallation = nil
        permissionOverlayVisible = false
    }
    
    func rescanExistingApps() {
        NSLog("🔍 AppPermissionService: Re-scanning existing applications")
        clearPendingInstallations()
        checkForNewApplications(forceRescan: true)
    }
    
    private func setupFileSystemMonitoring() {
        // Monitor /Applications directory for new app installations
        let fileDescriptor = open(applicationsPath, O_EVTONLY)
        guard fileDescriptor != -1 else {
            NSLog("🔍 AppPermissionService: Failed to open /Applications directory")
            return
        }
        
        fileSystemWatcher = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .delete, .rename],
            queue: DispatchQueue.global(qos: .background)
        )
        
        fileSystemWatcher?.setEventHandler { [weak self] in
            self?.handleFileSystemEvent()
        }
        
        fileSystemWatcher?.setCancelHandler {
            close(fileDescriptor)
        }
        
        fileSystemWatcher?.resume()
        NSLog("🔍 AppPermissionService: File system monitoring started for \(applicationsPath)")
    }
    
    private func handleFileSystemEvent() {
        // Small delay to ensure file operations are complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.checkForNewApplications(forceRescan: false)
        }
    }
    
    private func checkForNewApplications(forceRescan: Bool = false) {
        let fileManager = FileManager.default
        
        do {
            let applications = try fileManager.contentsOfDirectory(atPath: applicationsPath)
            let userApplications = try? fileManager.contentsOfDirectory(atPath: userApplicationsPath)
            let allApplications = applications + (userApplications ?? [])
            
            for appName in allApplications {
                guard appName.hasSuffix(".app") else { continue }
                
                let appPath = applicationsPath + "/" + appName
                let appURL = URL(fileURLWithPath: appPath)
                
                // Check if this is a new installation or force rescan
                if let installation = createAppInstallation(from: appURL, appName: appName) {
                    // Check if we've already processed this app (unless force rescan)
                    let alreadyProcessed = pendingInstallations.contains(where: { $0.bundleIdentifier == installation.bundleIdentifier })
                    
                    if forceRescan || !alreadyProcessed {
                        if forceRescan {
                            NSLog("🔍 AppPermissionService: Force rescan - re-processing app: \(appName)")
                            processAppInBackground(installation)
                        } else {
                            NSLog("🔍 AppPermissionService: New app detected: \(appName)")
                            processNewInstallation(installation)
                        }
                    }
                }
            }
        } catch {
            NSLog("🔍 AppPermissionService: Error reading applications directory: \(error)")
        }
    }
    
    private func createAppInstallation(from appURL: URL, appName: String) -> AppInstallation? {
        let infoPlistURL = appURL.appendingPathComponent("Contents/Info.plist")
        
        NSLog("🔍 AppPermissionService: Analyzing app: \(appName)")
        NSLog("🔍 AppPermissionService: App path: \(appURL.path)")
        
        guard FileManager.default.fileExists(atPath: infoPlistURL.path) else { 
            NSLog("❌ AppPermissionService: Info.plist not found for \(appName)")
            return nil 
        }
        
        do {
            let infoPlistData = try Data(contentsOf: infoPlistURL)
            let infoPlist = try PropertyListSerialization.propertyList(from: infoPlistData, format: nil) as? [String: Any]
            
            let bundleIdentifier = infoPlist?["CFBundleIdentifier"] as? String ?? "unknown"
            let version = infoPlist?["CFBundleShortVersionString"] as? String ?? "1.0"
            
            // For Electron apps, try to get a better app name
            var displayName = infoPlist?["CFBundleDisplayName"] as? String ?? infoPlist?["CFBundleName"] as? String ?? appName.replacingOccurrences(of: ".app", with: "")
            
            // Check if this is an Electron app with generic bundle ID
            if bundleIdentifier.hasPrefix("com.todesktop.") || bundleIdentifier.hasPrefix("com.electron.") {
                // Try to get the actual app name from the app bundle name
                let cleanAppName = appName.replacingOccurrences(of: ".app", with: "")
                if !cleanAppName.isEmpty && cleanAppName != "Electron" {
                    displayName = cleanAppName
                    NSLog("🔍 AppPermissionService: Detected Electron app, using bundle name: \(displayName)")
                }
            }
            
            NSLog("🔍 AppPermissionService: Bundle ID: \(bundleIdentifier)")
            NSLog("🔍 AppPermissionService: Display Name: \(displayName)")
            NSLog("🔍 AppPermissionService: Version: \(version)")
            
            // Get app icon
            var appIcon: Data?
            if let iconFileName = infoPlist?["CFBundleIconFile"] as? String {
                let iconURL = appURL.appendingPathComponent("Contents/Resources/\(iconFileName)")
                appIcon = try? Data(contentsOf: iconURL)
            }
            
            // Analyze Info.plist for requested permissions
            let requestedPermissions = analyzeInfoPlistForPermissions(infoPlist)
            
            let installation = AppInstallation(
                bundleIdentifier: bundleIdentifier,
                appName: displayName,
                version: version,
                appIcon: appIcon,
                requestedPermissions: requestedPermissions
            )
            
            NSLog("✅ AppPermissionService: Created installation for \(displayName) (\(bundleIdentifier))")
            return installation
            
        } catch {
            NSLog("❌ AppPermissionService: Error reading Info.plist for \(appName): \(error)")
            return nil
        }
    }
    
    private func analyzeInfoPlistForPermissions(_ infoPlist: [String: Any]?) -> [AppPermission] {
        guard let infoPlist = infoPlist else { return [] }
        
        var permissions: [AppPermission] = []
        
        // Check for camera usage
        if let cameraUsage = infoPlist["NSCameraUsageDescription"] as? String, !cameraUsage.isEmpty {
            permissions.append(AppPermission(permissionType: .camera, description: cameraUsage))
        }
        
        // Check for microphone usage
        if let micUsage = infoPlist["NSMicrophoneUsageDescription"] as? String, !micUsage.isEmpty {
            permissions.append(AppPermission(permissionType: .microphone, description: micUsage))
        }
        
        // Check for location usage
        if let locationUsage = infoPlist["NSLocationUsageDescription"] as? String, !locationUsage.isEmpty {
            permissions.append(AppPermission(permissionType: .location, description: locationUsage))
        }
        
        // Check for contacts usage
        if let contactsUsage = infoPlist["NSContactsUsageDescription"] as? String, !contactsUsage.isEmpty {
            permissions.append(AppPermission(permissionType: .contacts, description: contactsUsage))
        }
        
        // Check for photo library usage
        if let photosUsage = infoPlist["NSPhotoLibraryUsageDescription"] as? String, !photosUsage.isEmpty {
            permissions.append(AppPermission(permissionType: .photos, description: photosUsage))
        }
        
        // Check for calendar usage
        if let calendarUsage = infoPlist["NSCalendarsUsageDescription"] as? String, !calendarUsage.isEmpty {
            permissions.append(AppPermission(permissionType: .calendar, description: calendarUsage))
        }
        
        // Check for reminders usage
        if let remindersUsage = infoPlist["NSRemindersUsageDescription"] as? String, !remindersUsage.isEmpty {
            permissions.append(AppPermission(permissionType: .reminders, description: remindersUsage))
        }
        
        // Check for file access
        if let fileUsage = infoPlist["NSDocumentsFolderUsageDescription"] as? String, !fileUsage.isEmpty {
            permissions.append(AppPermission(permissionType: .files, description: fileUsage))
        }
        
        // Network access is typically implied for most apps
        permissions.append(AppPermission(permissionType: .network, description: "Network access for app functionality"))
        
        return permissions
    }
    
    // MARK: - Installation Processing
    
    private func processNewInstallation(_ installation: AppInstallation) {
        NSLog("🔍 AppPermissionService: Processing installation: \(installation.appName)")
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.pendingInstallations.append(installation)
            
            // Only show overlay for truly new installations (not during automatic scanning)
            if strongSelf.pendingInstallations.count == 1 {
                strongSelf.currentInstallation = installation
                strongSelf.permissionOverlayVisible = true
            }
        }
        
        // Fetch metadata asynchronously
        Task {
            await fetchAppMetadata(for: installation)
        }
    }
    
    private func processAppInBackground(_ installation: AppInstallation) {
        NSLog("🔍 AppPermissionService: Processing app in background: \(installation.appName)")
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.pendingInstallations.append(installation)
        }
        
        // Fetch metadata asynchronously without showing overlay
        Task {
            await fetchAppMetadata(for: installation)
        }
    }
    
    // MARK: - Metadata Fetching
    
    private func fetchAppMetadata(for installation: AppInstallation) async {
        NSLog("🔍 AppPermissionService: Fetching real metadata for \(installation.appName)")
        
        // Check if Perplexity is configured
        if PerplexityConfig.shared.isConfigured {
            NSLog("✅ Perplexity API: CONFIGURED and ready to use")
        } else {
            NSLog("❌ Perplexity API: NOT CONFIGURED - using fallback analysis")
        }
        
        // Step 1: Get app info from Perplexity
        var appInfo: (name: String, developer: String, privacyPolicyURL: String?)?
        
        // Check if this is a generic Electron bundle ID
        let isGenericBundle = installation.bundleIdentifier.hasPrefix("com.todesktop.") || installation.bundleIdentifier.hasPrefix("com.electron.")
        
        if isGenericBundle {
            NSLog("🔍 AppPermissionService: Detected generic bundle ID, trying to get info by app name")
            appInfo = await perplexityService.getAppStoreInfoByName(installation.appName)
        } else {
            appInfo = await perplexityService.getAppStoreInfo(for: installation.bundleIdentifier)
        }
        
        if let appInfo = appInfo {
            NSLog("✅ Perplexity API: Successfully found app info")
            NSLog("🔍 AppPermissionService: Found app info - \(appInfo.name) by \(appInfo.developer)")
            
            // Step 2: Find privacy policy URL if not already provided
            var privacyPolicyURL = installation.privacyPolicyURL ?? appInfo.privacyPolicyURL
            if privacyPolicyURL == nil, let foundURL = await perplexityService.findPrivacyPolicyURL(
                for: appInfo.name, 
                bundleIdentifier: installation.bundleIdentifier
            ) {
                privacyPolicyURL = foundURL
                NSLog("✅ Perplexity API: Successfully found privacy policy URL")
                NSLog("🔍 AppPermissionService: Found privacy policy URL: \(foundURL)")
            } else {
                NSLog("❌ Perplexity API: Could not find privacy policy URL")
            }
            
            // Step 3: Analyze privacy policy if URL is available
            var privacyAnalysis: PrivacyPolicyAnalysis?
            if let policyURL = privacyPolicyURL {
                NSLog("🔍 AppPermissionService: Analyzing privacy policy...")
                privacyAnalysis = await privacyAnalyzer.analyzePrivacyPolicy(url: policyURL)
                
                // Log privacy policy analysis results
                if let analysis = privacyAnalysis {
                    NSLog("✅ Privacy Policy Analysis: SUCCESS")
                    NSLog("📄 Privacy Policy Analysis Results:")
                    NSLog("   - Overall Score: \(analysis.overallScore)/100")
                    NSLog("   - Data Collection: \(analysis.dataCollection.dataTypes.joined(separator: ", "))")
                    NSLog("   - Third Party Sharing: \(analysis.thirdPartySharing.sharesWithThirdParties ? "Yes" : "No")")
                } else {
                    NSLog("❌ Privacy Policy Analysis: FAILED")
                }
            }
            
            // Step 4: Get additional privacy insights from Perplexity
            let permissionsList = installation.requestedPermissions.map { $0.permissionType.rawValue }
            NSLog("🤖 Perplexity API: Generating AI privacy insights...")
            let privacyInsights = await perplexityService.analyzeAppPrivacy(
                for: appInfo.name,
                bundleIdentifier: installation.bundleIdentifier,
                permissions: permissionsList
            )
            
            if let insights = privacyInsights {
                NSLog("✅ Perplexity API: Successfully generated privacy insights")
                NSLog("🧠 AI Privacy Insights Preview: \(insights.prefix(150))...")
            } else {
                NSLog("❌ Perplexity API: Failed to generate privacy insights")
            }
            
            // Step 5: Update the installation with real metadata
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                
                if let index = strongSelf.pendingInstallations.firstIndex(where: { $0.id == installation.id }) {
                    // Create updated installation with real metadata
                    let updatedInstallation = AppInstallation(
                        bundleIdentifier: installation.bundleIdentifier,
                        appName: appInfo.name,
                        version: installation.version,
                        appIcon: installation.appIcon,
                        requestedPermissions: installation.requestedPermissions,
                        termsAndConditionsURL: installation.termsAndConditionsURL,
                        privacyPolicyURL: privacyPolicyURL
                    )
                    
                    strongSelf.pendingInstallations[index] = updatedInstallation
                    
                    NSLog("🔍 AppPermissionService: Updated installation with real metadata")
                    NSLog("   - App: \(appInfo.name)")
                    NSLog("   - Developer: \(appInfo.developer)")
                    NSLog("   - Privacy Policy: \(privacyPolicyURL ?? "Not found")")
                    NSLog("   - Privacy Analysis: \(privacyAnalysis?.overallScore ?? 0)/100")
                    NSLog("   - Privacy Insights: \(privacyInsights?.prefix(100) ?? "None")")
                }
            }
        } else {
            NSLog("❌ Perplexity API: Could not find app info for \(installation.bundleIdentifier)")
        }
    }
    
    // MARK: - Permission Decisions
    
    func makePermissionDecision(_ installation: AppInstallation, decision: PermissionDecision) {
        NSLog("🔍 AppPermissionService: User decision for \(installation.appName): \(decision.rawValue)")
        
        // Remove from pending installations
        pendingInstallations.removeAll { $0.id == installation.id }
        
        // Hide overlay
        if currentInstallation?.id == installation.id {
            currentInstallation = nil
            permissionOverlayVisible = false
        }
        
        // In a real implementation, we would:
        // 1. Apply the permission settings to the system
        // 2. Log the decision for analytics
        // 3. Update user preferences
        
        // For now, just log the decision
        logPermissionDecision(installation, decision: decision)
    }
    
    private func logPermissionDecision(_ installation: AppInstallation, decision: PermissionDecision) {
        let logEntry = """
        Permission Decision Log:
        App: \(installation.appName)
        Bundle ID: \(installation.bundleIdentifier)
        Decision: \(decision.rawValue)
        Timestamp: \(Date())
        Permissions: \(installation.requestedPermissions.map { $0.permissionType.rawValue }.joined(separator: ", "))
        """
        
        NSLog("📝 Permission Decision: \(logEntry)")
        
        // In a real implementation, this would be saved to a local database
        // or sent to a secure analytics service
    }
    
    // MARK: - Privacy Policy Analysis
    
    func analyzePrivacyPolicy(url: String) async -> PrivacyPolicyAnalysis? {
        return await privacyAnalyzer.analyzePrivacyPolicy(url: url)
    }
    
    // MARK: - Perplexity Service Access
    
    func getPerplexityService() -> PerplexityService {
        return perplexityService
    }
}
