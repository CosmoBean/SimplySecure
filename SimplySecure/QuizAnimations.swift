import SwiftUI

// MARK: - Quiz Animations and Effects
struct QuizAnimations {
    
    // MARK: - Answer Selection Animation
    static func answerSelectionEffect() -> some View {
        Circle()
            .stroke(Color.blue, lineWidth: 2)
            .scaleEffect(1.2)
            .opacity(0.6)
            .animation(.easeInOut(duration: 0.3), value: true)
    }
    
    // MARK: - Correct Answer Animation
    static func correctAnswerEffect() -> some View {
        ZStack {
            Circle()
                .fill(Color.green.opacity(0.3))
                .scaleEffect(1.5)
                .opacity(0.8)
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.green)
                .scaleEffect(1.2)
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: true)
    }
    
    // MARK: - Wrong Answer Animation
    static func wrongAnswerEffect() -> some View {
        ZStack {
            Circle()
                .fill(Color.red.opacity(0.3))
                .scaleEffect(1.5)
                .opacity(0.8)
            
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)
                .scaleEffect(1.2)
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: true)
    }
    
    // MARK: - Progress Animation
    static func progressPulse() -> some View {
        Circle()
            .fill(Color.blue.opacity(0.2))
            .scaleEffect(1.1)
            .opacity(0.7)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: true)
    }
    
    // MARK: - XP Gain Animation
    static func xpGainEffect(points: Int) -> some View {
        VStack {
            Text("+\(points) XP")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.yellow)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.7))
                )
        }
        .offset(y: -50)
        .opacity(0.8)
        .scaleEffect(1.1)
        .animation(.easeOut(duration: 2.0), value: true)
    }
    
    // MARK: - Quiz Complete Celebration
    static func celebrationEffect() -> some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Image(systemName: "star.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
                    .offset(
                        x: cos(Double(index) * .pi / 4) * 100,
                        y: sin(Double(index) * .pi / 4) * 100
                    )
                    .opacity(0.8)
                    .animation(
                        .easeOut(duration: 1.5)
                        .delay(Double(index) * 0.1),
                        value: true
                    )
            }
        }
    }
    
    // MARK: - Loading Animation
    static func loadingDots() -> some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                    .scaleEffect(1.0)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: true
                    )
            }
        }
    }
}

// MARK: - Animated Quiz Components
struct AnimatedQuizButton: View {
    let title: String
    let icon: String
    let color: Color
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    QuizAnimations.loadingDots()
                } else {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEnabled ? color : Color.gray)
                    .scaleEffect(isPressed ? 0.95 : 1.0)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled || isLoading)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct AnimatedOptionButton: View {
    let option: String
    let index: Int
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let showResult: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var showFeedback = false
    
    var body: some View {
        Button(action: {
            action()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                showFeedback = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showFeedback = false
                }
            }
        }) {
            HStack {
                Text(String(UnicodeScalar(65 + index)!))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(optionColor)
                    )
                
                Text(option)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .transition(.scale.combined(with: .opacity))
                }
                
                if showResult && isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .transition(.scale.combined(with: .opacity))
                } else if showResult && isWrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(optionBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(optionBorderColor, lineWidth: 2)
                    )
                    .scaleEffect(isPressed ? 0.98 : 1.0)
            )
            .overlay(
                feedbackOverlay
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(showResult)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
    
    private var optionColor: Color {
        if showResult {
            if isCorrect {
                return .green
            } else if isWrong {
                return .red
            } else {
                return .gray
            }
        } else {
            return isSelected ? .blue : .gray
        }
    }
    
    private var optionBackgroundColor: Color {
        if showResult {
            if isCorrect {
                return Color.green.opacity(0.1)
            } else if isWrong {
                return Color.red.opacity(0.1)
            } else {
                return Color.clear
            }
        } else {
            return isSelected ? Color.blue.opacity(0.1) : Color.clear
        }
    }
    
    private var optionBorderColor: Color {
        if showResult {
            if isCorrect {
                return .green
            } else if isWrong {
                return .red
            } else {
                return .clear
            }
        } else {
            return isSelected ? .blue : .clear
        }
    }
    
    @ViewBuilder
    private var feedbackOverlay: some View {
        if showFeedback {
            ZStack {
                if isCorrect {
                    QuizAnimations.correctAnswerEffect()
                } else if isWrong {
                    QuizAnimations.wrongAnswerEffect()
                }
            }
            .transition(.scale.combined(with: .opacity))
        }
    }
}

struct AnimatedProgressBar: View {
    let progress: Double
    let color: Color
    let height: CGFloat
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: height)
                
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color, color.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * animatedProgress, height: height)
                    .animation(.easeInOut(duration: 0.8), value: animatedProgress)
            }
        }
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeInOut(duration: 0.8)) {
                animatedProgress = newValue
            }
        }
    }
}

struct FloatingXPGain: View {
    let points: Int
    let position: CGPoint
    
    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 1.0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Text("+\(points) XP")
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.yellow)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.8))
            )
            .offset(offset)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeOut(duration: 2.0)) {
                    offset = CGSize(width: 0, height: -100)
                    opacity = 0.0
                    scale = 1.5
                }
            }
    }
}

struct QuizParticleEffect: View {
    let isActive: Bool
    
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var velocity: CGVector
        var opacity: Double
        var scale: CGFloat
    }
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 4, height: 4)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
            }
        }
        .onAppear {
            if isActive {
                createParticles()
            }
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                createParticles()
            } else {
                particles = []
            }
        }
    }
    
    private func createParticles() {
        particles = (0..<20).map { _ in
            Particle(
                position: CGPoint(x: Double.random(in: 0...400), y: Double.random(in: 0...400)),
                velocity: CGVector(
                    dx: Double.random(in: -50...50),
                    dy: Double.random(in: -50...50)
                ),
                opacity: Double.random(in: 0.3...1.0),
                scale: CGFloat.random(in: 0.5...1.5)
            )
        }
        
        withAnimation(.easeOut(duration: 3.0)) {
            for i in particles.indices {
                particles[i].position.x += particles[i].velocity.dx
                particles[i].position.y += particles[i].velocity.dy
                particles[i].opacity = 0.0
                particles[i].scale = 0.1
            }
        }
    }
}

// MARK: - Haptic Feedback
struct QuizHapticFeedback {
    static func selection() {
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        #endif
    }
    
    static func correct() {
        #if os(iOS)
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        #endif
    }
    
    static func wrong() {
        #if os(iOS)
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
        #endif
    }
    
    static func completion() {
        #if os(iOS)
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        #endif
    }
}
