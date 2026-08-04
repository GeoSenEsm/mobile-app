# mobile-app

Flutter respondent client for GeoSenEsm. Respondents log in, complete
scheduled surveys (online and offline), and sync location / sensor data to
`survey-api`. Local notifications for each time slot follow the per-survey
rules synced from `/api/surveys/allwithtimeslots` (defaults: at start, and
15 minutes before end). On home refresh the app also pulls sensor data setup
from `/api/surveysettings/sensordata/mobile`, including no-sensor mode,
enabled sources, connection timeouts, parameter definitions, and ordered
respondent assignments for backend-provided sensor type codes such as
`xiaomi`, `kestrel`, `pc_60fw`, `bluetooth_sig_plx`, `flower_care`,
`xiaomi_door_sensor_2`, `inkbird_ibs_th1`, `manual`, or `none`. See
`../docs/AddingSensor.md` for the sensor extension guide.


|                      |                                                                                                                                       |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| Stack                | Flutter 3.16+, Dart ≥ 3.3, Dio, GetX, GetStorage, sqflite, geolocator, flutter_blue_plus, flutter_local_notifications, sentry_flutter |
| Platforms            | Android, iOS                                                                                                                          |
| Backend              | `survey-api` (base URL entered on login, stored as `apiUrl`)                                                                          |
| White-label variants | `geosenesm`, `urbeat`                                                                                                                 |
| Sibling clients      | `survey-admin-panel` (researchers)                                                                                                    |


---



## Repository contents


| Path                            | Purpose                                                        |
| ------------------------------- | -------------------------------------------------------------- |
| `lib/presentation/`             | Screens, GetX controllers, bindings                            |
| `lib/domain/`                   | Use cases, entities, service contracts                         |
| `lib/data/`                     | HTTP datasources (`APIServiceBase`), DTO models, local sqflite |
| `lib/core/`                     | Shared models, usecases helpers, utils                         |
| `lib/l10n/`                     | Generated / ARB-driven localizations                           |
| `assets/<variant>/`             | Per-brand images and launcher icon source                      |
| `android/`, `ios/`              | Platform projects                                              |
| `scripts/`                      | Release APK / AAB build scripts per variant                    |
| `android_launcher_icons_*.yaml` | Launcher-icon generation per variant                           |
| `pubspec.yaml`                  | Dependencies and assets                                        |




### Source layout

```
lib/
├── presentation/   UI — screens, GetX controllers, DI bindings
├── domain/         Use cases and pure domain models
├── data/           Datasources, JSON models (*.g.dart), local DB
├── core/           Cross-cutting helpers
└── l10n/           Localization output
```

Screens depend on controllers; controllers depend on use cases / service
interfaces — not on datasource implementations. Wire new services in
`lib/presentation/bindings/initial_bindings.dart`.

### Android variants

One codebase, two branded apps:


| Aspect              | `geosenesm`                               | `urbeat`                               |
| ------------------- | ----------------------------------------- | -------------------------------------- |
| `APP_TYPE`          | `geosenesm`                               | `urbeat`                               |
| Assets              | `assets/geosenesm/`                       | `assets/urbeat/`                       |
| Launcher icons YAML | `android_launcher_icons_geosenesm.yaml`   | `android_launcher_icons_urbeat.yaml`   |
| Signing keys        | `geosenesm.*` in `android/key.properties` | `urbeat.*` in `android/key.properties` |


Use the scripts under `scripts/` for release builds — do not run bare
`flutter build apk` for store artifacts (wrong icon / label / signing).

---



## Local development



### Prerequisites

- Flutter SDK 3.16+ on `PATH`
- Android SDK and/or Xcode
- **JDK 17** for Android builds (e.g. Amazon Corretto 17). Android Studio's
  bundled JBR may be Java 25, which breaks Gradle 8.11 with a cryptic
  `Error resolving plugin ... > 25.0.2`. Pin with
  `flutter config --jdk-dir="<path-to-jdk17>"` and/or `$env:JAVA_HOME`.
- Running `survey-api` reachable from the device / emulator
- `mobile-app/.env` if listed as a dotenv asset in `pubspec.yaml` (placeholder
  is enough when unused)



### Install and run

```bash
flutter pub get
flutter emulators --launch Pixel_API_35   # if needed
flutter run
flutter run --dart-define=APP_TYPE=geosenesm -d emulator-5554
flutter run --dart-define=APP_TYPE=urbeat
```

For the full demo stack (API + admin + seed data), see workspace
`scripts/dev-up.ps1 -Seed` and skill `geosenesm-run-locally`.



### Point at the backend

On first login, enter the API base URL. It is persisted in GetStorage under
`apiUrl` and applied to Dio in `initial_bindings.dart`.


| Target           | Typical URL                 |
| ---------------- | --------------------------- |
| Android emulator | `http://10.0.2.2:8080`      |
| iOS simulator    | `http://localhost:8080`     |
| Physical device  | `http://<host-lan-ip>:8080` |




### Code generation

After changing `@JsonSerializable` models:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Localizations:

```bash
flutter gen-l10n
```

Analyzer should be clean before finishing work:

```bash
flutter analyze
```

---



## Android release builds



### Windows

```powershell
.\scripts\build-android-geosenesm.ps1 apk

.\scripts\build-android-geosenesm.ps1 appbundle
```



### Linux / macOS

```bash
./scripts/build-android-geosenesm.sh apk

./scripts/build-android-geosenesm.sh appbundle
```



### Output artifacts


| Artifact      | Path                                                         |
| ------------- | ------------------------------------------------------------ |
| GeoSenEsm APK | `build/app/outputs/flutter-apk/app-geosenesm-release.apk`    |
| GeoSenEsm AAB | `build/app/outputs/bundle/release/app-geosenesm-release.aab` |




### Signing

Keys are read from `android/key.properties` :

```properties
geosenesm.storePassword=...
geosenesm.keyPassword=...
geosenesm.keyAlias=...
geosenesm.storeFile=...
```

Do not commit real signing secrets.