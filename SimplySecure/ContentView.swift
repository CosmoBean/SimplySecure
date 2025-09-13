import SwiftUI

struct ContentView: View {
    @StateObject private var securityScanner = SecurityScanner()
    @StateObject private var gameModel = NinjaGameModel()
    @State private var selectedTab: Tab = .dashboard
    @State private var testCounter = 0
    
    enum Tab: String, CaseIterable {
        case dashboard = "Dashboard"
        case account = "Account"
        case reports = "Reports"
        case terminal = "Terminal Test"
    }
    
    var body: some View {
        NavigationSplitView {
            // MARK: - Sidebar
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "shield.checkered")
                        .font(.title2)
                        .foregroundColor(.red)
                    Text("SimplySecure")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding()
                
                Divider()
                
                // Navigation
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Button(action: {
                            selectedTab = tab
                        }) {
                            HStack {
                                Image(systemName: tabIcon(for: tab))
                                    .foregroundColor(selectedTab == tab ? .white : .primary)
                                Text(tab.rawValue)
                                    .foregroundColor(selectedTab == tab ? .white : .primary)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedTab == tab ? Color.red : Color.clear)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                Spacer()
                
                // Quick Stats
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Stats")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Security Score")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(securityScanner.totalScore)/100")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(securityScoreColor)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Level")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(gameModel.currentLevel.rawValue)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(gameModel.currentLevel.color)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .frame(minWidth: 200)
            .background(Color(NSColor.controlBackgroundColor))
            
        } detail: {
            // MARK: - Main Content
            Group {
                switch selectedTab {
                case .dashboard:
                    DashboardView(securityScanner: securityScanner, gameModel: gameModel, testCounter: $testCounter)
                case .account:
                    AccountView(gameModel: gameModel)
                case .reports:
                    ReportsView(securityScanner: securityScanner)
                case .terminal:
                    TerminalTestView()
                }
            }
            .frame(minWidth: 600, minHeight: 500)
        }
    }
    
    private func tabIcon(for tab: Tab) -> String {
        switch tab {
        case .dashboard: return "house.fill"
        case .account: return "person.circle.fill"
        case .reports: return "chart.bar.fill"
        case .terminal: return "terminal.fill"
        }
    }
    
    private var securityScoreColor: Color {
        switch securityScanner.totalScore {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    @ObservedObject var securityScanner: SecurityScanner
    @ObservedObject var gameModel: NinjaGameModel
    @Binding var testCounter: Int
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with Ninja Avatar and Level
                headerView
                
                // Security Score Progress Bar
                scoreProgressView
                
                // Mission List
                missionListView
                
                // Scan Button
                scanButtonView
            }
            .padding()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            // Ninja Avatar
            Image(systemName: "person.fill")
                .font(.system(size: 60))
                .foregroundColor(gameModel.currentLevel.color)
                .background(
                    Circle()
                        .fill(Color(NSColor.controlBackgroundColor))
                        .frame(width: 80, height: 80)
                )
            
            VStack(alignment: .leading, spacing: 8) {
                Text(gameModel.currentLevel.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(gameModel.currentLevel.color)
                
                Text("\(gameModel.currentXP) XP")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Test: \(testCounter)")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    // MARK: - Score Progress View
    private var scoreProgressView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Security Score")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(securityScanner.totalScore)/100")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(securityScoreColor)
            }
            
            ProgressView(value: Double(securityScanner.totalScore), total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: securityScoreColor))
                .frame(height: 8)
            
            Text(securityScoreMessage)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    // MARK: - Mission List View
    private var missionListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Security Missions")
                .font(.headline)
                .fontWeight(.semibold)
            
            if securityScanner.isScanning {
                VStack(spacing: 12) {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text(securityScanner.currentScanStep)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    ProgressView(value: securityScanner.scanProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .frame(height: 8)
                    if !securityScanner.scanResults.isEmpty {
                        Text("Completed Scans:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        LazyVStack(spacing: 4) {
                            ForEach(securityScanner.scanResults, id: \.name) { result in
                                HStack {
                                    Image(systemName: result.passed ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                        .foregroundColor(result.passed ? .green : .orange)
                                        .font(.caption)
                                    Text(result.name)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(result.passed ? "✓" : "✗")
                                        .font(.caption)
                                        .foregroundColor(result.passed ? .green : .red)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(NSColor.controlBackgroundColor))
                                )
                            }
                        }
                        .frame(maxHeight: 100)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            } else if securityScanner.isFixing {
                VStack(spacing: 12) {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.orange)
                        Text(securityScanner.currentFixStep)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    ProgressView(value: securityScanner.fixProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                        .frame(height: 8)
                    Text("Fixing security issues...")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            } else if !securityScanner.scanResults.isEmpty {
                LazyVStack(spacing: 8) {
                    ForEach(securityScanner.scanResults, id: \.name) { result in
                        missionRowView(result: result)
                    }
                }
            } else {
                Text("No scans performed yet. Click 'Run Security Scan' to start!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    // MARK: - Mission Row View
    private func missionRowView(result: SecurityScanResult) -> some View {
        HStack {
            Image(systemName: result.passed ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(result.passed ? .green : .orange)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(result.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(result.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(result.passed ? "✓ PASSED" : "✗ FAILED")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(result.passed ? .green : .red)
                
                if !result.passed {
                    Button("Fix Now") {
                        print("🔧 ContentView: Fix Now clicked for \(result.name)")
                        securityScanner.fixSecurityIssue(result)
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(securityScanner.isFixing ? Color.gray : Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .disabled(securityScanner.isFixing)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    // MARK: - Scan Button View
    private var scanButtonView: some View {
        Button(action: {
            print("🥷 ContentView: Scan button clicked!")
            print("🥷 ContentView: Current isScanning: \(securityScanner.isScanning)")
            print("🥷 ContentView: Test counter before: \(testCounter)")
            testCounter += 1
            print("🥷 ContentView: Test counter after: \(testCounter)")
            print("🥷 ContentView: About to call performSecurityScan()")
            securityScanner.performSecurityScan()
            print("🥷 ContentView: performSecurityScan() called")
        }) {
            HStack {
                if securityScanner.isScanning {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "shield.checkered")
                }
                Text(securityScanner.isScanning ? "Scanning..." : securityScanner.isFixing ? "Fixing Issues..." : "Run Security Scan")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(securityScanner.isScanning ? Color.orange : Color.red)
                    .animation(.easeInOut(duration: 0.3), value: securityScanner.isScanning)
            )
        }
        .disabled(securityScanner.isScanning || securityScanner.isFixing)
        .scaleEffect((securityScanner.isScanning || securityScanner.isFixing) ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: securityScanner.isScanning)
        .animation(.easeInOut(duration: 0.2), value: securityScanner.isFixing)
    }
    
    // MARK: - Computed Properties
    private var securityScoreColor: Color {
        switch securityScanner.totalScore {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }
    
    private var securityScoreMessage: String {
        switch securityScanner.totalScore {
        case 80...100: return "Excellent security posture! 🥷"
        case 60..<80: return "Good security, but room for improvement"
        case 40..<60: return "Security needs attention"
        default: return "Critical security issues detected!"
        }
    }
}

// MARK: - Account View
struct AccountView: View {
    @ObservedObject var gameModel: NinjaGameModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Profile Header
                profileHeader
                
                // Level Progress
                levelProgressView
                
                // Achievements
                achievementsView
                
                // Stats
                statsView
            }
            .padding()
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 20) {
            // Large Avatar
            Image(systemName: "person.fill")
                .font(.system(size: 120))
                .foregroundColor(gameModel.currentLevel.color)
                .background(
                    Circle()
                        .fill(Color(NSColor.controlBackgroundColor))
                        .frame(width: 140, height: 140)
                )
            
            VStack(spacing: 8) {
                Text(gameModel.currentLevel.rawValue)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(gameModel.currentLevel.color)
                
                Text("\(gameModel.currentXP) XP")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private var levelProgressView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Level Progress")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Current Level: \(gameModel.currentLevel.rawValue)")
                        .font(.subheadline)
                    Spacer()
                    Text("\(gameModel.currentXP) XP")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                ProgressView(value: gameModel.progressToNextLevel)
                    .progressViewStyle(LinearProgressViewStyle(tint: gameModel.currentLevel.color))
                    .frame(height: 8)
                
                Text("Next Level: \(gameModel.currentLevel.nextLevelXP) XP")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private var achievementsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ForEach(NinjaLevel.allCases, id: \.self) { level in
                    VStack(spacing: 8) {
                        Image(systemName: level == gameModel.currentLevel ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundColor(level == gameModel.currentLevel ? .yellow : .gray)
                        
                        Text(level.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        
                        Text("\(level.xpThreshold)+ XP")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(level == gameModel.currentLevel ? Color.yellow.opacity(0.1) : Color(NSColor.controlBackgroundColor))
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private var statsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Total XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(gameModel.currentXP)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Current Level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(gameModel.currentLevel.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(gameModel.currentLevel.color)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
}

// MARK: - Reports View
struct ReportsView: View {
    @ObservedObject var securityScanner: SecurityScanner
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Report Header
                reportHeader
                
                // Detailed Results
                detailedResultsView
                
                // Recommendations
                recommendationsView
            }
            .padding()
        }
    }
    
    private var reportHeader: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                Text("Security Report")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            HStack {
                VStack {
                    Text("Overall Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(securityScanner.totalScore)/100")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(overallScoreColor)
                }
                
                Spacer()
                
                VStack {
                    Text("Issues Found")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(securityScanner.scanResults.filter { !$0.passed }.count)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                VStack {
                    Text("Fixed Issues")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(securityScanner.scanResults.filter { $0.passed }.count)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private var detailedResultsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detailed Results")
                .font(.headline)
                .fontWeight(.semibold)
            
            if securityScanner.scanResults.isEmpty {
                Text("No scan results available. Run a security scan to see detailed results.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(securityScanner.scanResults, id: \.name) { result in
                    detailedResultRow(result: result)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private func detailedResultRow(result: SecurityScanResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: result.passed ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundColor(result.passed ? .green : .orange)
                
                VStack(alignment: .leading) {
                    Text(result.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(result.message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(result.passed ? "PASSED" : "FAILED")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(result.passed ? .green : .red)
                    
                    Text("\(result.points) points")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !result.passed {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recommendation:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                    
                    Text(result.fixInstructions)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 8)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity(0.1))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private var recommendationsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Security Recommendations")
                .font(.headline)
                .fontWeight(.semibold)
            
            let failedResults = securityScanner.scanResults.filter { !$0.passed }
            
            if failedResults.isEmpty {
                Text("🎉 Excellent! All security checks have passed. Your system is secure!")
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green.opacity(0.1))
                    )
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Priority Actions:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    
                    ForEach(failedResults, id: \.name) { result in
                        HStack {
                            Text("•")
                                .foregroundColor(.red)
                            Text(result.name)
                                .font(.subheadline)
                            Spacer()
                            Text("\(result.points) points")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red.opacity(0.1))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private var overallScoreColor: Color {
        switch securityScanner.totalScore {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }
}

// MARK: - Terminal Test View
struct TerminalTestView: View {
    @State private var commandOutput = ""
    @State private var isRunning = false
    @State private var selectedCommand: TerminalCommand = .say
    @State private var customCommand = ""
    @State private var customArguments = ""
    
    enum TerminalCommand: String, CaseIterable {
        case say = "Say Hello"
        case whoami = "Who Am I"
        case uptime = "System Uptime"
        case diskUsage = "Disk Usage"
        case networkInfo = "Network Info"
        case custom = "Custom Command"
        
        var executablePath: String {
            switch self {
            case .say: return "/usr/bin/say"
            case .whoami: return "/usr/bin/whoami"
            case .uptime: return "/usr/bin/uptime"
            case .diskUsage: return "/bin/df"
            case .networkInfo: return "/usr/sbin/networksetup"
            case .custom: return "/bin/zsh"
            }
        }
        
        var arguments: [String] {
            switch self {
            case .say: return ["Hello from SimplySecure!"]
            case .whoami: return []
            case .uptime: return []
            case .diskUsage: return ["-h"]
            case .networkInfo: return ["-listallhardwareports"]
            case .custom: return ["-c", ""]
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerView
                
                // Command Selection
                commandSelectionView
                
                // Custom Command Input
                if selectedCommand == .custom {
                    customCommandView
                }
                
                // Execute Button
                executeButtonView
                
                // Output Display
                outputView
                
                // Examples
                examplesView
            }
            .padding()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "terminal.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                Text("Terminal Access Test")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            Text("Test terminal command execution with proper permissions")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private var commandSelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Command")
                .font(.headline)
                .fontWeight(.semibold)
            
            Picker("Command", selection: $selectedCommand) {
                ForEach(TerminalCommand.allCases, id: \.self) { command in
                    Text(command.rawValue).tag(command)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if selectedCommand != .custom {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Command Details:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Text("Path:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(selectedCommand.executablePath)
                            .font(.system(.caption, design: .monospaced))
                    }
                    
                    if !selectedCommand.arguments.isEmpty {
                        HStack {
                            Text("Args:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(selectedCommand.arguments.joined(separator: " "))
                                .font(.system(.caption, design: .monospaced))
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.controlBackgroundColor))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private var customCommandView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Custom Command")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Command:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                TextField("e.g., echo 'Hello World'", text: $customCommand)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(.body, design: .monospaced))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Arguments (optional):")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                TextField("e.g., -l, --verbose", text: $customArguments)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(.body, design: .monospaced))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private var executeButtonView: some View {
        Button(action: executeCommand) {
            HStack {
                if isRunning {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "play.fill")
                }
                Text(isRunning ? "Running..." : "Execute Command")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isRunning ? Color.orange : Color.blue)
            )
        }
        .disabled(isRunning)
    }
    
    private var outputView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Command Output")
                .font(.headline)
                .fontWeight(.semibold)
            
            ScrollView {
                Text(commandOutput.isEmpty ? "No output yet. Run a command to see results." : commandOutput)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.05))
                    )
            }
            .frame(minHeight: 200, maxHeight: 300)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private var examplesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Example Commands")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                exampleRow("Say Hello", "Uses /usr/bin/say to speak text")
                exampleRow("Who Am I", "Shows current user with /usr/bin/whoami")
                exampleRow("System Uptime", "Displays system uptime")
                exampleRow("Disk Usage", "Shows disk space usage")
                exampleRow("Network Info", "Lists network hardware ports")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private func exampleRow(_ title: String, _ description: String) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func executeCommand() {
        isRunning = true
        commandOutput = ""
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let executableURL = URL(fileURLWithPath: selectedCommand.executablePath)
                var arguments = selectedCommand.arguments
                
                if selectedCommand == .custom {
                    if !customArguments.isEmpty {
                        arguments = ["-c", "\(customCommand) \(customArguments)"]
                    } else {
                        arguments = ["-c", customCommand]
                    }
                }
                
                let task = Process()
                task.executableURL = executableURL
                task.arguments = arguments
                
                let pipe = Pipe()
                task.standardOutput = pipe
                task.standardError = pipe
                
                try task.run()
                task.waitUntilExit()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? "No output"
                
                DispatchQueue.main.async {
                    self.commandOutput = """
                    Command: \(executableURL.path)
                    Arguments: \(arguments.joined(separator: " "))
                    Exit Code: \(task.terminationStatus)
                    
                    Output:
                    \(output)
                    """
                    self.isRunning = false
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.commandOutput = "Error: \(error.localizedDescription)"
                    self.isRunning = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}