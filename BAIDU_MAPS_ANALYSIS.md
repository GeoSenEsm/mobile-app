# Baidu Maps Integration Analysis

## Current State
- **Map Library**: flutter_map (OpenStreetMap)
- **Current URL Template**: `https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png`
- **Coordinates System**: WGS-84 (latlong2)
- **Location**: `lib/presentation/screens/map/map_screen.dart`
- **Controller**: `MapScreenController`

## Requirements
- Replace OpenStreetMap with Baidu Maps
- Support both China and Europe
- Use ONLY Baidu Maps (no alternatives)

## Solution Architecture

### Key Considerations for Baidu Maps
1. **Coordinate System Difference**: Baidu Maps uses BD-09 (Baidu coordinates), while current app uses WGS-84
2. **API Key**: Required for Baidu Maps (need to add to build.gradle for Android and Info.plist for iOS)
3. **Works Globally**: Baidu Maps API works worldwide including Europe
4. **Tile URLs**: Baidu Maps tiles are accessed via specific URL templates

### Implementation Strategy

#### Option A: Baidu Maps Flutter Package
- Use `amap_flutter_map` or `baidu_flutter_map` package
- Requires platform-specific setup (Android & iOS keys)
- Better native performance

#### Option B: flutter_map with Baidu Tiles
- Keep flutter_map, use Baidu tile URL templates
- Works with WGS-84 coordinates but uses Baidu servers
- Simpler implementation

#### Chosen Approach: Option B
- Use `flutter_map` with Baidu tile layers
- Coordinate transformation: WGS-84 → BD-09 for display accuracy
- Leverages existing flutter_map setup

## Changes Required

### 1. Dependencies (pubspec.yaml)
- Add coordinate transformation package (if needed)
- Ensure flutter_map is latest

### 2. New Files
- `lib/domain/local_services/baidu_maps_service.dart` - Baidu Maps utility service

### 3. Modified Files
- `lib/presentation/controllers/map_screen_controller.dart` - Update map URL template
- `lib/presentation/screens/map/map_screen.dart` - No major UI changes needed
- `android/app/build.gradle` - Add Baidu API key
- `ios/Runner/Info.plist` - Add Baidu API key

## Baidu Maps URL Template
```
https://api{num}.map.bdimg.com/customimage/tile?x={x}&y={y}&z={z}&udt=20230101&scale=1
```

## Coordinate Transformation (WGS-84 to BD-09)
Baidu has specific algorithms for coordinate transformation. The service will handle this conversion.

## Implementation Steps
1. Create BaiduMapsService for coordinate conversion
2. Update MapScreenController with Baidu tile URL
3. Add necessary API keys to build files
4. Test in both regions

