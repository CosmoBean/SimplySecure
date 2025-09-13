#!/usr/bin/env swift

import Foundation

// Test FileVault command
print("🧪 Testing FileVault command...")
let fileVaultTask = Process()
fileVaultTask.executableURL = URL(fileURLWithPath: "/usr/bin/fdesetup")
fileVaultTask.arguments = ["status"]

let fileVaultPipe = Pipe()
let fileVaultErrorPipe = Pipe()
fileVaultTask.standardOutput = fileVaultPipe
fileVaultTask.standardError = fileVaultErrorPipe

do {
    try fileVaultTask.run()
    fileVaultTask.waitUntilExit()
    
    let data = fileVaultPipe.fileHandleForReading.readDataToEndOfFile()
    let errorData = fileVaultErrorPipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""
    let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
    
    print("🥷 FileVault - Output: '\(output)'")
    print("🥷 FileVault - Error: '\(errorOutput)'")
    print("🥷 FileVault - Exit code: \(fileVaultTask.terminationStatus)")
    print("🥷 FileVault - Contains 'FileVault is On': \(output.contains("FileVault is On"))")
    
    if output.contains("FileVault is On") {
        print("✅ FileVault: PASSED")
    } else {
        print("❌ FileVault: FAILED")
    }
} catch {
    print("❌ FileVault Error: \(error)")
}

print("\n" + String(repeating: "=", count: 50) + "\n")

// Test Firewall command
print("🧪 Testing Firewall command...")
let firewallTask = Process()
firewallTask.executableURL = URL(fileURLWithPath: "/usr/libexec/ApplicationFirewall/socketfilterfw")
firewallTask.arguments = ["--getglobalstate"]

let firewallPipe = Pipe()
let firewallErrorPipe = Pipe()
firewallTask.standardOutput = firewallPipe
firewallTask.standardError = firewallErrorPipe

do {
    try firewallTask.run()
    firewallTask.waitUntilExit()
    
    let data = firewallPipe.fileHandleForReading.readDataToEndOfFile()
    let errorData = firewallErrorPipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""
    let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
    
    print("🥷 Firewall - Output: '\(output)'")
    print("🥷 Firewall - Error: '\(errorOutput)'")
    print("🥷 Firewall - Exit code: \(firewallTask.terminationStatus)")
    print("🥷 Firewall - Contains 'enabled': \(output.contains("enabled"))")
    print("🥷 Firewall - Contains 'State = 1': \(output.contains("State = 1"))")
    
    if output.contains("enabled") || output.contains("State = 1") {
        print("✅ Firewall: PASSED")
    } else {
        print("❌ Firewall: FAILED")
    }
} catch {
    print("❌ Firewall Error: \(error)")
}
