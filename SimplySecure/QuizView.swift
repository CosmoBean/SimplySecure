import SwiftUI

// MARK: - Quiz View
struct QuizView: View {
    @StateObject private var quizService = QuizService(apiKey: GeminiConfig.shared.apiKey)
    @ObservedObject var gameModel: NinjaGameModel
    
    @State private var selectedDifficulty: QuizDifficulty = .medium
    @State private var selectedCategory: QuizCategory = .general
    @State private var numberOfQuestions: Int = 5
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswers: [Int?] = []
    @State private var showResults = false
    @State private var quizStartTime: Date?
    @State private var showExplanation = false
    @State private var currentAnswer: Int?
    
    var body: some View {
        VStack(spacing: 0) {
            if showResults, let session = quizService.currentSession {
                resultsView(session: session)
            } else if !quizService.currentQuiz.isEmpty {
                quizGameView
            } else {
                quizSetupView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Quiz Setup View
    private var quizSetupView: some View {
        VStack(spacing: 20) {
            headerView
            difficultySelectionView
            categorySelectionView
            generateButtonView
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Text("Security Quiz")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Test your macOS security knowledge")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if !GeminiConfig.shared.isConfigured {
                Text("⚠️ API Key Required")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }
    
    private var difficultySelectionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Difficulty")
                .font(.headline)
                .fontWeight(.semibold)
            
            Picker("Difficulty", selection: $selectedDifficulty) {
                ForEach(QuizDifficulty.allCases, id: \.self) { difficulty in
                    Text(difficulty.rawValue).tag(difficulty)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(maxWidth: 300)
        }
    }
    
    private var categorySelectionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.headline)
                .fontWeight(.semibold)
            
            Picker("Category", selection: $selectedCategory) {
                ForEach(QuizCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(maxWidth: 300)
        }
    }
    
    
    private var generateButtonView: some View {
        VStack(spacing: 12) {
            Button(action: generateQuiz) {
                HStack {
                    if quizService.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "play.fill")
                    }
                    Text(quizService.isLoading ? "Generating..." : "Start Quiz")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(quizService.isLoading ? Color.gray : Color.blue)
                )
            }
            .disabled(quizService.isLoading || !GeminiConfig.shared.isConfigured)
            
            if !quizService.errorMessage.isEmpty {
                Text("Error: \(quizService.errorMessage)")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    
    // MARK: - Quiz Game View
    private var quizGameView: some View {
        VStack(spacing: 20) {
            progressHeaderView
            questionView
            optionsView
            navigationView
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var progressHeaderView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Question \(currentQuestionIndex + 1) of \(quizService.currentQuiz.count)")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(quizService.currentQuiz[currentQuestionIndex].difficulty.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
            }
            
            ProgressView(value: Double(currentQuestionIndex + 1), total: Double(quizService.currentQuiz.count))
                .progressViewStyle(LinearProgressViewStyle())
        }
    }
    
    private var questionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(quizService.currentQuiz[currentQuestionIndex].question)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
            
            if showExplanation {
                explanationView
            }
        }
    }
    
    private var optionsView: some View {
        VStack(spacing: 8) {
            ForEach(Array(quizService.currentQuiz[currentQuestionIndex].options.enumerated()), id: \.offset) { index, option in
                simpleOptionButton(index: index, option: option)
            }
        }
    }
    
    private func simpleOptionButton(index: Int, option: String) -> some View {
        Button(action: {
            selectAnswer(index)
        }) {
            HStack {
                Text(String(UnicodeScalar(65 + index)!))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(buttonColor(for: index)))
                
                Text(option)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor(for: index))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor(for: index), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(showExplanation)
    }
    
    private var explanationView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Explanation")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text(quizService.currentQuiz[currentQuestionIndex].explanation)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.yellow.opacity(0.1))
        )
    }
    
    private var navigationView: some View {
        HStack {
            if currentQuestionIndex > 0 {
                Button("Previous") {
                    previousQuestion()
                }
            }
            
            Spacer()
            
            if currentQuestionIndex == quizService.currentQuiz.count - 1 {
                Button("Finish") {
                    finishQuiz()
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .background(Color.green)
                .cornerRadius(6)
            } else {
                Button("Next") {
                    nextQuestion()
                }
                .disabled(!hasAnsweredCurrentQuestion())
            }
        }
    }
    
    // MARK: - Results View
    private func resultsView(session: QuizSession) -> some View {
        VStack(spacing: 20) {
            resultsHeaderView(session: session)
            actionButtonsView
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func resultsHeaderView(session: QuizSession) -> some View {
        VStack(spacing: 16) {
            Text(session.grade.emoji)
                .font(.system(size: 60))
            
            Text(session.grade.rawValue)
                .font(.title)
                .fontWeight(.bold)
            
            Text("\(session.percentage, specifier: "%.1f")%")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text("\(session.score)/\(session.totalPoints) points")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    
    private var actionButtonsView: some View {
        Button("Take Another Quiz") {
            resetQuiz()
        }
        .fontWeight(.semibold)
        .foregroundColor(.white)
        .padding(.horizontal, 32)
        .padding(.vertical, 12)
        .background(Color.blue)
        .cornerRadius(8)
    }
    
    // MARK: - Helper Methods
    private func generateQuiz() {
        Task {
            await quizService.generateQuiz(
                difficulty: selectedDifficulty,
                category: selectedCategory,
                numberOfQuestions: numberOfQuestions
            )
            
            if !quizService.currentQuiz.isEmpty {
                selectedAnswers = Array(repeating: nil, count: numberOfQuestions)
                currentQuestionIndex = 0
                quizStartTime = Date()
                showResults = false
                showExplanation = false
            }
        }
    }
    
    private func selectAnswer(_ index: Int) {
        if selectedAnswers.indices.contains(currentQuestionIndex) {
            selectedAnswers[currentQuestionIndex] = index
        }
        currentAnswer = index
        showExplanation = true
        
        // Award XP for answering (even if wrong, learning is valuable)
        gameModel.addXP(5)
        
        // Haptic feedback
        QuizHapticFeedback.selection()
        
        // Check if answer is correct for additional feedback
        let question = quizService.currentQuiz[currentQuestionIndex]
        if index == question.correctAnswer {
            QuizHapticFeedback.correct()
        } else {
            QuizHapticFeedback.wrong()
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < quizService.currentQuiz.count - 1 {
            currentQuestionIndex += 1
            showExplanation = false
            currentAnswer = nil
        }
    }
    
    private func previousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            showExplanation = false
            currentAnswer = nil
        }
    }
    
    private func finishQuiz() {
        guard let startTime = quizStartTime else { return }
        
        let timeSpent = Date().timeIntervalSince(startTime)
        let session = quizService.completeQuiz(answers: selectedAnswers, timeSpent: timeSpent)
        
        // Award XP based on performance
        let xpBonus = Int(session.percentage * 2) // Up to 200 XP for perfect score
        gameModel.addXP(xpBonus)
        
        // Celebration feedback
        QuizHapticFeedback.completion()
        
        showResults = true
    }
    
    private func resetQuiz() {
        quizService.resetQuiz()
        currentQuestionIndex = 0
        selectedAnswers = []
        showResults = false
        showExplanation = false
        currentAnswer = nil
    }
    
    private func hasAnsweredCurrentQuestion() -> Bool {
        return selectedAnswers.indices.contains(currentQuestionIndex) && 
               selectedAnswers[currentQuestionIndex] != nil
    }
    
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Helper Functions for Simple UI
    private func buttonColor(for index: Int) -> Color {
        if showExplanation {
            if index == quizService.currentQuiz[currentQuestionIndex].correctAnswer {
                return .green
            } else if selectedAnswers.indices.contains(currentQuestionIndex) && 
                      selectedAnswers[currentQuestionIndex] == index {
                return .red
            }
        } else if selectedAnswers.indices.contains(currentQuestionIndex) && 
                  selectedAnswers[currentQuestionIndex] == index {
            return .blue
        }
        return .gray
    }
    
    private func backgroundColor(for index: Int) -> Color {
        if showExplanation {
            if index == quizService.currentQuiz[currentQuestionIndex].correctAnswer {
                return Color.green.opacity(0.1)
            } else if selectedAnswers.indices.contains(currentQuestionIndex) && 
                      selectedAnswers[currentQuestionIndex] == index {
                return Color.red.opacity(0.1)
            }
        } else if selectedAnswers.indices.contains(currentQuestionIndex) && 
                  selectedAnswers[currentQuestionIndex] == index {
            return Color.blue.opacity(0.1)
        }
        return Color.clear
    }
    
    private func borderColor(for index: Int) -> Color {
        if showExplanation {
            if index == quizService.currentQuiz[currentQuestionIndex].correctAnswer {
                return .green
            } else if selectedAnswers.indices.contains(currentQuestionIndex) && 
                      selectedAnswers[currentQuestionIndex] == index {
                return .red
            }
        } else if selectedAnswers.indices.contains(currentQuestionIndex) && 
                  selectedAnswers[currentQuestionIndex] == index {
            return .blue
        }
        return Color.clear
    }
}

#Preview {
    QuizView(gameModel: NinjaGameModel())
}
