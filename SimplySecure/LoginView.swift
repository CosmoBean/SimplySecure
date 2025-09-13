import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @Binding var isLoggedIn: Bool
    @Binding var showVideo: Bool
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                Spacer()
            // App Logo and Title
            VStack(spacing: 16) {
                Image("logobro")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                
                Text("SimplySecure")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Security Management Platform")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Login Form
            VStack(spacing: 20) {
                VStack(alignment: .center, spacing: 8) {
                    Text("Username")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    TextField("Enter username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(.title2, design: .default))
                        .disableAutocorrection(true)
                        .frame(height: 100)
                }
                
                VStack(alignment: .center, spacing: 8) {
                    Text("Password")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    SecureField("Enter password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(.title2, design: .default))
                        .frame(height: 100)
                }
                
                // Error Message
                if showError {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red.opacity(0.1))
                    )
                    .multilineTextAlignment(.center)
                }
                
                // Login Button
                Button(action: login) {
                    HStack {
                        Image(systemName: "person.badge.key.fill")
                            .font(.title2)
                        Text("Login")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(username.isEmpty || password.isEmpty)
            }
            .padding(.horizontal, 250)
            
            // // Demo Credentials Info
            // VStack(spacing: 12) {
            //     Text("Demo Credentials")
            //         .font(.headline)
            //         .fontWeight(.semibold)
            //         .foregroundColor(.secondary)
                
            //     VStack(spacing: 8) {
            //         HStack {
            //             Text("Username:")
            //                 .font(.subheadline)
            //                 .foregroundColor(.secondary)
            //             Text("admin")
            //                 .font(.subheadline)
            //                 .fontWeight(.semibold)
            //                 .foregroundColor(.primary)
            //         }
                    
            //         HStack {
            //             Text("Password:")
            //                 .font(.subheadline)
            //                 .foregroundColor(.secondary)
            //             Text("admin")
            //                 .font(.subheadline)
            //                 .fontWeight(.semibold)
            //                 .foregroundColor(.primary)
            //         }
            //     }
            //     .padding()
            //     .background(
            //         RoundedRectangle(cornerRadius: 8)
            //             .fill(Color(NSColor.controlBackgroundColor))
            //     )
            // }
            // .padding(.horizontal, 40)
            
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
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
            .onSubmit {
                login()
            }
        }
    }
    
    private func login() {
        // Clear previous error
        showError = false
        errorMessage = ""
        
        // Check credentials
        if username.lowercased() == "admin" && password == "admin" {
            // Successful login - show video screen
            showVideo = true
        } else {
            // Failed login
            showError = true
            errorMessage = "Invalid username or password. Please try again."
            
            // Clear password field
            password = ""
        }
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false), showVideo: .constant(false))
}
