#!/bin/bash

# SimplySecure Build Script
# This script helps set up and build the SimplySecure macOS app

echo "🥷 SimplySecure - macOS Security Scanner Setup"
echo "=============================================="

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script only works on macOS"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed. Please install Xcode from the App Store."
    exit 1
fi

echo "✅ macOS detected"
echo "✅ Xcode found"

# Check macOS version
macos_version=$(sw_vers -productVersion)
echo "📱 macOS Version: $macos_version"

# Check if macOS version is 13.0 or later
if [[ $(echo "$macos_version" | cut -d. -f1) -ge 13 ]]; then
    echo "✅ macOS version is compatible (13.0+)"
else
    echo "⚠️  Warning: macOS version may not be compatible. App requires macOS 13.0+"
fi

echo ""
echo "🔧 Project Structure:"
echo "├── SimplySecure/"
echo "│   ├── SimplySecureApp.swift      # Main app entry point"
echo "│   ├── ContentView.swift          # Main UI with dashboard"
echo "│   ├── SecurityScanner.swift      # Security scan logic"
echo "│   ├── NinjaGameModel.swift       # Gamification system"
echo "│   ├── Assets.xcassets           # App icons and assets"
echo "│   ├── Info.plist                # App configuration"
echo "│   └── SimplySecure.entitlements  # App permissions"
echo "├── SimplySecure.xcodeproj        # Xcode project file"
echo "└── README.md                     # Documentation"

echo ""
echo "🚀 To build and run:"
echo "1. Open SimplySecure.xcodeproj in Xcode"
echo "2. Select your Mac as the target device"
echo "3. Press Cmd+R to build and run"
echo ""
echo "📋 Features:"
echo "• Security scanning (OS updates, FileVault, Safari)"
echo "• Ninja-themed gamification with XP and levels"
echo "• Real-time security score (0-100)"
echo "• Actionable fix instructions"
echo "• Dark/light mode support"
echo "• Phishing call simulation with Retell AI"
echo "• AI-powered security insights with Gemini"
echo ""
echo "🎯 Perfect for HackCMU 2025 demo!"

# Try to open Xcode if the project file exists
if [ -f "SimplySecure.xcodeproj/project.pbxproj" ]; then
    echo ""
    read -p "Would you like to open the project in Xcode now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🔨 Opening SimplySecure.xcodeproj in Xcode..."
        open SimplySecure.xcodeproj
    fi
else
    echo "⚠️  Project file not found. Make sure you're in the correct directory."
fi

echo ""
echo "🔧 Optional API Setup:"
echo "• Run './setup_gemini.sh' to configure Gemini AI API"
echo "• Run './setup_retell.sh' to configure Retell AI API for phishing simulation"
echo "• Run './setup_perplexity.sh' to configure Perplexity API"
echo ""
echo "🥷 Ready to secure your Mac like a ninja!"
