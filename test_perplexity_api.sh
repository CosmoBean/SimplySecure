#!/bin/bash

echo "🧪 Testing Perplexity API Configuration"
echo "======================================"
echo ""

# Check if API key is set
if [ -z "$PERPLEXITY_API_KEY" ]; then
    echo "❌ PERPLEXITY_API_KEY environment variable is not set"
    echo ""
    echo "Please set it using one of these methods:"
    echo "1. export PERPLEXITY_API_KEY=\"your_api_key_here\""
    echo "2. Run ./setup_perplexity.sh"
    echo "3. Add it to your ~/.zshrc or ~/.bash_profile"
    exit 1
fi

echo "✅ PERPLEXITY_API_KEY is set"
echo "🔑 API Key: ${PERPLEXITY_API_KEY:0:8}..."
echo "📏 API Key Length: ${#PERPLEXITY_API_KEY} characters"
echo ""

# Test the API with a simple request
echo "🧪 Testing API with a simple request..."
echo ""

curl -X POST "https://api.perplexity.ai/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
  -d '{
    "model": "sonar",
    "messages": [
      {
        "role": "user",
        "content": "What is the capital of France?"
      }
    ],
    "max_tokens": 100,
    "temperature": 0.1
  }' \
  --silent --show-error --write-out "HTTP Status: %{http_code}\n" \
  --output /tmp/perplexity_test_response.json

echo ""
echo "📄 Response saved to: /tmp/perplexity_test_response.json"
echo ""

# Check the response
if [ -f "/tmp/perplexity_test_response.json" ]; then
    echo "📋 Response content:"
    cat /tmp/perplexity_test_response.json | python3 -m json.tool 2>/dev/null || cat /tmp/perplexity_test_response.json
    echo ""
fi

echo "🔍 Next steps:"
echo "1. If you see HTTP Status: 200, your API key is working!"
echo "2. If you see HTTP Status: 401, check your API key"
echo "3. Run SimplySecure and watch the console logs for detailed debugging"
