import SwiftUI
import AVKit
import AppKit

struct SimpleVideoPlayer: View {
    let videoURL: URL
    @Binding var isPresented: Bool
    @State private var player: AVPlayer?
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome Video")
                .font(.title)
                .fontWeight(.bold)
            
            if let player = player {
                AVPlayerViewRepresentable(player: player)
                    .frame(width: 600, height: 400)
                    .cornerRadius(12)
            } else {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading video...")
                        .font(.headline)
                }
                .frame(width: 600, height: 400)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
            }
            
            Button("Continue") {
                dismissVideo()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(8)
        }
        .padding()
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            cleanupPlayer()
        }
    }
    
    private func setupPlayer() {
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
        isPresented = false
        onDismiss()
    }
}

struct AVPlayerViewRepresentable: NSViewRepresentable {
    let player: AVPlayer
    
    func makeNSView(context: Context) -> AVPlayerView {
        let playerView = AVPlayerView()
        playerView.player = player
        playerView.controlsStyle = .floating
        playerView.showsFullScreenToggleButton = false
        playerView.showsSharingServiceButton = false
        return playerView
    }
    
    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        nsView.player = player
    }
}