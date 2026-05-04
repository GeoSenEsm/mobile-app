# survey_frontend

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Android Build Variants

The project supports two Android variants:

- `geosenesm`
- `urbeat`

The build scripts set the correct `APP_TYPE`, Android `applicationId`, signing config, app label, and launcher icon for the selected variant.

### Windows

Build release APK:

```powershell
.\scripts\build-android-geosenesm.ps1 apk
.\scripts\build-android-urbeat.ps1 apk
```

Build release app bundle:

```powershell
.\scripts\build-android-geosenesm.ps1 appbundle
.\scripts\build-android-urbeat.ps1 appbundle
```

### Linux

Build release APK:

```bash
./scripts/build-android-geosenesm.sh apk
./scripts/build-android-urbeat.sh apk
```

Build release app bundle:

```bash
./scripts/build-android-geosenesm.sh appbundle
./scripts/build-android-urbeat.sh appbundle
```

### Output Files

The scripts copy the generated artifacts to variant-specific filenames:

- `build/app/outputs/flutter-apk/app-geosenesm-release.apk`
- `build/app/outputs/flutter-apk/app-urbeat-release.apk`
- `build/app/outputs/bundle/release/app-geosenesm-release.aab`
- `build/app/outputs/bundle/release/app-urbeat-release.aab`

### Android Signing Configuration

Android signing is read from `android/key.properties` using explicit per-variant keys:

```properties
geosenesm.storePassword=...
geosenesm.keyPassword=...
geosenesm.keyAlias=...
geosenesm.storeFile=...

urbeat.storePassword=...
urbeat.keyPassword=...
urbeat.keyAlias=...
urbeat.storeFile=...
```

Do not commit real signing secrets.
