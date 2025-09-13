#!/bin/bash

# SimplySecure - Perplexity API Setup Script
# This script helps you configure your Perplexity API key for real privacy policy analysis

echo "🔍 SimplySecure - Perplexity API Setup"
echo "======================================"
echo ""

# Check if .env file exists
if [ -f ".env" ]; then
    echo "📄 Found existing .env file"
    if grep -q "PERPLEXITY_API_KEY" .env; then
        echo "⚠️  PERPLEXITY_API_KEY already exists in .env file"
        echo "Current value: $(grep PERPLEXITY_API_KEY .env | cut -d'=' -f2)"
        echo ""
        read -p "Do you want to update it? (y/n): " update_key
        if [ "$update_key" = "y" ] || [ "$update_key" = "Y" ]; then
            # Remove existing line
            sed -i '' '/PERPLEXITY_API_KEY/d' .env
        else
            echo "✅ Keeping existing Perplexity API key"
            exit 0
        fi
    fi
else
    echo "📄 Creating new .env file"
    touch .env
fi

echo ""
echo "🔑 Please enter your Perplexity API key:"
echo "   (Get it from: https://www.perplexity.ai/settings/api)"
echo ""
read -p "Perplexity API Key: " perplexity_key

if [ -z "$perplexity_key" ]; then
    echo "❌ No API key provided. Exiting."
    exit 1
fi

# Add the API key to .env file
echo "PERPLEXITY_API_KEY=$perplexity_key" >> .env

# Also export it for the current session
export PERPLEXITY_API_KEY="$perplexity_key"

echo ""
echo "✅ Perplexity API key added to .env file"
echo "✅ Environment variable set for current session"
echo ""
echo "🚀 What this enables:"
echo "   • Real-time privacy policy URL discovery"
echo "   • AI-powered privacy analysis of apps"
echo "   • Intelligent permission recommendations"
echo "   • App store metadata lookup"
echo ""
echo "📱 Next steps:"
echo "   1. Restart SimplySecure to load the new API key"
echo "   2. Install a new app to see real privacy analysis in action"
echo "   3. Check the console logs for detailed analysis results"
echo ""
echo "🔧 To set the environment variable permanently:"
echo "   Add this line to your ~/.zshrc or ~/.bash_profile:"
echo "   export PERPLEXITY_API_KEY=\"$perplexity_key\""
echo ""
echo "   Then run: source ~/.zshrc (or restart your terminal)"
echo ""
echo "🔍 Test the integration:"
echo "   • Try installing a popular app like Instagram, TikTok, or WhatsApp"
echo "   • Watch the permission overlay show real privacy insights"
echo "   • See AI-generated recommendations based on actual privacy policies"
echo ""
echo "✨ Enjoy enhanced privacy protection with AI-powered insights!"
