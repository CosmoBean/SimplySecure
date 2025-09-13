import SwiftUI

// MARK: - Permission Overlay View

struct PermissionOverlayView: View {
    @ObservedObject var permissionService: AppPermissionService
    @State private var selectedDecisions: [AppPermission: PermissionDecision] = [:]
    @State private var showingPrivacyAnalysis = false
    @State private var privacyAnalysis: PrivacyPolicyAnalysis?
    @State private var privacyInsights: String = ""
    @State private var isAnalyzingPrivacy = false
    
    var body: some View {
        if permissionService.permissionOverlayVisible, let installation = permissionService.currentInstallation {
            ZStack {
                // Background overlay
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Allow dismissing by tapping outside
                        dismissOverlay()
                    }
                
                // Main overlay content
                VStack(spacing: 0) {
                    overlayHeader(installation: installation)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            appInfoSection(installation: installation)
                            
                            if !installation.requestedPermissions.isEmpty {
                                permissionsSection(installation: installation)
                            }
                            
                            if let analysis = privacyAnalysis {
                                privacyAnalysisSection(analysis: analysis)
                            }
                            
                            // Always show privacy insights section (with loading state initially)
                            privacyInsightsSection()
                            
                            recommendationsSection(installation: installation)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                    
                    overlayFooter(installation: installation)
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(NSColor.windowBackgroundColor))
                        .shadow(radius: 20)
                )
                .frame(maxWidth: 600, maxHeight: 700)
                .padding(40)
            }
            .transition(.opacity.combined(with: .scale))
            .onAppear {
                initializeDecisions(for: installation)
                loadPrivacyAnalysis(for: installation)
            }
        }
    }
    
    // MARK: - Header Section
    
    private func overlayHeader(installation: AppInstallation) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("New App Installation Detected")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("SimplySecure is analyzing permissions for your protection")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: dismissOverlay) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }
    
    // MARK: - App Info Section
    
    private func appInfoSection(installation: AppInstallation) -> some View {
        HStack(spacing: 16) {
            // App Icon
            Group {
                if let iconData = installation.appIcon,
                   let nsImage = NSImage(data: iconData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                } else {
                    Image(systemName: "app.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                        .frame(width: 60, height: 60)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.controlBackgroundColor))
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(installation.appName)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Version \(installation.version)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(installation.bundleIdentifier)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontDesign(.monospaced)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    // MARK: - Permissions Section
    
    private func permissionsSection(installation: AppInstallation) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Requested Permissions")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(installation.requestedPermissions.count) permissions")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(installation.requestedPermissions) { permission in
                    permissionRow(permission: permission, installation: installation)
                }
            }
        }
    }
    
    private func permissionRow(permission: AppPermission, installation: AppInstallation) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Permission Icon
                Image(systemName: permission.permissionType.iconName)
                    .font(.title2)
                    .foregroundColor(permission.permissionType.color)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(permission.permissionType.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(permission.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Risk Level Badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(permission.riskLevel.color)
                        .frame(width: 8, height: 8)
                    Text(permission.riskLevel.rawValue)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(permission.riskLevel.color)
                }
            }
            
            // Recommendation and Reasoning
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: permission.recommendation.iconName)
                        .foregroundColor(permission.recommendation.color)
                        .font(.caption)
                    
                    Text("Recommendation: \(permission.recommendation.rawValue)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(permission.recommendation.color)
                    
                    Spacer()
                }
                
                Text(permission.reasoning)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 16)
            }
            .padding(.leading, 36)
            
            // Decision Buttons
            HStack(spacing: 8) {
                ForEach(PermissionDecision.allCases.filter { $0 != .skip }, id: \.self) { decision in
                    Button(action: {
                        selectedDecisions[permission] = decision
                    }) {
                        Text(decision.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(selectedDecisions[permission] == decision ? decision.color : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(decision.color, lineWidth: 1)
                                    )
                            )
                            .foregroundColor(selectedDecisions[permission] == decision ? .white : decision.color)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.leading, 36)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    // MARK: - Privacy Analysis Section
    
    private func privacyAnalysisSection(analysis: PrivacyPolicyAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Privacy Policy Analysis")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text("Score:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(analysis.overallScore)/100")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(analysis.recommendation.color)
                }
            }
            
            // Overall Recommendation
            HStack {
                Image(systemName: "shield.fill")
                    .foregroundColor(analysis.recommendation.color)
                Text("Overall: \(analysis.recommendation.rawValue)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(analysis.recommendation.color)
                Spacer()
            }
            
            Text(analysis.recommendation.description)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Positives and Concerns
            VStack(alignment: .leading, spacing: 8) {
                if !analysis.positives.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("✅ Positives")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                        
                        ForEach(analysis.positives, id: \.self) { positive in
                            Text("• \(positive)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 8)
                        }
                    }
                }
                
                if !analysis.concerns.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("⚠️ Concerns")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                        
                        ForEach(analysis.concerns, id: \.self) { concern in
                            Text("• \(concern)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 8)
                        }
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
    
    // MARK: - Privacy Insights Section
    
    private func privacyInsightsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("AI Privacy Analysis")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.purple)
            }
            
            if isAnalyzingPrivacy || privacyInsights.isEmpty {
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.9)
                            .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                        Text("Analyzing privacy implications...")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    Text("This may take a few moments while we analyze the app's privacy policy and permissions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 16)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.purple.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                        )
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                Text(privacyInsights)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.purple.opacity(0.1))
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
        .animation(.easeInOut(duration: 0.3), value: isAnalyzingPrivacy)
        .animation(.easeInOut(duration: 0.3), value: privacyInsights.isEmpty)
    }
    
    // MARK: - Recommendations Section
    
    private func recommendationsSection(installation: AppInstallation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Security Recommendations")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                recommendationRow(
                    icon: "shield.checkered",
                    title: "Review Each Permission",
                    description: "Carefully consider each permission request based on the app's stated purpose."
                )
                
                recommendationRow(
                    icon: "doc.text.magnifyingglass",
                    title: "Read Privacy Policy",
                    description: "Check the app's privacy policy to understand how your data will be used."
                )
                
                recommendationRow(
                    icon: "gear",
                    title: "Use Limited Access",
                    description: "When possible, choose 'Limited' access instead of full permission."
                )
                
                recommendationRow(
                    icon: "bell.slash",
                    title: "Deny Unnecessary Permissions",
                    description: "Deny permissions that aren't essential for the app's core functionality."
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.1))
        )
    }
    
    private func recommendationRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(.blue)
                .frame(width: 16, height: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Footer Section
    
    private func overlayFooter(installation: AppInstallation) -> some View {
        HStack(spacing: 12) {
            Button("Skip for Now") {
                dismissOverlay()
            }
            .buttonStyle(PlainButtonStyle())
            .foregroundColor(.secondary)
            
            Spacer()
            
            Button("Apply Decisions") {
                applyPermissionDecisions(for: installation)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!hasAllDecisionsMade(for: installation))
            .opacity(hasAllDecisionsMade(for: installation) ? 1.0 : 0.5)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
    
    // MARK: - Helper Methods
    
    private func initializeDecisions(for installation: AppInstallation) {
        selectedDecisions = [:]
        for permission in installation.requestedPermissions {
            selectedDecisions[permission] = permission.recommendation == .allow ? .allow : .limited
        }
    }
    
    private func loadPrivacyAnalysis(for installation: AppInstallation) {
        // Initialize loading state immediately
        DispatchQueue.main.async {
            self.isAnalyzingPrivacy = true
            self.privacyInsights = ""
        }
        
        Task {
            // Load privacy policy analysis if URL is available
            if let privacyURL = installation.privacyPolicyURL {
                let analysis = await permissionService.analyzePrivacyPolicy(url: privacyURL)
                DispatchQueue.main.async {
                    self.privacyAnalysis = analysis
                }
            }
            
            // Load additional privacy insights from Perplexity
            let permissionsList = installation.requestedPermissions.map { $0.permissionType.rawValue }
            let insights = await permissionService.getPerplexityService().analyzeAppPrivacy(
                for: installation.appName,
                bundleIdentifier: installation.bundleIdentifier,
                permissions: permissionsList
            )
            
            DispatchQueue.main.async {
                self.privacyInsights = insights ?? "Privacy analysis unavailable"
                self.isAnalyzingPrivacy = false
            }
        }
    }
    
    private func hasAllDecisionsMade(for installation: AppInstallation) -> Bool {
        return installation.requestedPermissions.allSatisfy { permission in
            selectedDecisions[permission] != nil
        }
    }
    
    private func applyPermissionDecisions(for installation: AppInstallation) {
        let primaryDecision = determinePrimaryDecision()
        permissionService.makePermissionDecision(installation, decision: primaryDecision)
    }
    
    private func determinePrimaryDecision() -> PermissionDecision {
        let decisions = selectedDecisions.values
        
        if decisions.contains(.deny) {
            return .deny
        } else if decisions.contains(.limited) {
            return .limited
        } else {
            return .allow
        }
    }
    
    private func dismissOverlay() {
        withAnimation(.easeInOut(duration: 0.3)) {
            permissionService.permissionOverlayVisible = false
        }
    }
}

// MARK: - Preview

#Preview {
    PermissionOverlayView(permissionService: AppPermissionService())
        .frame(width: 800, height: 600)
}
