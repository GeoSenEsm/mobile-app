# Baidu Maps Configuration Setup Script for Windows
# This script helps you configure Baidu Maps API keys for your app

Write-Host "================================================" -ForegroundColor Yellow
Write-Host "Baidu Maps Configuration Setup" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Yellow
Write-Host ""

# Function to prompt for input with default
function Prompt-ForKey {
    param(
        [string]$PromptText,
        [string]$DefaultValue
    )

    $input = Read-Host "$PromptText (default: $DefaultValue)"

    if ([string]::IsNullOrWhiteSpace($input)) {
        return $DefaultValue
    }
    return $input
}

# Get API keys
Write-Host "Step 1: Get your Baidu Maps API Keys" -ForegroundColor Green
Write-Host "Visit: https://lbsyun.baidu.com/apiconsole/key"
Write-Host ""

$AndroidApiKey = Prompt-ForKey "Enter your Android API Key" "YOUR_ANDROID_KEY_HERE"
$iOsApiKey = Prompt-ForKey "Enter your iOS API Key" "YOUR_iOS_KEY_HERE"

Write-Host ""
Write-Host "Step 2: Updating configuration files" -ForegroundColor Green
Write-Host ""

# Update Android configuration
Write-Host "Updating android/app/build.gradle..." -ForegroundColor Yellow

$AndroidBuildFile = "android/app/build.gradle"

if (Test-Path $AndroidBuildFile) {
    # Create backup
    Copy-Item $AndroidBuildFile "$AndroidBuildFile.backup"

    # Read the file
    $content = Get-Content $AndroidBuildFile -Raw

    # Replace the API key using regex
    $content = $content -replace 'BAIDU_MAPS_API_KEY: "[^"]*"', "BAIDU_MAPS_API_KEY: `"$AndroidApiKey`""

    # Write back
    Set-Content $AndroidBuildFile $content -Encoding UTF8

    Write-Host "✓ Android configuration updated" -ForegroundColor Green
}
else {
    Write-Host "✗ Android build file not found" -ForegroundColor Red
}

# Update iOS configuration
Write-Host "Updating ios/Runner/Info.plist..." -ForegroundColor Yellow

$iOsPlistFile = "ios/Runner/Info.plist"

if (Test-Path $iOsPlistFile) {
    # Create backup
    Copy-Item $iOsPlistFile "$iOsPlistFile.backup"

    # Read the file
    $content = Get-Content $iOsPlistFile -Raw

    # Replace the API key
    $content = $content -replace '<string>YOUR_BAIDU_MAPS_API_KEY_HERE</string>', "<string>$iOsApiKey</string>"

    # Write back
    Set-Content $iOsPlistFile $content -Encoding UTF8

    Write-Host "✓ iOS configuration updated" -ForegroundColor Green
}
else {
    Write-Host "✗ iOS plist file not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "Configuration Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Clean Flutter cache: flutter clean"
Write-Host "2. Get dependencies: flutter pub get"
Write-Host "3. Test the app: flutter run"
Write-Host ""
Write-Host "For more information, see BAIDU_MAPS_SETUP.md"

