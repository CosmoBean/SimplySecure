#!/bin/bash

# SimplySecure Gemini API Setup Script
# This script helps configure the Gemini API key for the SimplySecure app

echo "🔧 SimplySecure Gemini API Setup"
echo "================================="
echo ""

# Check if API key is already set
if [ ! -z "$GEMINI_API_KEY" ]; then
    echo "✅ GEMINI_API_KEY is already set in your environment"
    echo "   Current key: ${GEMINI_API_KEY:0:10}..."
    echo ""
    echo "To update your API key, run:"
    echo "export GEMINI_API_KEY='your_new_api_key_here'"
    echo ""
else
    echo "❌ GEMINI_API_KEY is not set"
    echo ""
    echo "To get your Gemini API key:"
    echo "1. Visit: https://makersuite.google.com/app/apikey"
    echo "2. Sign in with your Google account"
    echo "3. Create a new API key"
    echo "4. Copy the API key"
    echo ""
    echo "To set your API key, run:"
    echo "export GEMINI_API_KEY='your_api_key_here'"
    echo ""
    echo "To make it permanent, add the above line to your ~/.zshrc or ~/.bash_profile"
    echo ""
fi

echo "🚀 Once configured, you can:"
echo "   - Run the SimplySecure app"
echo "   - Navigate to the 'AI Assistant' tab"
echo "   - Test the Gemini API integration"
echo ""

# Check if we're in the project directory
if [ -f "SimplySecure.xcodeproj/project.pbxproj" ]; then
    echo "📱 Project detected! You can now build and run the app."
    echo ""
    echo "To build and run:"
    echo "   xcodebuild -project SimplySecure.xcodeproj -scheme SimplySecure -configuration Debug"
    echo "   # or open in Xcode and run normally"
else
    echo "⚠️  Please run this script from the SimplySecure project directory"
fi

echo ""
echo "🔐 Security Note:"
echo "   - Never commit your API key to version control"
echo "   - Keep your API key secure and don't share it"
echo "   - Consider using environment variables or secure key storage"
echo ""
