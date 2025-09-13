import SwiftUI

// MARK: - Security Tasks View
struct SecurityTasksView: View {
    @StateObject private var taskService = SecurityTaskService()
    @StateObject private var executionService = TaskExecutionService()
    @ObservedObject var gameModel: NinjaGameModel
    @State private var selectedDay: Int = 1
    @State private var showingTaskDetail = false
    @State private var selectedTask: SecurityTask?
    @State private var showingAchievements = false
    
    var body: some View {
        NavigationSplitView {
            sidebarView
        } detail: {
            mainContentView
        }
        .onAppear {
            taskService.setGameModel(gameModel)
            executionService.setGameModel(gameModel)
        }
    }
    
    private var sidebarView: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            Divider()
            daySelectionSection
            Divider()
            quickStatsSection
            Spacer()
            achievementsButton
        }
        .frame(minWidth: 250)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "shield.checkered")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("Security Tasks")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text("Learn macOS security through hands-on tasks")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var daySelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Challenges")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            ForEach(taskService.dailyChallenges, id: \.day) { challenge in
                dayButton(challenge: challenge)
            }
        }
        .padding(.vertical)
    }
    
    private func dayButton(challenge: DailyChallengeSet) -> some View {
        let progress = taskService.getDayProgress(day: challenge.day)
        let isSelected = selectedDay == challenge.day
        let isCompleted = progress.completed == progress.total
        
        return Button(action: {
            selectedDay = challenge.day
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Day \(challenge.day)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text(challenge.completionBadge)
                            .font(.title3)
                    }
                    
                    Text(challenge.title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("\(progress.completed)/\(progress.total) tasks")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress Overview")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                statRow("Total Tasks", "\(taskService.getCompletedTasksCount())/15")
                statRow("Current Day", "Day \(selectedDay)")
                statRow("XP Earned", "\(gameModel.currentXP)")
                statRow("Level", gameModel.currentLevel.rawValue)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
    
    private var achievementsButton: some View {
        Button(action: {
            showingAchievements = true
        }) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
                Text("Achievements")
                    .fontWeight(.semibold)
                Spacer()
                Text("\(taskService.achievements.filter { $0.isUnlocked }.count)/\(taskService.achievements.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var mainContentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Challenge Header
                challengeHeaderView
                
                // Tasks List
                tasksListView
            }
            .padding()
        }
        .sheet(isPresented: $showingTaskDetail) {
            if let task = selectedTask {
                TaskDetailView(task: task, taskService: taskService, executionService: executionService)
            }
        }
        .sheet(isPresented: $showingAchievements) {
            AchievementsView(achievements: taskService.achievements)
        }
    }
    
    private var challengeHeaderView: some View {
        let challenge = taskService.dailyChallenges.first { $0.day == selectedDay }
        let progress = taskService.getDayProgress(day: selectedDay)
        
        return VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Day \(selectedDay)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text(challenge?.title ?? "Challenge")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(challenge?.description ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text(challenge?.completionBadge ?? "🎯")
                        .font(.largeTitle)
                    
                    Text("\(progress.completed)/\(progress.total)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(progress.completed == progress.total ? .green : .blue)
                }
            }
            
            // Progress Bar
            ProgressView(value: Double(progress.completed), total: Double(progress.total))
                .progressViewStyle(LinearProgressViewStyle(tint: progress.completed == progress.total ? .green : .blue))
                .frame(height: 8)
            
            // Challenge Stats
            HStack(spacing: 20) {
                VStack {
                    Text("\(challenge?.totalXP ?? 0)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("Total XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(challenge?.estimatedTimeMinutes ?? 0)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    Text("Minutes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text(challenge?.theme ?? "Security")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Theme")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private var tasksListView: some View {
        let challenge = taskService.dailyChallenges.first { $0.day == selectedDay }
        let tasks = challenge?.tasks ?? []
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Tasks")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 12) {
                ForEach(tasks, id: \.id) { task in
                    taskRowView(task: task)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private func taskRowView(task: SecurityTask) -> some View {
        let progress = taskService.getTaskProgress(for: task.id)
        let status = progress?.status ?? .notStarted
        
        return Button(action: {
            selectedTask = task
            showingTaskDetail = true
        }) {
            HStack(spacing: 16) {
                // Status Icon
                Image(systemName: status.icon)
                    .font(.title2)
                    .foregroundColor(Color(status.color))
                    .frame(width: 30)
                
                // Task Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(task.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        // Category Badge
                        HStack(spacing: 4) {
                            Image(systemName: task.category.icon)
                                .font(.caption)
                            Text(task.category.rawValue)
                                .font(.caption)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(task.category.color).opacity(0.2))
                        )
                        .foregroundColor(Color(task.category.color))
                        
                        // Difficulty Badge
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                            Text(task.difficulty.rawValue)
                                .font(.caption)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(task.difficulty.color).opacity(0.2))
                        )
                        .foregroundColor(Color(task.difficulty.color))
                        
                        Spacer()
                        
                        // XP Reward
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text("\(task.xpReward) XP")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Spacer()
                
                // Status and Action
                VStack(alignment: .trailing, spacing: 8) {
                    Text(status.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(status.color))
                    
                    if status == .notStarted {
                        VStack(spacing: 4) {
                            Button("Execute") {
                                Task {
                                    let result = await executionService.executeTask(task)
                                    if result.success {
                                        taskService.startTask(task)
                                    }
                                }
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(executionService.isExecuting ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                            .disabled(executionService.isExecuting)
                            
                            if executionService.isExecuting {
                                ProgressView()
                                    .scaleEffect(0.6)
                            }
                        }
                    } else if status == .completed {
                        Button("Verify") {
                            taskService.verifyTask(task)
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(status.color).opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Task Detail View
struct TaskDetailView: View {
    let task: SecurityTask
    @ObservedObject var taskService: SecurityTaskService
    @ObservedObject var executionService: TaskExecutionService
    @Environment(\.dismiss) private var dismiss
    @State private var notes: String = ""
    @State private var showingVerification = false
    @State private var executionResult: TaskExecutionResult?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Task Header
                    taskHeaderView
                    
                    // Instructions
                    instructionsView
                    
                    // Execution Results
                    if let result = executionResult {
                        executionResultsView(result)
                    }
                    
                    // Verification
                    if task.verificationCommand != nil {
                        verificationView
                    }
                    
                    // Notes
                    notesView
                    
                    // Actions
                    actionsView
                }
                .padding()
            }
            .navigationTitle(task.title)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var taskHeaderView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(task.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(task.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("\(task.xpReward) XP")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text("\(task.estimatedTimeMinutes) min")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 12) {
                categoryBadge
                difficultyBadge
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private var categoryBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: task.category.icon)
                .font(.caption)
            Text(task.category.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(task.category.color).opacity(0.2))
        )
        .foregroundColor(Color(task.category.color))
    }
    
    private var difficultyBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
                .font(.caption)
            Text(task.difficulty.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(task.difficulty.color).opacity(0.2))
        )
        .foregroundColor(Color(task.difficulty.color))
    }
    
    private var instructionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Instructions")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(task.detailedInstructions)
                .font(.body)
                .lineSpacing(4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private var verificationView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Verification")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let command = task.verificationCommand {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Run this command to verify:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(command)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.05))
                        )
                    
                    if let description = task.verificationDescription {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private var notesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)
                .fontWeight(.semibold)
            
            TextEditor(text: $notes)
                .font(.body)
                .frame(minHeight: 100)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.05))
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private func executionResultsView(_ result: TaskExecutionResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Execution Results")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                Image(systemName: result.success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(result.success ? .green : .orange)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.success ? "Task Executed Successfully" : "Task Execution Completed")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(result.success ? .green : .orange)
                    
                    Text("Exit Code: \(result.exitCode)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            if !result.output.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Output:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ScrollView {
                        Text(result.output)
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.05))
                            )
                    }
                    .frame(maxHeight: 200)
                }
            }
            
            if !result.error.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Additional Info:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                    
                    Text(result.error)
                        .font(.body)
                        .foregroundColor(.orange)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange.opacity(0.1))
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
    
    private var actionsView: some View {
        let progress = taskService.getTaskProgress(for: task.id)
        let status = progress?.status ?? .notStarted
        
        return VStack(spacing: 12) {
            if status == .notStarted {
                VStack(spacing: 8) {
                    Button("Execute Task") {
                        Task {
                            executionResult = await executionService.executeTask(task)
                        }
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(executionService.isExecuting ? Color.gray : Color.blue)
                    .cornerRadius(12)
                    .disabled(executionService.isExecuting)
                    
                    if executionService.isExecuting {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Executing: \(executionService.currentCommand)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } else if status == .inProgress {
                VStack(spacing: 8) {
                    Button("Execute Task Again") {
                        Task {
                            executionResult = await executionService.executeTask(task)
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(executionService.isExecuting ? Color.gray : Color.blue)
                    .cornerRadius(8)
                    .disabled(executionService.isExecuting)
                    
                    Button("Mark as Completed") {
                        taskService.completeTask(task, notes: notes)
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(12)
                }
            } else if status == .completed {
                Button("Verify Task") {
                    taskService.verifyTask(task)
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange)
                .cornerRadius(12)
            } else if status == .verified {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Task Verified!")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Achievements View
struct AchievementsView: View {
    let achievements: [SecurityAchievement]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(achievements, id: \.id) { achievement in
                        achievementCard(achievement)
                    }
                }
                .padding()
            }
            .navigationTitle("Achievements")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func achievementCard(_ achievement: SecurityAchievement) -> some View {
        VStack(spacing: 12) {
            Image(systemName: achievement.icon)
                .font(.system(size: 40))
                .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
            
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(achievement.requirement)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                if achievement.isUnlocked {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                        Text("\(achievement.xpReward) XP")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(achievement.isUnlocked ? Color.yellow.opacity(0.1) : Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(achievement.isUnlocked ? Color.yellow : Color.clear, lineWidth: 2)
                )
        )
    }
}

#Preview {
    SecurityTasksView(gameModel: NinjaGameModel())
}
