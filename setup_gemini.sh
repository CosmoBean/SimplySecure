#!/bin/bash

# SimplySecure Gemini API Setup Script
# This script helps configure the Gemini API key for the SimplySecure app

echo "🔧 SimplySecure Gemini API Setup"
echo "================================="
echo ""

# Check if .env file exists
if [ -f ".env" ]; then
    echo "✅ .env file found"
    
    # Check if GEMINI_API_KEY is already configured in .env
    if grep -q "GEMINI_API_KEY=" .env && ! grep -q "GEMINI_API_KEY=your_gemini_api_key_here" .env; then
        echo "✅ GEMINI_API_KEY is already configured in .env file"
        echo ""
        echo "Current configuration:"
        grep "GEMINI_API_KEY=" .env | head -1
        echo ""
    else
        echo "❌ GEMINI_API_KEY needs to be configured in .env file"
        echo ""
        echo "To configure your API key:"
        echo "1. Edit the .env file"
        echo "2. Replace 'your_gemini_api_key_here' with your actual API key"
        echo "3. Save the file"
        echo ""
    fi
else
    echo "❌ .env file not found"
    echo ""
    echo "Creating .env file with Gemini API key template..."
    echo "# Gemini API Configuration" > .env
    echo "GEMINI_API_KEY=your_gemini_api_key_here" >> .env
    echo "" >> .env
    echo "# Example:" >> .env
    echo "# GEMINI_API_KEY=AIzaSyC..." >> .env
    echo ""
    echo "✅ .env file created! Please edit it and add your API key."
fi

echo "To get your Gemini API key:"
echo "1. Visit: https://makersuite.google.com/app/apikey"
echo "2. Sign in with your Google account"
echo "3. Create a new API key"
echo "4. Copy the API key"
echo "5. Edit the .env file and replace 'your_gemini_api_key_here' with your key"
echo ""

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
echo "   - The .env file is automatically ignored by git"
echo ""
