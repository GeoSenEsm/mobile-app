# 🚀 Baidu Maps Setup - 5 Minute Quick Start

## Step 1: Get Your Free API Keys (3 minutes)

### For Android:

1. Visit: **https://lbsyun.baidu.com/apiconsole/key**
2. Click **"Create New App"** (or sign in first if needed)
3. Fill in the form:
   - **App Name**: `UrbEaT Mobile` (or any name)
   - **App Type**: Select `Android Native App` (安卓原生应用)
   - **Package Name**: `urbeat.site.app`
   - **SHA1 Fingerprint**: Get this from command below ↓

**Get your SHA1 (run this in terminal):**
```bash
# macOS/Linux
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1

# Windows (PowerShell)
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android | findstr SHA1
```

Copy the SHA1 value (looks like: `AB:CD:EF:12:34:56...`)

4. Paste it in the Baidu form
5. Click **Submit**
6. **Copy your Android API Key** (save it somewhere)

### For iOS:

1. Go back to: **https://lbsyun.baidu.com/apiconsole/key**
2. Click **"Create New App"** again
3. Fill in the form:
   - **App Name**: `UrbEaT Mobile iOS` (or same name)
   - **App Type**: Select `iOS App` (iOS应用)
   - **Bundle ID**: `com.example.survey_frontend`
   
4. Click **Submit**
5. **Copy your iOS API Key** (save it somewhere)

**Done! You now have 2 API keys** ✓

---

## Step 2: Add Keys to Your App (2 minutes)

### Choose your method:

**Option A - Automated (easiest):**

**macOS/Linux:**
```bash
cd /Users/mawit/PycharmProjects/mobile-apps
bash setup_baidu_maps.sh
```
Then paste your API keys when prompted.

**Windows (PowerShell):**
```powershell
cd C:\Users\mawit\PycharmProjects\mobile-apps
.\setup_baidu_maps.ps1
```
Then paste your API keys when prompted.

---

**Option B - Manual:**

1. Open file: `android/app/build.gradle`
   - Find line 55: `BAIDU_MAPS_API_KEY: "YOUR_BAIDU_MAPS_API_KEY_HERE"`
   - Replace with your Android key
   - Example: `BAIDU_MAPS_API_KEY: "abc123XYZ789"`

2. Open file: `ios/Runner/Info.plist`
   - Find the line with `<string>YOUR_BAIDU_MAPS_API_KEY_HERE</string>`
   - Replace with your iOS key
   - Example: `<string>abc123XYZ789</string>`

3. Save both files

---

## Step 3: Test It (2 minutes)

```bash
cd /Users/mawit/PycharmProjects/mobile-apps

# Clean cache
flutter clean

# Get dependencies
flutter pub get

# Run on emulator or device
flutter run
```

**What to look for:**
- ✅ App launches
- ✅ Map loads (tiles visible)
- ✅ No blank/grey map
- ✅ Zoom works
- ✅ Pan works

---

## Done! 🎉

Your app now uses Baidu Maps and works in:
- ✅ China
- ✅ Europe
- ✅ Everywhere!

---

## If Tiles Don't Load

**Try these:**

1. Double-check your API keys (copy exactly, no spaces)
2. Make sure `flutter clean` was run
3. Check Baidu console: https://lbsyun.baidu.com/apiconsole/key
   - Click your app
   - Verify status is "Active"
4. Check internet connection
5. Restart the app

---

## Need Help?

- **Keys not working?** See: `BAIDU_MAPS_SETUP.md` (Troubleshooting section)
- **More info?** See: `QUICK_REFERENCE.md`
- **Full docs?** See: `README_BAIDU_INTEGRATION.md`

---

**Total time: ~5 minutes**

**Start here:** https://lbsyun.baidu.com/apiconsole/key

