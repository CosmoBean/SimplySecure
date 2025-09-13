#!/bin/bash

# Setup script for Retell AI API key configuration
# This script helps configure the Retell AI API key for phishing call simulation

echo "🔴 Setting up Retell AI API configuration..."

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Creating .env file..."
    touch .env
    echo "# Environment variables for SimplySecure" >> .env
    echo "" >> .env
fi

# Check if RETELL_API_KEY is already configured
if grep -q "RETELL_API_KEY=" .env; then
    echo "⚠️  RETELL_API_KEY already exists in .env file"
    echo "Current configuration:"
    grep "RETELL_API_KEY=" .env
    echo ""
    read -p "Do you want to update it? (y/n): " update_key
    if [ "$update_key" = "y" ] || [ "$update_key" = "Y" ]; then
        # Remove existing line
        sed -i '' '/RETELL_API_KEY=/d' .env
    else
        echo "Keeping existing configuration."
        exit 0
    fi
fi

echo "To get your Retell AI API key:"
echo "1. Visit: https://retellai.com"
echo "2. Sign up for an account"
echo "3. Navigate to API settings"
echo "4. Generate a new API key"
echo ""

# Prompt for API key
read -p "Enter your Retell AI API key: " retell_api_key

if [ -z "$retell_api_key" ]; then
    echo "❌ No API key provided. Exiting."
    exit 1
fi

# Add API key to .env file
echo "RETELL_API_KEY=$retell_api_key" >> .env

echo ""
echo "✅ Retell AI API key configured successfully!"
echo ""
echo "📝 Configuration added to .env file:"
echo "RETELL_API_KEY=$retell_api_key"
echo ""
echo "🔄 Please restart the SimplySecure app to load the new configuration."
echo ""
echo "🔴 You can now use the Phishing Call Simulation feature!"
echo "   - Navigate to the 'Phishing Sim' tab in the app"
echo "   - Enter phone numbers in E.164 format (e.g., +1234567890)"
echo "   - Click 'Start Phishing Call Simulation' to begin"
echo ""
echo "📋 The simulation will:"
echo "   1. Create an outbound call using Retell AI"
echo "   2. Wait for call completion"
echo "   3. Fetch and log the full transcription using NSLog"
echo ""
