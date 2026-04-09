import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:survey_frontend/data/models/location_model.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/app_styles.dart';
import 'package:survey_frontend/presentation/controllers/map_screen_controller.dart';
import 'package:survey_frontend/presentation/functions/formatters.dart';
import 'package:survey_frontend/presentation/screens/map/map_provider_type.dart';

class MapScreen extends GetView<MapScreenController> {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 60,
          ),
          _buildTopBar(context),
          _buildProviderSelector(context),
          _buildFilters(context),
          _buildMap(),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppStyles.backgroundSecondary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getAppLocalizations().map,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 22,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      color: AppStyles.backgroundSecondary,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        child: Wrap(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Obx(() {
                final style = TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).cardColor,
                    fontWeight: FontWeight.bold);

                if (controller.from.value == null &&
                    controller.to.value == null) {
                  return Text(getAppLocalizations().today, style: style);
                }

                final fromString = controller.from.value == null
                    ? ''
                    : dateTimeShortFormat(controller.from.value!);
                final toString = controller.to.value == null
                    ? ''
                    : dateTimeShortFormat(controller.to.value!);
                return Text(
                  '$fromString - $toString',
                  style: style,
                );
              }),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                  onPressed: controller.openFilters,
                  child: const Icon(Icons.filter_alt)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProviderSelector(BuildContext context) {
    final localizations = getAppLocalizations();
    return Container(
      width: double.infinity,
      color: AppStyles.backgroundSecondary,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.mapProvider,
            style: TextStyle(
              color: Theme.of(context).cardColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final selectedProvider = controller.selectedMapProvider.value;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final provider in MapProviderType.values)
                  ChoiceChip(
                    label: Text(provider.localizedLabel(localizations)),
                    selected: selectedProvider == provider,
                    onSelected: (_) => controller.setMapProvider(provider),
                  )
              ],
            );
          })
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Expanded(
      child: Container(
        color: AppStyles.backgroundSecondary,
        child: Obx(() => FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: controller.initialCenter,
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: controller.mapUrlTemplate,
                  subdomains: controller.mapSubdomains,
                  userAgentPackageName: 'urbeat.site.app',
                ),
                MarkerLayer(
                  markers: controller.locations
                      .map(_getMarkerForLocation)
                      .toList(growable: false),
                )
              ],
            )),
      ),
    );
  }

  Marker _getMarkerForLocation(LocationModel model) {
    return Marker(
        point: controller.mapPointForLocation(model),
        child: GestureDetector(
          onTap: () => controller.openDetails(model),
            child: Icon(
              Icons.circle,
              color: model.sentToServer ? Colors.blue : Colors.red,
              size: 40,
            ),
        ));
  }
}
