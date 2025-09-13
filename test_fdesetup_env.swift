#!/usr/bin/env swift

import Foundation

print("🔍 Testing fdesetup status with app-like environment...")
print("Current user: \(NSUserName())")
print("Current user ID: \(getuid())")

let task = Process()
task.executableURL = URL(fileURLWithPath: "/usr/bin/fdesetup")
task.arguments = ["status"]

let pipe = Pipe()
let errorPipe = Pipe()
task.standardOutput = pipe
task.standardError = errorPipe

do {
    try task.run()
    task.waitUntilExit()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""
    let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
    
    print("📤 Output: '\(output)'")
    print("📤 Error: '\(errorOutput)'")
    print("📤 Exit code: \(task.terminationStatus)")
    print("📤 Output length: \(output.count)")
    print("📤 Contains 'FileVault is On': \(output.contains("FileVault is On"))")
    print("📤 Contains 'FileVault is Off': \(output.contains("FileVault is Off"))")
    
} catch {
    print("❌ Error: \(error)")
}
