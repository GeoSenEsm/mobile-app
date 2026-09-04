import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:survey_frontend/core/models/map_provider.dart';
import 'package:survey_frontend/data/models/location_model.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/app_styles.dart';
import 'package:survey_frontend/presentation/controllers/map_screen_controller.dart';
import 'package:survey_frontend/presentation/functions/formatters.dart';
import 'package:survey_frontend/presentation/screens/map/baidu_tile_provider.dart';

class MapScreen extends GetView<MapScreenController> {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 60),
          _buildTopBar(context),
          _buildFilters(context),
          _buildMap(context),
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
            icon: const Icon(Icons.close, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      color: AppStyles.backgroundSecondary,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
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
                return Text('$fromString - $toString', style: style);
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

  Widget _buildMap(BuildContext context) {
    return Expanded(
      child: Container(
        color: AppStyles.backgroundSecondary,
        child: Stack(
          children: [
            Obx(() {
              final provider = controller.mapProvider.value;
              return FlutterMap(
                mapController: controller.mapController,
                options: MapOptions(
                  initialCenter: controller.initialCenter,
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: controller.tileUrlTemplate,
                    subdomains: controller.tileSubdomains,
                    userAgentPackageName: 'urbeat.site.app',
                    tileProvider: provider == MapProvider.baidu
                        ? BaiduTileProvider()
                        : null,
                  ),
                  MarkerLayer(
                    markers: controller.locations
                        .map(_getMarkerForLocation)
                        .toList(),
                  ),
                ],
              );
            }),
            Positioned(
              top: 10,
              right: 10,
              child: _buildProviderButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderButton(BuildContext context) {
    return Obx(() {
      final isBaidu = controller.mapProvider.value == MapProvider.baidu;
      return Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showProviderDialog(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map,
                    size: 18, color: isBaidu ? Colors.red : Colors.green),
                const SizedBox(width: 4),
                Text(
                  isBaidu ? 'Baidu' : 'OSM',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isBaidu ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showProviderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Obx(() {
        final current = controller.mapProvider.value;
        return AlertDialog(
          title: const Text('Wybierz mapę'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildProviderTile(
                ctx,
                provider: MapProvider.openStreetMap,
                label: 'OpenStreetMap',
                icon: Icons.public,
                color: Colors.green,
                isSelected: current == MapProvider.openStreetMap,
              ),
              const SizedBox(height: 8),
              _buildProviderTile(
                ctx,
                provider: MapProvider.baidu,
                label: 'Baidu Maps',
                icon: Icons.map,
                color: Colors.red,
                isSelected: current == MapProvider.baidu,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProviderTile(
    BuildContext context, {
    required MapProvider provider,
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        controller.setMapProvider(provider);
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color:
              isSelected ? color.withValues(alpha: 0.08) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? color : null)),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 20),
          ],
        ),
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
      ),
    );
  }
}
