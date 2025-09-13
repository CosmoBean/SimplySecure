import SwiftUI
import SwiftData

@main
struct SimplySecureApp: App {
    @State private var isLoggedIn = false
    @State private var showVideo = false
    
    var body: some Scene {
        WindowGroup {
            if showVideo {
                VideoScreen(
                    onComplete: {
                        showVideo = false
                        isLoggedIn = true
                    }
                )
            } else if isLoggedIn {
                ContentView()
            } else {
                LoginView(
                    isLoggedIn: $isLoggedIn,
                    showVideo: $showVideo
                )
            }
        }
        .windowStyle(DefaultWindowStyle())
        .windowResizability(.contentSize)
        .modelContainer(for: User.self)
    }
}