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
                Image(systemName: "shield.checkered")
                    .font(.system(size: 120))
                    .foregroundColor(.red)
                
                Text("SimplySecure")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Security Management Platform")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Login Form
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("Username")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("Enter username", text: $username)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(NSColor.controlBackgroundColor))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .disableAutocorrection(true)
                }
                
                VStack(spacing: 8) {
                    Text("Password")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    SecureField("Enter password", text: $password)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(NSColor.controlBackgroundColor))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                
                // Error Message
                if showError {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.red.opacity(0.1))
                    )
                }
                
                // Login Button
                Button(action: login) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.badge.key.fill")
                            .font(.subheadline)
                        Text("Login")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(username.isEmpty || password.isEmpty)
                .opacity(username.isEmpty || password.isEmpty ? 0.6 : 1.0)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .frame(width: 320)
            
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
