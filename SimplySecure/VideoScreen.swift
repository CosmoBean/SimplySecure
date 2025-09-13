import SwiftUI
import AVKit
import AppKit

struct VideoScreen: View {
    let onComplete: () -> Void
    @State private var player: AVPlayer?
    
    var body: some View {
        VStack(spacing: 30) {
            // App branding
            VStack(spacing: 16) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Text("Welcome to SimplySecure")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Security Management Platform")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Video player
            if let player = player {
                AVPlayerViewRepresentable(player: player)
                    .frame(width: 800, height: 450)
                    .cornerRadius(12)
                    .shadow(radius: 10)
            } else {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading video...")
                        .font(.headline)
                }
                .frame(width: 800, height: 450)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
            }
            
            Spacer()
            
            // Continue button
            Button("Continue to App") {
                dismissVideo()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 40)
            .padding(.vertical, 15)
            .background(Color.blue)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(NSColor.controlBackgroundColor),
                    Color(NSColor.controlBackgroundColor).opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            cleanupPlayer()
        }
    }
    
    private func setupPlayer() {
        guard let videoURL = Bundle.main.url(forResource: "intro", withExtension: "mp4") else {
            print("Video file not found")
            return
        }
        
        player = AVPlayer(url: videoURL)
        player?.play()
        
        // Auto-dismiss when video ends
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            dismissVideo()
        }
    }
    
    private func cleanupPlayer() {
        player?.pause()
        player = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    private func dismissVideo() {
        cleanupPlayer()
        onComplete()
    }
}

