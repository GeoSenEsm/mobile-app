import 'package:survey_frontend/l10n/app_localizations.dart';

const String selectedMapProviderStorageKey = 'selectedMapProvider';

enum MapProviderType { google, baidu }

MapProviderType mapProviderTypeFromStorage(String? value) {
  return MapProviderType.values.firstWhere(
    (provider) => provider.storageValue == value,
    orElse: () => MapProviderType.google,
  );
}

extension MapProviderTypeX on MapProviderType {
  String get storageValue => switch (this) {
        MapProviderType.google => 'google',
        MapProviderType.baidu => 'baidu',
      };

  String get tileUrlTemplate => switch (this) {
        MapProviderType.google =>
          'https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
        MapProviderType.baidu =>
          'https://maponline{s}.bdimg.com/tile/?qt=tile&x={x}&y={y}&z={z}&styles=pl&scaler=1&p=1',
      };

  List<String> get subdomains => const ['0', '1', '2', '3'];

  String localizedLabel(AppLocalizations localizations) => switch (this) {
        MapProviderType.google => localizations.googleMap,
        MapProviderType.baidu => localizations.baiduMap,
      };
}
