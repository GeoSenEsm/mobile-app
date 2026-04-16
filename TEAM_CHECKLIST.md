# Baidu Maps Implementation - Team Checklist

## Phase 1: Setup & Configuration

### Getting API Keys
- [ ] Visit Baidu LBS Console: https://lbsyun.baidu.com/apiconsole/key
- [ ] Sign in to Baidu account
- [ ] Create "Android Native App"
  - [ ] App name: UrbEaT Mobile
  - [ ] Package: urbeat.site.app
  - [ ] Get SHA1 fingerprint
  - [ ] Copy Android API key to secure location
- [ ] Create "iOS App"
  - [ ] App name: UrbEaT Mobile
  - [ ] Bundle ID: com.example.survey_frontend
  - [ ] Copy iOS API key to secure location

### Configuring API Keys
**Choose ONE method:**

#### Method 1: Automated Setup (Easiest)
- [ ] Windows: Run `.\setup_baidu_maps.ps1`
- [ ] macOS/Linux: Run `bash setup_baidu_maps.sh`
- [ ] Follow prompts, enter API keys
- [ ] Verify files were updated

#### Method 2: Manual Setup
- [ ] Open `android/app/build.gradle`
  - [ ] Find line with `BAIDU_MAPS_API_KEY: "YOUR_BAIDU_MAPS_API_KEY_HERE"`
  - [ ] Replace with actual Android API key
  - [ ] Verify format: `BAIDU_MAPS_API_KEY: "your_key_here"`
- [ ] Open `ios/Runner/Info.plist`
  - [ ] Find line with `<string>YOUR_BAIDU_MAPS_API_KEY_HERE</string>`
  - [ ] Replace with actual iOS API key
  - [ ] Verify format: `<string>your_key_here</string>`
- [ ] Save both files

### Verification
- [ ] `android/app/build.gradle` line 55 has Android key
- [ ] `ios/Runner/Info.plist` line 41 has iOS key
- [ ] Keys are not placeholders anymore
- [ ] Keys are valid format (not empty)

---

## Phase 2: Testing & Validation

### Initial Setup
- [ ] `flutter clean` (removes cache)
- [ ] `flutter pub get` (gets dependencies)
- [ ] No build errors appear

### Unit Tests
- [ ] Run: `flutter test test/baidu_maps_service_test.dart`
- [ ] All tests pass
- [ ] No errors in console

### Android Device Testing
- [ ] Connect Android device (API 24+)
- [ ] Run: `flutter run`
- [ ] App launches successfully
- [ ] Map screen opens
- [ ] Tiles load (not blank/grey)
- [ ] Markers display
- [ ] Zoom in/out works
- [ ] Panning works
- [ ] No crashes

### iOS Device Testing
- [ ] Connect iOS device (11.0+)
- [ ] Run: `flutter run -d ios`
- [ ] App launches successfully
- [ ] Map screen opens
- [ ] Tiles load (not blank/grey)
- [ ] Markers display
- [ ] Zoom in/out works
- [ ] Panning works
- [ ] No crashes

### Europe Region Testing
- [ ] Open app with Warsaw location (52.2297, 21.0122)
- [ ] Tiles render correctly
- [ ] Marker displays on map
- [ ] Zoom levels show proper tiles
- [ ] Test other European cities:
  - [ ] London (51.5074, -0.1278)
  - [ ] Paris (48.8566, 2.3522)
  - [ ] Berlin (52.5200, 13.4050)

### China Region Testing
- [ ] Open app with Beijing location (39.9042, 116.4074)
- [ ] Tiles render correctly
- [ ] Marker displays on map
- [ ] Zoom levels show proper tiles
- [ ] Test other Chinese cities:
  - [ ] Shanghai (31.2304, 121.4737)
  - [ ] Shenzhen (22.5431, 114.0579)
  - [ ] Chengdu (30.5728, 104.0668)

### Feature Testing
- [ ] Location filtering works correctly
- [ ] Date range filtering works
- [ ] Marker colors correct (Blue = sent, Red = unsent)
- [ ] Clicking marker opens details
- [ ] Details screen shows correct data
- [ ] Map bounds calculate correctly
- [ ] Multiple markers display correctly

### Performance Testing
- [ ] App doesn't lag during panning
- [ ] Zooming is smooth
- [ ] Tiles load within reasonable time
- [ ] Memory usage acceptable
- [ ] No memory leaks during extended use

### Network Testing
- [ ] Test on WiFi connection
- [ ] Test on cellular connection
- [ ] Test with slow network (throttling)
- [ ] Test with weak network
- [ ] Graceful handling of network loss

---

## Phase 3: Code Review

### Code Quality
- [ ] Review `lib/domain/local_services/baidu_maps_service.dart`
  - [ ] Code is well-documented
  - [ ] Functions have clear purposes
  - [ ] Error handling is present
  - [ ] Type safety is maintained
  
- [ ] Review `lib/presentation/controllers/map_screen_controller.dart`
  - [ ] Import added correctly
  - [ ] URL template points to Baidu
  - [ ] No other changes affect functionality
  
- [ ] Review `lib/presentation/screens/map/map_screen.dart`
  - [ ] TileLayer configured correctly
  - [ ] No breaking changes to UI
  - [ ] Marker behavior unchanged

### Test Coverage
- [ ] Run: `flutter test --coverage`
- [ ] Coverage > 80% for new code
- [ ] All test cases pass
- [ ] No skipped tests
- [ ] Error cases handled

### Documentation Review
- [ ] All documentation files present
- [ ] Setup instructions clear
- [ ] Code examples accurate
- [ ] Troubleshooting complete
- [ ] API key instructions accurate

---

## Phase 4: Build & Deployment

### Version Bump
- [ ] Update `pubspec.yaml` version
  - [ ] Current: 1.0.15+62
  - [ ] Suggested: 1.0.16+63
  - [ ] Update reason: Baidu Maps integration

### Android Build
- [ ] Run: `flutter build apk --release`
- [ ] Build succeeds without errors
- [ ] APK size acceptable
- [ ] Manifest includes Baidu key
- [ ] No warnings in build output

### iOS Build
- [ ] Run: `flutter build ipa --release`
- [ ] Build succeeds without errors
- [ ] IPA size acceptable
- [ ] Info.plist includes Baidu key
- [ ] No warnings in build output

### Release Build Testing
- [ ] Test APK on Android device
  - [ ] App installs
  - [ ] Map loads correctly
  - [ ] All features work
  - [ ] No crashes

- [ ] Test IPA on iOS device
  - [ ] App installs
  - [ ] Map loads correctly
  - [ ] All features work
  - [ ] No crashes

### Store Preparation
- [ ] Prepare release notes
  - [ ] Updated map provider info
  - [ ] Global coverage mention
- [ ] Update app description (if needed)
- [ ] Prepare screenshots
- [ ] Check all metadata

### Google Play Store
- [ ] Create release build
- [ ] Test internal testing track
- [ ] Promote to beta testing
- [ ] Confirm no issues reported
- [ ] Prepare release notes
- [ ] Submit for review
- [ ] Monitor approval status

### Apple App Store
- [ ] Create release build
- [ ] Test on TestFlight
- [ ] Confirm no issues reported
- [ ] Prepare release notes
- [ ] Update app information
- [ ] Submit for review
- [ ] Monitor approval status

---

## Phase 5: Post-Deployment

### Monitoring
- [ ] Check Sentry error tracking
  - [ ] No new map-related errors
  - [ ] No Baidu API errors
  - [ ] Performance metrics normal

- [ ] Monitor user feedback
  - [ ] App Store reviews
  - [ ] Support tickets
  - [ ] Error reports

### Analytics
- [ ] Map feature usage tracking
- [ ] Regional usage statistics
- [ ] Performance metrics
- [ ] Crash reporting

### Feedback & Iteration
- [ ] Gather user feedback
- [ ] Document any issues
- [ ] Plan improvements
- [ ] Schedule enhancements

---

## Phase 6: Maintenance

### Regular Checks
- [ ] Weekly: Monitor Sentry for issues
- [ ] Monthly: Check map tile service status
- [ ] Quarterly: Review performance metrics
- [ ] Annually: Update dependencies

### Documentation Maintenance
- [ ] Keep docs updated with changes
- [ ] Update troubleshooting as issues arise
- [ ] Maintain API key documentation
- [ ] Update performance metrics

### Scaling & Optimization
- [ ] Monitor performance in production
- [ ] Identify optimization opportunities
- [ ] Implement enhancements as needed
- [ ] Plan Phase 2 features

---

## Troubleshooting Checklist

### If Map Not Loading
- [ ] Check API key in build.gradle
- [ ] Check API key in Info.plist
- [ ] Verify internet connection
- [ ] Check Baidu API status
- [ ] Review error logs in Sentry
- [ ] Try `flutter clean && flutter pub get`

### If Tiles Not Rendering
- [ ] Verify API key format
- [ ] Check Baidu console permissions
- [ ] Verify network connectivity
- [ ] Test tile URL directly: https://api0.map.bdimg.com/customimage/tile?x=1&y=1&z=1
- [ ] Check for API rate limiting

### If Markers Not Showing
- [ ] Verify coordinate format
- [ ] Check database has location records
- [ ] Verify LocationModel data
- [ ] Check marker rendering code
- [ ] Test with known good coordinates

### If Performance Issues
- [ ] Clear app cache
- [ ] Check network speed
- [ ] Monitor memory usage
- [ ] Reduce marker count if excessive
- [ ] Review tile loading behavior

---

## Sign-Off Checklist

### Developer Sign-Off
- [ ] Code implementation complete
- [ ] Tests pass locally
- [ ] Code reviewed
- [ ] Ready for QA

- **Developer**: _________________ **Date**: _________

### QA Sign-Off
- [ ] All testing phases complete
- [ ] No critical bugs found
- [ ] Performance acceptable
- [ ] Ready for release

- **QA Lead**: _________________ **Date**: _________

### Product Sign-Off
- [ ] Feature meets requirements
- [ ] Documentation complete
- [ ] Ready for deployment
- [ ] Launch approved

- **Product Owner**: _________________ **Date**: _________

### Release Sign-Off
- [ ] Build artifacts created
- [ ] Store submissions ready
- [ ] Monitoring configured
- [ ] Ready to release

- **Release Manager**: _________________ **Date**: _________

---

## Quick Reference Links

- Baidu Maps Console: https://lbsyun.baidu.com/apiconsole/key
- Baidu Documentation: https://lbsyun.baidu.com/index.php
- BaiduMapsService: `lib/domain/local_services/baidu_maps_service.dart`
- Tests: `test/baidu_maps_service_test.dart`
- Quick Start: `QUICK_REFERENCE.md`
- Complete Docs: `README_BAIDU_INTEGRATION.md`

---

## Notes & Comments

```
Space for team notes and comments:

_______________________________________________________________

_______________________________________________________________

_______________________________________________________________

_______________________________________________________________

```

---

**Document Version**: 1.0  
**Last Updated**: April 16, 2026  
**Status**: Ready for Team Use  

Print this checklist and check off items as you complete them!

