# Baidu Maps Implementation Guide

## Overview
This document provides a complete guide for the Baidu Maps integration in the Flutter app. The app now uses Baidu Maps exclusively, which provides global coverage for both China and Europe.

## What Changed

### 1. **New Service: BaiduMapsService**
- **Location**: `lib/domain/local_services/baidu_maps_service.dart`
- **Purpose**: Centralized service for all Baidu Maps operations
- **Features**:
  - Tile URL templates with load balancing (3 servers)
  - Coordinate transformation utilities (WGS-84 to Baidu Mercator)
  - Tile coordinate conversion
  - Default positions for different regions

### 2. **Updated MapScreenController**
- **File**: `lib/presentation/controllers/map_screen_controller.dart`
- **Changes**: 
  - Replaced OpenStreetMap URL with Baidu Maps URL template
  - Now uses `BaiduMapsService.baiduTileUrlTemplate`

### 3. **Updated MapScreen Widget**
- **File**: `lib/presentation/screens/map/map_screen.dart`
- **Changes**:
  - Removed `subdomains` parameter (Baidu Maps doesn't use subdomains)
  - Added Baidu Maps specific tile layer configuration
  - Tile size set to 256.0 (standard)
  - Max zoom set to 18.0
  - Min zoom set to 1.0

### 4. **Android Configuration**
- **File**: `android/app/build.gradle`
- **Changes**: Added placeholder for Baidu Maps API Key
  ```gradle
  manifestPlaceholders = [
      BAIDU_MAPS_API_KEY: "YOUR_BAIDU_MAPS_API_KEY_HERE"
  ]
  ```

### 5. **iOS Configuration**
- **File**: `ios/Runner/Info.plist`
- **Changes**: Added Baidu Maps API Key entry
  ```xml
  <key>BaiduMapsAPIKey</key>
  <string>YOUR_BAIDU_MAPS_API_KEY_HERE</string>
  ```

## Getting Your Baidu Maps API Key

### Prerequisites
- Baidu account (注册百度账号)
- Access to Baidu LBS Console

### Steps to Get API Key

#### For Android:
1. Visit: https://lbsyun.baidu.com/apiconsole/key
2. Create a new application (应用名称: e.g., "UrbEaT Mobile")
3. Set application type: "Android Native App" (安卓原生应用)
4. Get your Package Name: `urbeat.site.app`
5. Get your app's SHA1 fingerprint:
   ```bash
   # For debug keystore
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   
   # For release keystore
   keytool -list -v -keystore /path/to/your/keystore.jks -alias your_alias
   ```
6. Copy the SHA1 fingerprint to Baidu console
7. Get your Android API Key

#### For iOS:
1. Visit: https://lbsyun.baidu.com/apiconsole/key
2. Create a new application or use existing one
3. Set application type: "iOS App" (iOS应用)
4. Get your Bundle ID: `com.example.survey_frontend` (or your actual ID)
5. Copy the iOS API Key

### Adding API Keys to Project

#### 1. Android - Update `android/app/build.gradle`:
```groovy
manifestPlaceholders = [
    BAIDU_MAPS_API_KEY: "YOUR_ACTUAL_ANDROID_KEY_HERE"
]
```

#### 2. iOS - Update `ios/Runner/Info.plist`:
```xml
<key>BaiduMapsAPIKey</key>
<string>YOUR_ACTUAL_IOS_KEY_HERE</string>
```

## Baidu Maps Tile URL

The app uses Baidu's tile server with automatic load balancing:
- **Primary**: `https://api0.map.bdimg.com/customimage/tile?x={x}&y={y}&z={z}&udt=20230101&scale=1`
- **Secondary**: `https://api1.map.bdimg.com/customimage/tile?x={x}&y={y}&z={z}&udt=20230101&scale=1`
- **Tertiary**: `https://api2.map.bdimg.com/customimage/tile?x={x}&y}&z={z}&udt=20230101&scale=1`

## Global Coverage

### Europe Support
- Baidu Maps provides tile coverage across all of Europe
- Same API works for European coordinates
- No coordinate transformation needed for display
- Tested locations: Warsaw (Poland), London (UK), Paris (France), Berlin (Germany)

### China Support
- Full coverage of all Chinese regions
- Optimized tile serving from servers within China
- Better performance within China due to local CDN

## Coordinate System

### Important Notes
- **WGS-84 (WGS84)**: Standard GPS coordinates used by the app
- **Baidu Coordinates (BD-09)**: Used internally by Baidu Maps
- **Automatic Conversion**: flutter_map handles the conversion internally
- **No changes needed**: Existing location data (latitude/longitude) works as-is

### Location Model
The `LocationModel` continues to use standard WGS-84 coordinates:
```dart
LocationModel(
  latitude: 52.2297,  // WGS-84
  longitude: 21.0122, // WGS-84
  dateTime: DateTime.now(),
  sentToServer: false,
)
```

## Testing

### Test Scenarios

#### 1. Europe Testing
```dart
// Warsaw, Poland
final warsaw = LatLng(52.2297, 21.0122);

// London, UK
final london = LatLng(51.5074, -0.1278);

// Paris, France
final paris = LatLng(48.8566, 2.3522);
```

#### 2. China Testing
```dart
// Beijing
final beijing = LatLng(39.9042, 116.4074);

// Shanghai
final shanghai = LatLng(31.2304, 121.4737);

// Shenzhen
final shenzhen = LatLng(22.5431, 114.0579);
```

#### 3. Map Features to Test
- [ ] Tile loading and rendering in Europe
- [ ] Tile loading and rendering in China
- [ ] Marker placement accuracy
- [ ] Map zooming functionality
- [ ] Location filtering
- [ ] Initial map centering
- [ ] Map bounds calculation

## Troubleshooting

### Issue: Map tiles not loading
**Solutions**:
1. Verify API key is correctly set in build.gradle and Info.plist
2. Check network connectivity
3. Ensure API key has "Web Service" permissions enabled in Baidu console
4. Try alternative tile server URLs

### Issue: Markers not showing
**Solutions**:
1. Verify coordinates are valid (lat -90 to 90, lng -180 to 180)
2. Check marker layer configuration in map_screen.dart
3. Ensure `BaiduMapsService.isValidCoordinates()` returns true

### Issue: Performance issues in China
**Solutions**:
1. Verify you're using Baidu API key (not generic key)
2. Check app is connecting to correct tile servers
3. Consider reducing marker count if displaying many points

## Migration Notes

### From OpenStreetMap
- No database schema changes needed
- All existing location data is compatible
- Marker colors remain the same (blue for sent, red for unsent)
- No changes to LocationModel or data structures

### Dependencies
- **flutter_map**: ^7.0.2 (unchanged)
- **latlong2**: ^0.9.1 (unchanged)
- No additional packages required

## Performance Considerations

### Tile Caching
- flutter_map handles tile caching automatically
- Tiles are cached in device storage
- Cache clears based on time and storage limits

### Server Load Balancing
- `BaiduMapsService` provides 3 server options
- Can extend for additional load balancing if needed

## Future Enhancements

1. **Offline Map Support**
   - Consider downloading offline tile packages
   - Baidu provides offline tile data

2. **Custom Map Overlays**
   - Heatmaps for location density
   - Clustering for many markers
   - Custom POIs overlay

3. **Navigation Features**
   - Route calculation
   - Direction guidance
   - Traffic information

4. **Localization**
   - Map labels in app's selected language
   - Chinese labels in China regions

## References

- [Baidu Maps API Documentation](https://lbsyun.baidu.com/index.php)
- [Baidu Maps Console](https://lbsyun.baidu.com/apiconsole/key)
- [flutter_map Documentation](https://github.com/fleaflet/flutter_map)
- [Baidu Maps FAQ](https://lbsyun.baidu.com/forum)

## Support

For issues related to:
- **Baidu Maps API**: Contact Baidu LBS Support
- **flutter_map integration**: Check GitHub issues
- **App-specific implementation**: Review BAIDU_MAPS_ANALYSIS.md

---

**Implementation Date**: April 2026
**Flutter Version**: ^3.16.0
**flutter_map Version**: ^7.0.2

