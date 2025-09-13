import SwiftUI
import SwiftData

@main
struct SimplySecureApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(DefaultWindowStyle())
        .windowResizability(.contentSize)
        .modelContainer(for: User.self)
    }
}