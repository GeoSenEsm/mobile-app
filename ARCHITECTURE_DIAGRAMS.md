# Baidu Maps Architecture & Flow Diagrams

## 1. High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  Flutter Mobile App                         │
│                 (iOS & Android)                             │
└────────────────────────┬────────────────────────────────────┘
                         │
        ┌────────────────┴─────────────────┐
        │                                  │
   ┌────▼──────────┐           ┌──────────▼──────┐
   │  Android      │           │  iOS            │
   │  (ARMv8)      │           │  (ARM64)        │
   └────┬──────────┘           └────────┬────────┘
        │                               │
        │    ┌────────────────────┐     │
        └────│  Flutter Engine    │─────┘
             │  (Dart Runtime)    │
             └────────┬───────────┘
                      │
        ┌─────────────┴──────────────┐
        │                            │
   ┌────▼──────────────┐    ┌────────▼────────────┐
   │  MapScreenWidget  │    │  MapScreenController│
   │  (UI Layer)       │◄───│  (Logic Layer)      │
   └───────────────────┘    └─────────┬───────────┘
                                      │
                           ┌──────────▼──────────┐
                           │ BaiduMapsService    │
                           │ (Service Layer)     │
                           │ - Tile URLs         │
                           │ - Coordinates       │
                           │ - Validation        │
                           └──────────┬──────────┘
                                      │
                         ┌────────────┴────────────┐
                         │                        │
                    ┌────▼──────┐         ┌──────▼────┐
                    │ Baidu     │         │ Device    │
                    │ Tile      │         │ Storage   │
                    │ Servers   │         │ (Cache)   │
                    └───────────┘         └───────────┘
```

---

## 2. Data Flow: Displaying Locations on Map

```
LocationModel Database
     │
     │ SELECT locations WHERE date BETWEEN ? AND ?
     │
     ▼
MapScreenController.loadData()
     │
     ├─► Clear existing locations
     │
     ├─► Query DatabaseHelper.getAllLocationsBetween()
     │
     ▼
List<LocationModel> results
     │
     ├─► Calculate map bounds
     │
     ├─► BaiduMapsService.isValidCoordinates() ✓
     │
     ├─► Convert to LatLng points
     │   └─ LatLng(latitude, longitude)
     │
     ▼
Calculate LatLngBounds
     │
     ├─► bounds.center
     ├─► bounds.north, south, east, west
     │
     ▼
mapController.move(center, zoom)
     │
     ├─► Fetch Baidu tiles from CDN
     │   └─► API servers: api0/1/2.map.bdimg.com
     │
     ▼
MapScreen._buildMap()
     │
     ├─► TileLayer renders Baidu map
     │   └─► URL Template applied
     │       x={x}, y={y}, z={z}
     │
     ├─► MarkerLayer renders location markers
     │   └─► For each LocationModel:
     │       ├─ Position: LatLng(lat, lng)
     │       ├─ Color: Blue if sent, Red if pending
     │       └─ Size: 40x40 circular icon
     │
     ▼
User sees map with markers
```

---

## 3. Coordinate System Flow

```
GPS Device (WGS-84)
     │
     │ Latitude:  52.2297°N
     │ Longitude: 21.0122°E
     │
     ▼
LocationModel
     │ latitude:  52.2297
     │ longitude: 21.0122
     │
     ▼
Database Storage
     │ (No transformation)
     │
     ▼
MapScreenController
     │
     ├─► Create LatLng(52.2297, 21.0122)
     │
     ▼
flutter_map (FlutterMap widget)
     │
     ├─► Web Mercator Projection
     │   (Automatically applied)
     │
     │   PSEUDO CODE:
     │   lng_mercator = lng * 20037508.34 / 180
     │   lat_mercator = log(tan((90 + lat) * π / 360)) * 20037508.34 / π
     │
     ▼
Mercator Coordinates
     │ (Internal representation)
     │
     ▼
Tile Coordinates
     │ tile_x = (lng_mercator / 20037508.34 + 1) / 2 * 2^zoom
     │ tile_y = (1 - lat_mercator / 20037508.34) / 2 * 2^zoom
     │
     ▼
Baidu Tile Request
     │ GET /customimage/tile?
     │     x={tile_x}&y={tile_y}&z={zoom}
     │
     ▼
Baidu Maps Server
     │ (Automatically handles BD-09 internally)
     │
     ▼
Tile Image Downloaded
     │ (PNG format, 256x256 pixels)
     │
     ▼
Cached Locally
     │ (flutter_map cache)
     │
     ▼
Rendered on Screen
```

---

## 4. Tile Loading Architecture

```
FlutterMap - TileLayer Configuration
│
├─ urlTemplate: "https://api{num}.map.bdimg.com/..."
├─ tileSize: 256.0
├─ minZoom: 1.0
├─ maxZoom: 18.0
├─ maxNativeZoom: 18
│
▼
Visible Tile Calculation
│
├─ Current map center
├─ Current zoom level
├─ Screen size in pixels
│
▼
Determine Needed Tiles
│
├─ Calculate tile coordinates needed
│   Example at zoom 13:
│   ├─ Tile X: 4328
│   ├─ Tile Y: 2803
│   └─ ... more tiles for coverage
│
▼
BaiduMapsService.getBaiduTileUrl()
│
├─ Select server (api0, api1, or api2)
├─ Format URL: https://api{n}.map.bdimg.com/
│              customimage/tile?x={x}&y={y}&z={z}
├─ Examples:
│   ├─ https://api0.map.bdimg.com/customimage/tile?x=4328&y=2803&z=13
│   ├─ https://api1.map.bdimg.com/customimage/tile?x=4328&y=2804&z=13
│   └─ https://api2.map.bdimg.com/customimage/tile?x=4329&y=2803&z=13
│
▼
HTTP Request → Baidu CDN
│
├─ Connection optimization
├─ Automatic server selection
├─ Load balancing across api0/1/2
│
▼
PNG Tile Response (256x256)
│
▼
Local Cache Storage
│
├─ Path: ${app_temp_dir}/tiles/
├─ Cache size: Configurable
├─ TTL: Configurable
│
▼
Render to Screen
```

---

## 5. Region Detection Flow (Future Enhancement)

```
Device Location
     │
     ▼
Geolocator.getCurrentPosition()
     │
     ▼
Latitude, Longitude
     │
     ├─ If longitude < 115° (approx):
     │  └─► Europe / Americas region
     │      └─► Optional: Switch to OSM
     │
     ├─ Else if longitude > 115°:
     │  └─► Asia / China region
     │      └─► Use Baidu Maps (optimized)
     │
     ▼
Current Implementation:
Uses Baidu Maps for ALL regions
(Works globally, optimized for both regions)
```

---

## 6. Database Schema (No Changes)

```
locations_table
┌──────────────────┬───────────┐
│ Column           │ Type      │
├──────────────────┼───────────┤
│ id               │ INTEGER   │ PRIMARY KEY
│ survey_id        │ TEXT      │ Foreign Key
│ latitude         │ REAL      │ WGS-84
│ longitude        │ REAL      │ WGS-84
│ dateTime         │ INTEGER   │ Timestamp
│ sentToServer     │ BOOLEAN   │
│ accuracyMeters   │ REAL      │
│ relatedToSurvey  │ BOOLEAN   │
└──────────────────┴───────────┘

Migration: NONE REQUIRED ✓
(Existing schema fully compatible)
```

---

## 7. Request/Response Flow: Single Marker

```
User taps marker on map
     │
     ▼
_getMarkerForLocation(LocationModel)
     │
     ├─ marker.point = LatLng(latitude, longitude)
     │
     ├─ marker.child = GestureDetector
     │  └─ Icon(Icons.circle)
     │     ├─ Color: Blue if sentToServer
     │     └─ Color: Red if !sentToServer
     │
     ▼
GestureDetector.onTap()
     │
     ▼
controller.openDetails(LocationModel)
     │
     ├─ Get.to(LocationDetailsScreen)
     │
     ▼
LocationDetailsScreen displays:
     ├─ Latitude (read-only)
     ├─ Longitude (read-only)
     ├─ Date
     ├─ Time
     ├─ Submission Status (Icon)
     └─ Survey Relationship (if any)

NO CHANGES required in this flow ✓
(Marker interaction unchanged)
```

---

## 8. Error Handling Flow

```
BaiduMapsService Operation
     │
     ├─► Coordinate Validation
     │   │
     │   ├─ isValidCoordinates(lat, lng)?
     │   │
     │   ├─ YES ─► Continue
     │   │
     │   └─ NO ──► ArgumentError
     │             └─► Catch in controller
     │
     ├─► Create LatLng
     │   │
     │   ├─ Valid? ─► Success
     │   │
     │   └─ Invalid? ─► Exception
     │                 └─► Sentry.captureException()
     │
     ▼
MapScreenController.loadData()
     │
     ├─ try/catch block
     │
     ├─ Error caught? ─► Log to Sentry
     │
     └─► Gracefully handled
         └─► Map shows default center
             (Warsaw, Poland)
```

---

## 9. Deployment Flow

```
Development
     │
     ├─ Baidu Maps API keys configured
     │  ├─ Android: build.gradle
     │  └─ iOS: Info.plist
     │
     ▼
Testing
     │
     ├─ flutter clean
     ├─ flutter pub get
     ├─ flutter test
     │
     ├─ Manual testing:
     │  ├─ Europe (Warsaw, London, Paris)
     │  └─ China (Beijing, Shanghai)
     │
     ▼
Build Artifact
     │
     ├─ flutter build android
     │  └─ APK with Baidu Maps configured
     │
     ├─ flutter build ios
     │  └─ IPA with Baidu Maps configured
     │
     ▼
Release
     │
     ├─ Google Play Store
     │  └─ APK uploaded with keys
     │
     ├─ Apple App Store
     │  └─ IPA uploaded with keys
     │
     ▼
User Installation
     │
     ├─ App downloaded
     ├─ Baidu Maps tiles loaded
     ├─ Works in Europe ✓
     ├─ Works in China ✓
     │
     ▼
Production Running ✓
```

---

## 10. Performance Optimization Strategy

```
User opens map
     │
     ├─► Screen size detected
     │   └─ Calculate visible area in tiles
     │
     ├─► Request only visible tiles
     │   ├─ Avoid over-fetching
     │   └─ Tile pyramid: api0 → api1 → api2
     │
     ├─► Parallel tile requests
     │   └─ Multiple tiles loaded simultaneously
     │
     ├─► Cache management
     │   ├─ In-memory cache (fast)
     │   ├─ Disk cache (persistent)
     │   └─ LRU eviction policy
     │
     ├─► User pans/zooms
     │   └─ Incremental tile loading
     │       (Only new tiles fetched)
     │
     └─► Smooth 60 FPS rendering
```

---

## Document References

- **IMPLEMENTATION_SUMMARY.md** - Complete project overview
- **BAIDU_MAPS_SETUP.md** - Detailed setup instructions
- **BAIDU_MAPS_ANALYSIS.md** - Technical analysis
- **QUICK_REFERENCE.md** - Quick start guide

---

**Last Updated**: April 2026
**Status**: Implementation Complete ✓

