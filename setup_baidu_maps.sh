#!/bin/bash
# Baidu Maps Configuration Setup Script
# This script helps you configure Baidu Maps API keys for your app

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}================================================${NC}"
echo -e "${YELLOW}Baidu Maps Configuration Setup${NC}"
echo -e "${YELLOW}================================================${NC}\n"

# Function to prompt for input
prompt_for_key() {
    local prompt_text=$1
    local default_value=$2
    local input_value=""

    read -p "$prompt_text (default: $default_value): " input_value

    if [ -z "$input_value" ]; then
        echo "$default_value"
    else
        echo "$input_value"
    fi
}

# Get API keys
echo -e "${GREEN}Step 1: Get your Baidu Maps API Keys${NC}"
echo "Visit: https://lbsyun.baidu.com/apiconsole/key"
echo ""

ANDROID_API_KEY=$(prompt_for_key "Enter your Android API Key" "YOUR_ANDROID_KEY_HERE")
iOS_API_KEY=$(prompt_for_key "Enter your iOS API Key" "YOUR_iOS_KEY_HERE")

echo ""
echo -e "${GREEN}Step 2: Updating configuration files${NC}\n"

# Update Android configuration
echo -e "${YELLOW}Updating android/app/build.gradle...${NC}"

ANDROID_BUILD_FILE="android/app/build.gradle"

if [ -f "$ANDROID_BUILD_FILE" ]; then
    # Create backup
    cp "$ANDROID_BUILD_FILE" "$ANDROID_BUILD_FILE.backup"

    # Replace the API key
    sed -i "" "s/BAIDU_MAPS_API_KEY: \"[^\"]*\"/BAIDU_MAPS_API_KEY: \"$ANDROID_API_KEY\"/g" "$ANDROID_BUILD_FILE"

    echo -e "${GREEN}✓ Android configuration updated${NC}"
else
    echo -e "${RED}✗ Android build file not found${NC}"
fi

# Update iOS configuration
echo -e "${YELLOW}Updating ios/Runner/Info.plist...${NC}"

iOS_PLIST_FILE="ios/Runner/Info.plist"

if [ -f "$iOS_PLIST_FILE" ]; then
    # Create backup
    cp "$iOS_PLIST_FILE" "$iOS_PLIST_FILE.backup"

    # Replace the API key
    sed -i "" "s/<string>YOUR_BAIDU_MAPS_API_KEY_HERE<\/string>/<string>$iOS_API_KEY<\/string>/g" "$iOS_PLIST_FILE"

    echo -e "${GREEN}✓ iOS configuration updated${NC}"
else
    echo -e "${RED}✗ iOS plist file not found${NC}"
fi

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}Configuration Complete!${NC}"
echo -e "${GREEN}================================================${NC}\n"

echo "Next steps:"
echo "1. Clean Flutter cache: flutter clean"
echo "2. Get dependencies: flutter pub get"
echo "3. Test the app: flutter run"
echo ""
echo "For more information, see BAIDU_MAPS_SETUP.md"

