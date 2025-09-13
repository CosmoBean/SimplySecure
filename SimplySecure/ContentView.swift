import SwiftUI

struct ContentView: View {
    @StateObject private var securityScanner = SecurityScanner()
    @StateObject private var gameModel = NinjaGameModel()
    @State private var showingFixInstructions = false
    @State private var selectedMission: Mission?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header with Ninja Avatar and Level
                headerView
                
                // Security Score Progress Bar
                securityScoreView
                
                // Mission List
                missionListView
                
                // Scan Button
                scanButtonView
                
                Spacer()
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .onAppear {
                securityScanner.performSecurityScan()
            }
            .onChange(of: securityScanner.scanResults) { results in
                gameModel.updateMissions(from: results)
            }
            .sheet(isPresented: $showingFixInstructions) {
                if let mission = selectedMission {
                    FixInstructionsView(mission: mission, gameModel: gameModel)
                }
            }
        }
        .frame(minWidth: 600, minHeight: 500)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            // Ninja Avatar
            Image(systemName: "person.fill")
                .font(.system(size: 50))
                .foregroundColor(Color(gameModel.currentLevel.color))
                .background(
                    Circle()
                        .fill(Color(NSColor.controlBackgroundColor))
                        .frame(width: 80, height: 80)
                )
            
            VStack(alignment: .leading, spacing: 8) {
                Text(gameModel.currentLevel.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(gameModel.currentLevel.color))
                
                Text("Level \(gameModel.currentLevel.levelNumber)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("\(gameModel.currentXP) XP")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Level Progress
            VStack(alignment: .trailing) {
                Text("Next Level")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ProgressView(value: gameModel.getXPProgress())
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(gameModel.currentLevel.color)))
                    .frame(width: 150)
                
                Text("\(gameModel.currentLevel.nextLevelXP - gameModel.currentXP) XP to go")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    // MARK: - Security Score View
    private var securityScoreView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Security Score")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(securityScanner.totalScore)/100")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(securityScoreColor)
            }
            
            ProgressView(value: Double(securityScanner.totalScore), total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: securityScoreColor))
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            Text(securityScoreMessage)
                .font(.subheadline)
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
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Scanning system...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            } else if gameModel.missions.isEmpty {
                Text("No missions available. Run a security scan to see your tasks.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(gameModel.missions, id: \.id) { mission in
                            MissionRowView(
                                mission: mission,
                                onFixTapped: {
                                    selectedMission = mission
                                    showingFixInstructions = true
                                },
                                onCompleteTapped: {
                                    gameModel.completeMission(mission.id)
                                }
                            )
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    // MARK: - Scan Button View
    private var scanButtonView: some View {
        Button(action: {
            securityScanner.performSecurityScan()
        }) {
            HStack {
                if securityScanner.isScanning {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "shield.checkered")
                }
                
                Text(securityScanner.isScanning ? "Scanning..." : "Run Security Scan")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red)
            )
        }
        .disabled(securityScanner.isScanning)
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
        case 80...100: return "Excellent! Your system is well protected."
        case 60..<80: return "Good security, but there's room for improvement."
        case 40..<60: return "Your system needs attention."
        default: return "Critical security issues detected!"
        }
    }
}

// MARK: - Mission Row View
struct MissionRowView: View {
    let mission: Mission
    let onFixTapped: () -> Void
    let onCompleteTapped: () -> Void
    
    var body: some View {
        HStack {
            // Status Icon
            Image(systemName: mission.isCompleted ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(mission.isCompleted ? .green : .orange)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(mission.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(mission.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // XP Badge
            Text("+\(mission.xpReward) XP")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.red)
                )
            
            // Action Button
            if mission.isCompleted {
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
                    .font(.title3)
            } else {
                Button("Fix") {
                    onFixTapped()
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.blue)
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                )
        )
    }
}

// MARK: - Fix Instructions View
struct FixInstructionsView: View {
    let mission: Mission
    let gameModel: NinjaGameModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text(mission.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.blue)
            }
            
            // Instructions
            VStack(alignment: .leading, spacing: 12) {
                Text("How to Fix:")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(mission.fixInstructions)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // XP Reward
            HStack {
                Text("Reward:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("+\(mission.xpReward) XP")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
            }
            
            Spacer()
            
            // Action Buttons
            HStack {
                Button("Mark as Complete") {
                    gameModel.completeMission(mission.id)
                    dismiss()
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green)
                )
                
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                )
            }
        }
        .padding()
        .frame(width: 400, height: 300)
    }
}

#Preview {
    ContentView()
}