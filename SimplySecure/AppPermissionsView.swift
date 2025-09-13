import SwiftUI

// MARK: - App Permissions View

struct AppPermissionsView: View {
    @ObservedObject var permissionService: AppPermissionService
    @State private var showingTestOverlay = false
    @State private var testApp: AppInstallation?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerView
                
                // Monitoring Status
                monitoringStatusView
                
                // Recent Installations
                recentInstallationsView
                
                
                // Statistics
                statisticsView
            }
            .padding()
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.title)
                    .foregroundColor(.blue)
                Text("App Permission Manager")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            Text("Monitor and manage app permissions for enhanced privacy and security")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    // MARK: - Monitoring Status View
    
    private var monitoringStatusView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monitoring Status")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                Image(systemName: permissionService.isMonitoring ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(permissionService.isMonitoring ? .green : .red)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(permissionService.isMonitoring ? "Active" : "Inactive")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(permissionService.isMonitoring ? .green : .red)
                    
                    Text(permissionService.isMonitoring ? 
                         "Automatically tracking all apps and monitoring for new installations" : 
                         "App tracking is disabled")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button("Rescan Apps") {
                        permissionService.rescanExistingApps()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Button(permissionService.isMonitoring ? "Stop Tracking" : "Start Tracking") {
                        if permissionService.isMonitoring {
                            permissionService.stopMonitoring()
                        } else {
                            permissionService.startMonitoring()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    // MARK: - Recent Installations View
    
    private var recentInstallationsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Installations")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(permissionService.pendingInstallations.count) pending")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if permissionService.pendingInstallations.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "app.badge.checkmark")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    
                    Text("No Recent Installations")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("SimplySecure will automatically detect new app installations and show permission overlays when needed.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green.opacity(0.1))
                )
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(permissionService.pendingInstallations) { installation in
                        installationRow(installation: installation)
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
    
    private func installationRow(installation: AppInstallation) -> some View {
        HStack(spacing: 12) {
            // App Icon
            Group {
                if let iconData = installation.appIcon,
                   let nsImage = NSImage(data: iconData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                } else {
                    Image(systemName: "app.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 40, height: 40)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.controlBackgroundColor))
            )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(installation.appName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("\(installation.requestedPermissions.count) permissions requested")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Installed \(installation.installDate.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Button("Review Permissions") {
                    permissionService.currentInstallation = installation
                    permissionService.permissionOverlayVisible = true
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                if installation.requestedPermissions.count > 0 {
                    let highRiskCount = installation.requestedPermissions.filter { $0.riskLevel == .high }.count
                    if highRiskCount > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.caption2)
                            Text("\(highRiskCount) high risk")
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    // MARK: - Test Controls View
    
    private var testControlsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Test Controls")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Test the permission overlay with sample apps")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Button("Test Camera App") {
                    testApp = createTestApp(
                        name: "Test Camera App",
                        bundleId: "com.test.camera",
                        permissions: [
                            AppPermission(permissionType: .camera, description: "Take photos and videos"),
                            AppPermission(permissionType: .microphone, description: "Record audio for videos"),
                            AppPermission(permissionType: .photos, description: "Access photo library")
                        ]
                    )
                    showingTestOverlay = true
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button("Test Social Media App") {
                    testApp = createTestApp(
                        name: "Test Social Media App",
                        bundleId: "com.test.social",
                        permissions: [
                            AppPermission(permissionType: .contacts, description: "Find friends to connect with"),
                            AppPermission(permissionType: .location, description: "Share your location"),
                            AppPermission(permissionType: .photos, description: "Share photos and videos"),
                            AppPermission(permissionType: .notifications, description: "Receive notifications")
                        ]
                    )
                    showingTestOverlay = true
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button("Test Utility App") {
                    testApp = createTestApp(
                        name: "Test Utility App",
                        bundleId: "com.test.utility",
                        permissions: [
                            AppPermission(permissionType: .files, description: "Access files for organization"),
                            AppPermission(permissionType: .notifications, description: "Show reminders and alerts")
                        ]
                    )
                    showingTestOverlay = true
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    // MARK: - Statistics View
    
    private var statisticsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Permission Statistics")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Apps Monitored")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(permissionService.pendingInstallations.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("High Risk Permissions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(totalHighRiskPermissions)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Avg. Permissions/App")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(averagePermissionsPerApp, specifier: "%.1f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    // MARK: - Helper Methods
    
    private func createTestApp(name: String, bundleId: String, permissions: [AppPermission]) -> AppInstallation {
        return AppInstallation(
            bundleIdentifier: bundleId,
            appName: name,
            version: "1.0",
            appIcon: nil,
            requestedPermissions: permissions,
            termsAndConditionsURL: "https://example.com/terms",
            privacyPolicyURL: "https://example.com/privacy"
        )
    }
    
    private var totalHighRiskPermissions: Int {
        permissionService.pendingInstallations.flatMap { $0.requestedPermissions }
            .filter { $0.riskLevel == .high }
            .count
    }
    
    private var averagePermissionsPerApp: Double {
        guard !permissionService.pendingInstallations.isEmpty else { return 0 }
        let totalPermissions = permissionService.pendingInstallations.reduce(0) { $0 + $1.requestedPermissions.count }
        return Double(totalPermissions) / Double(permissionService.pendingInstallations.count)
    }
}

// MARK: - Preview

#Preview {
    AppPermissionsView(permissionService: AppPermissionService())
        .frame(width: 800, height: 600)
}
