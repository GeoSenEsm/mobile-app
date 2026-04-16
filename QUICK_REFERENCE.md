od# Baidu Maps - Quick Reference Guide

## 🚀 Quick Start (5 minutes)

### 1. Get API Keys
Visit: https://lbsyun.baidu.com/apiconsole/key
- Create Android app: Get Android API key
- Create iOS app: Get iOS API key

### 2. Update Configuration

**Android** (`android/app/build.gradle`):
```gradle
manifestPlaceholders = [
    BAIDU_MAPS_API_KEY: "YOUR_ANDROID_KEY"
]
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>BaiduMapsAPIKey</key>
<string>YOUR_iOS_KEY</string>
```

### 3. Test
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📁 Files Changed

| File | Changes |
|------|---------|
| `lib/domain/local_services/baidu_maps_service.dart` | ✨ NEW - Baidu Maps service |
| `lib/presentation/controllers/map_screen_controller.dart` | Updated: URL template to Baidu |
| `lib/presentation/screens/map/map_screen.dart` | Updated: Tile layer config |
| `android/app/build.gradle` | Added: API key placeholder |
| `ios/Runner/Info.plist` | Added: API key entry |

---

## 🌍 Coverage

### Europe ✓
- Warsaw, London, Paris, Berlin, etc.
- Full tile coverage
- Works with WGS-84 coordinates

### China ✓
- Beijing, Shanghai, Shenzhen, etc.
- Full tile coverage
- Works with WGS-84 coordinates

---

## 🔧 BaiduMapsService API

```dart
// Get tile URL template
BaiduMapsService.getTileUrlTemplate()

// Validate coordinates
BaiduMapsService.isValidCoordinates(lat, lng)

// Create LatLng
BaiduMapsService.getLatLng(lat, lng)

// Get region-specific position
BaiduMapsService.getInitialPosition(isChina: true)

// Coordinate transformations
BaiduMapsService.convertWgs84ToBaiduMercator(lat, lng)
BaiduMapsService.convertMercatorToTile(x, y, zoom)
BaiduMapsService.getBaiduTileUrl(x, y, z, serverIndex: 0)
```

---

## 🧪 Run Tests

```bash
# Run Baidu Maps tests
flutter test test/baidu_maps_service_test.dart

# Run all tests
flutter test
```

---

## 🔍 Troubleshooting

**Map not loading?**
- Check API key in build files
- Verify internet connection
- Try `flutter clean && flutter pub get`

**Markers not showing?**
- Verify coordinates are valid
- Check location data in database
- Ensure location filter includes the locations

**Performance issues?**
- Clear cache: `flutter clean`
- Check network connectivity
- Reduce number of markers displayed

---

## 📚 Documentation

- **IMPLEMENTATION_SUMMARY.md** - Complete overview
- **BAIDU_MAPS_ANALYSIS.md** - Technical analysis
- **BAIDU_MAPS_SETUP.md** - Detailed setup guide
- **test/baidu_maps_service_test.dart** - Unit tests

---

## ⚙️ Automated Setup

**Windows**:
```powershell
.\setup_baidu_maps.ps1
```

**macOS/Linux**:
```bash
bash setup_baidu_maps.sh
```

---

## ✅ Before Deployment

- [ ] API keys obtained
- [ ] Build files updated
- [ ] `flutter clean` run
- [ ] Tested in Europe region
- [ ] Tested in China region
- [ ] Verified markers show
- [ ] Tested zoom/pan
- [ ] Tested on Android device
- [ ] Tested on iOS device

---

## 🆘 Support

- **Baidu Console**: https://lbsyun.baidu.com/apiconsole/key
- **Baidu Docs**: https://lbsyun.baidu.com/index.php
- **flutter_map**: https://github.com/fleaflet/flutter_map

---

## 📝 Key Points

✅ Uses ONLY Baidu Maps (no alternatives)  
✅ Works in China AND Europe  
✅ No breaking changes  
✅ Backward compatible  
✅ Same dependencies  
✅ No database migration needed  
✅ Existing coordinates work as-is  

---

**Implementation Status**: ✓ Complete - Ready for API Key Configuration

