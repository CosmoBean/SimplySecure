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
        NavigationView {
            if showResults, let session = quizService.currentSession {
                resultsView(session: session)
            } else if !quizService.currentQuiz.isEmpty {
                quizGameView
            } else {
                quizSetupView
            }
        }
        .navigationTitle("Security Quiz")
    }
    
    // MARK: - Quiz Setup View
    private var quizSetupView: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerView
                difficultySelectionView
                categorySelectionView
                questionCountView
                generateButtonView
                examplesView
            }
            .padding()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title)
                    .foregroundColor(.purple)
                Text("Security Quiz")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            Text("Test your macOS security knowledge with AI-generated questions")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if !GeminiConfig.shared.isConfigured {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("API Key Required - Configure Gemini API to generate quizzes")
                        .font(.caption)
                        .foregroundColor(.orange)
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
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private var difficultySelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Difficulty Level")
                .font(.headline)
                .fontWeight(.semibold)
            
            Picker("Difficulty", selection: $selectedDifficulty) {
                ForEach(QuizDifficulty.allCases, id: \.self) { difficulty in
                    HStack {
                        Text(difficulty.rawValue)
                        Spacer()
                        Text("\(difficulty.points) pts")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .tag(difficulty)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private var categorySelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quiz Category")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(QuizCategory.allCases, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: category.icon)
                                .font(.title2)
                                .foregroundColor(selectedCategory == category ? .white : .primary)
                            
                            Text(category.rawValue)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedCategory == category ? Color.blue : Color(NSColor.controlBackgroundColor))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private var questionCountView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Number of Questions")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                Text("Questions:")
                    .font(.subheadline)
                Spacer()
                Stepper(value: $numberOfQuestions, in: 3...10) {
                    Text("\(numberOfQuestions)")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private var generateButtonView: some View {
        VStack(spacing: 8) {
            AnimatedQuizButton(
                title: quizService.isLoading ? "Generating Quiz..." : "Generate Quiz",
                icon: "sparkles",
                color: quizService.isLoading ? Color.orange : Color.purple,
                isEnabled: !quizService.isLoading && GeminiConfig.shared.isConfigured,
                isLoading: quizService.isLoading,
                action: generateQuiz
            )
            
            if !quizService.errorMessage.isEmpty {
                Text("Error: \(quizService.errorMessage)")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 8)
                    .transition(.opacity.combined(with: .scale))
            }
        }
    }
    
    private var examplesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Example Topics")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                exampleTopic("FileVault Encryption", "Learn about full-disk encryption")
                exampleTopic("Firewall Configuration", "Understand network security")
                exampleTopic("Privacy Settings", "Master macOS privacy controls")
                exampleTopic("System Integrity Protection", "Explore SIP security features")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private func exampleTopic(_ title: String, _ description: String) -> some View {
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
    
    // MARK: - Quiz Game View
    private var quizGameView: some View {
        VStack(spacing: 0) {
            progressHeaderView
            
            ScrollView {
                VStack(spacing: 20) {
                    questionView
                    optionsView
                    navigationView
                }
                .padding()
            }
        }
    }
    
    private var progressHeaderView: some View {
        VStack(spacing: 8) {
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
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.blue.opacity(0.2))
                    )
                    .foregroundColor(.blue)
            }
            
            AnimatedProgressBar(
                progress: Double(currentQuestionIndex) / Double(quizService.currentQuiz.count),
                color: .blue,
                height: 8
            )
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var questionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: quizService.currentQuiz[currentQuestionIndex].category.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text(quizService.currentQuiz[currentQuestionIndex].category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(quizService.currentQuiz[currentQuestionIndex].points) points")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            
            Text(quizService.currentQuiz[currentQuestionIndex].question)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
            
            if showExplanation {
                explanationView
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private var optionsView: some View {
        VStack(spacing: 12) {
            ForEach(Array(quizService.currentQuiz[currentQuestionIndex].options.enumerated()), id: \.offset) { index, option in
                optionButton(index: index, option: option)
            }
        }
    }
    
    private func optionButton(index: Int, option: String) -> some View {
        AnimatedOptionButton(
            option: option,
            index: index,
            isSelected: selectedAnswers.indices.contains(currentQuestionIndex) && selectedAnswers[currentQuestionIndex] == index,
            isCorrect: showExplanation && index == quizService.currentQuiz[currentQuestionIndex].correctAnswer,
            isWrong: showExplanation && selectedAnswers.indices.contains(currentQuestionIndex) && selectedAnswers[currentQuestionIndex] == index && index != quizService.currentQuiz[currentQuestionIndex].correctAnswer,
            showResult: showExplanation,
            action: {
                selectAnswer(index)
            }
        )
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
            Button("Previous") {
                previousQuestion()
            }
            .disabled(currentQuestionIndex == 0)
            
            Spacer()
            
            if currentQuestionIndex == quizService.currentQuiz.count - 1 {
                Button("Finish Quiz") {
                    finishQuiz()
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green)
                )
            } else {
                Button("Next") {
                    nextQuestion()
                }
                .disabled(!hasAnsweredCurrentQuestion())
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Results View
    private func resultsView(session: QuizSession) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                resultsHeaderView(session: session)
                scoreBreakdownView(session: session)
                questionsReviewView(session: session)
                actionButtonsView
            }
            .padding()
        }
    }
    
    private func resultsHeaderView(session: QuizSession) -> some View {
        ZStack {
            VStack(spacing: 16) {
                Text(session.grade.emoji)
                    .font(.system(size: 60))
                    .scaleEffect(1.2)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showResults)
                
                Text(session.grade.rawValue)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(session.grade.color))
                
                Text(session.grade.message)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 8) {
                    Text("\(session.score)/\(session.totalPoints) points")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(session.percentage, specifier: "%.1f")%")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Time: \(formatTime(session.timeSpent))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(NSColor.controlBackgroundColor))
            )
            
            // Celebration effect for excellent scores
            if session.grade == .excellent {
                QuizAnimations.celebrationEffect()
                    .opacity(0.8)
            }
        }
    }
    
    private func scoreBreakdownView(session: QuizSession) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Score Breakdown")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(Array(session.questions.enumerated()), id: \.offset) { index, question in
                let isCorrect = session.answers.indices.contains(index) && 
                               session.answers[index] == question.correctAnswer
                
                HStack {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isCorrect ? .green : .red)
                    
                    Text("Question \(index + 1)")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(isCorrect ? question.points : 0)/\(question.points) pts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private func questionsReviewView(session: QuizSession) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Question Review")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(Array(session.questions.enumerated()), id: \.offset) { index, question in
                questionReviewRow(question: question, index: index, session: session)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private func questionReviewRow(question: QuizQuestion, index: Int, session: QuizSession) -> some View {
        let isCorrect = session.answers.indices.contains(index) && 
                       session.answers[index] == question.correctAnswer
        let userAnswer = session.answers.indices.contains(index) ? session.answers[index] : nil
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Q\(index + 1)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(
                        Circle()
                            .fill(isCorrect ? Color.green : Color.red)
                    )
                
                Text(question.question)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            if let userAnswer = userAnswer {
                HStack {
                    Text("Your answer:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(question.options[userAnswer])
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(isCorrect ? .green : .red)
                }
            }
            
            if !isCorrect {
                HStack {
                    Text("Correct answer:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(question.options[question.correctAnswer])
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.05))
        )
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 12) {
            Button("Take Another Quiz") {
                resetQuiz()
            }
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.purple)
            )
            
            Button("Share Results") {
                // TODO: Implement sharing
            }
            .fontWeight(.semibold)
            .foregroundColor(.blue)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2)
            )
        }
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
    
    private func optionColor(for index: Int) -> Color {
        if !showExplanation {
            return selectedAnswers.indices.contains(currentQuestionIndex) && 
                   selectedAnswers[currentQuestionIndex] == index ? .blue : .gray
        } else {
            let question = quizService.currentQuiz[currentQuestionIndex]
            if index == question.correctAnswer {
                return .green
            } else if selectedAnswers.indices.contains(currentQuestionIndex) && 
                      selectedAnswers[currentQuestionIndex] == index {
                return .red
            } else {
                return .gray
            }
        }
    }
    
    private func optionBackgroundColor(for index: Int) -> Color {
        if !showExplanation {
            return selectedAnswers.indices.contains(currentQuestionIndex) && 
                   selectedAnswers[currentQuestionIndex] == index ? Color.blue.opacity(0.1) : Color.clear
        } else {
            let question = quizService.currentQuiz[currentQuestionIndex]
            if index == question.correctAnswer {
                return Color.green.opacity(0.1)
            } else if selectedAnswers.indices.contains(currentQuestionIndex) && 
                      selectedAnswers[currentQuestionIndex] == index {
                return Color.red.opacity(0.1)
            } else {
                return Color.clear
            }
        }
    }
    
    private func optionBorderColor(for index: Int) -> Color {
        if !showExplanation {
            return selectedAnswers.indices.contains(currentQuestionIndex) && 
                   selectedAnswers[currentQuestionIndex] == index ? .blue : .clear
        } else {
            let question = quizService.currentQuiz[currentQuestionIndex]
            if index == question.correctAnswer {
                return .green
            } else if selectedAnswers.indices.contains(currentQuestionIndex) && 
                      selectedAnswers[currentQuestionIndex] == index {
                return .red
            } else {
                return .clear
            }
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    QuizView(gameModel: NinjaGameModel())
}
