import Foundation
import SwiftUI

// MARK: - App Permission Models

struct AppInstallation: Identifiable, Codable {
    let id: UUID
    let bundleIdentifier: String
    let appName: String
    let version: String
    let installDate: Date
    let appIcon: Data?
    let requestedPermissions: [AppPermission]
    let termsAndConditionsURL: String?
    let privacyPolicyURL: String?
    
    init(bundleIdentifier: String, appName: String, version: String, appIcon: Data? = nil, requestedPermissions: [AppPermission] = [], termsAndConditionsURL: String? = nil, privacyPolicyURL: String? = nil) {
        self.id = UUID()
        self.bundleIdentifier = bundleIdentifier
        self.appName = appName
        self.version = version
        self.installDate = Date()
        self.appIcon = appIcon
        self.requestedPermissions = requestedPermissions
        self.termsAndConditionsURL = termsAndConditionsURL
        self.privacyPolicyURL = privacyPolicyURL
    }
}

struct AppPermission: Identifiable, Codable, Hashable {
    let id: UUID
    let permissionType: PermissionType
    let description: String
    let isRequired: Bool
    let riskLevel: RiskLevel
    let recommendation: PermissionRecommendation
    let reasoning: String
    
    init(permissionType: PermissionType, description: String, isRequired: Bool = false) {
        self.id = UUID()
        self.permissionType = permissionType
        self.description = description
        self.isRequired = isRequired
        self.riskLevel = Self.assessRiskLevel(for: permissionType)
        self.recommendation = Self.generateRecommendation(for: permissionType, riskLevel: self.riskLevel)
        self.reasoning = Self.generateReasoning(for: permissionType, riskLevel: self.riskLevel)
    }
    
    private static func assessRiskLevel(for permissionType: PermissionType) -> RiskLevel {
        switch permissionType {
        case .camera, .microphone, .contacts, .photos, .files:
            return .high
        case .location, .notifications, .calendar, .reminders:
            return .medium
        case .network, .systemEvents:
            return .low
        }
    }
    
    private static func generateRecommendation(for permissionType: PermissionType, riskLevel: RiskLevel) -> PermissionRecommendation {
        switch (permissionType, riskLevel) {
        case (.camera, _), (.microphone, _):
            return .deny
        case (.contacts, _), (.photos, _):
            return .limited
        case (.location, _), (.notifications, _), (.calendar, _), (.reminders, _):
            return .allow
        case (.network, _), (.files, _), (.systemEvents, _):
            return .allow
        }
    }
    
    private static func generateReasoning(for permissionType: PermissionType, riskLevel: RiskLevel) -> String {
        switch permissionType {
        case .camera:
            return "Camera access can be used to record you without consent. Only allow if absolutely necessary for the app's core functionality."
        case .microphone:
            return "Microphone access can record conversations. Grant only to trusted apps that genuinely need audio input."
        case .location:
            return "Location access reveals your whereabouts. Consider if the app truly needs your precise location."
        case .contacts:
            return "Contact access can expose personal information of your friends and family. Use limited access when possible."
        case .photos:
            return "Photo library access can see all your personal images. Grant limited access to specific photos when possible."
        case .notifications:
            return "Notifications are generally safe but can be annoying. Allow if you want app updates."
        case .calendar, .reminders:
            return "Calendar access can see your schedule. Only allow to productivity apps you trust."
        case .network:
            return "Network access is usually necessary for apps to function properly."
        case .files:
            return "File access should be limited to specific folders when possible."
        case .systemEvents:
            return "System events access can monitor system activity. Only allow to trusted system utilities."
        }
    }
}

enum PermissionType: String, CaseIterable, Codable, Hashable {
    case camera = "Camera"
    case microphone = "Microphone"
    case location = "Location"
    case contacts = "Contacts"
    case photos = "Photos"
    case notifications = "Notifications"
    case calendar = "Calendar"
    case reminders = "Reminders"
    case network = "Network"
    case files = "Files"
    case systemEvents = "System Events"
    
    var iconName: String {
        switch self {
        case .camera: return "camera.fill"
        case .microphone: return "mic.fill"
        case .location: return "location.fill"
        case .contacts: return "person.2.fill"
        case .photos: return "photo.fill"
        case .notifications: return "bell.fill"
        case .calendar: return "calendar"
        case .reminders: return "checklist"
        case .network: return "network"
        case .files: return "folder.fill"
        case .systemEvents: return "gear"
        }
    }
    
    var color: Color {
        switch self {
        case .camera, .microphone: return .red
        case .location, .contacts, .photos: return .orange
        case .notifications, .calendar, .reminders: return .blue
        case .network, .files, .systemEvents: return .green
        }
    }
}

enum RiskLevel: String, CaseIterable, Codable, Hashable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
    
    var description: String {
        switch self {
        case .low: return "Low privacy risk"
        case .medium: return "Medium privacy risk"
        case .high: return "High privacy risk"
        }
    }
}

enum PermissionRecommendation: String, CaseIterable, Codable, Hashable {
    case allow = "Allow"
    case limited = "Allow Limited"
    case deny = "Deny"
    
    var color: Color {
        switch self {
        case .allow: return .green
        case .limited: return .orange
        case .deny: return .red
        }
    }
    
    var iconName: String {
        switch self {
        case .allow: return "checkmark.circle.fill"
        case .limited: return "exclamationmark.triangle.fill"
        case .deny: return "xmark.circle.fill"
        }
    }
}

enum PermissionDecision: String, CaseIterable {
    case allow = "Allow"
    case limited = "Allow Limited"
    case deny = "Deny"
    case skip = "Skip"
    
    var color: Color {
        switch self {
        case .allow: return .green
        case .limited: return .orange
        case .deny: return .red
        case .skip: return .gray
        }
    }
}

// MARK: - Privacy Policy Analysis

struct PrivacyPolicyAnalysis: Codable {
    let dataCollection: DataCollectionInfo
    let thirdPartySharing: ThirdPartySharingInfo
    let dataRetention: DataRetentionInfo
    let securityMeasures: SecurityMeasuresInfo
    let overallScore: Int // 0-100
    let recommendation: PolicyRecommendation
    let concerns: [String]
    let positives: [String]
}

struct DataCollectionInfo: Codable {
    let collectsPersonalData: Bool
    let dataTypes: [String]
    let purpose: String
    let consentRequired: Bool
}

struct ThirdPartySharingInfo: Codable {
    let sharesWithThirdParties: Bool
    let thirdParties: [String]
    let purpose: String
    let optOutAvailable: Bool
}

struct DataRetentionInfo: Codable {
    let retentionPeriod: String
    let deletionPolicy: String
    let userControl: Bool
}

struct SecurityMeasuresInfo: Codable {
    let encryption: Bool
    let securityStandards: [String]
    let breachNotification: Bool
}

enum PolicyRecommendation: String, CaseIterable, Codable {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    case concerning = "Concerning"
    
    var color: Color {
        switch self {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .orange
        case .poor: return .red
        case .concerning: return .purple
        }
    }
    
    var description: String {
        switch self {
        case .excellent: return "Strong privacy practices, minimal data collection"
        case .good: return "Good privacy practices with some concerns"
        case .fair: return "Moderate privacy practices, some risks"
        case .poor: return "Poor privacy practices, significant risks"
        case .concerning: return "Concerning privacy practices, high risks"
        }
    }
}
