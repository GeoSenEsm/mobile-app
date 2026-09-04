import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/controllers/sensor_data_controller.dart';

/// One assigned sensor's own connection status block: shows what the app is currently doing with
/// this specific sensor (searching, connecting, reading, or failed) and — when it isn't actively
/// scanning — lets the user tap it to retry just this sensor. Spans the available width so long
/// value lists and error messages have room instead of clipping inside a small fixed circle.
class SensorSlotCircle extends StatelessWidget {
  final SensorSlot slot;
  final VoidCallback? onRetry;

  const SensorSlotCircle({
    super.key,
    required this.slot,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = slot.status.value;
      final retryable = status == SensorSlotStatus.idle ||
          status == SensorSlotStatus.notFound ||
          status == SensorSlotStatus.bluetoothOff ||
          status == SensorSlotStatus.busy ||
          status == SensorSlotStatus.error;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: retryable ? onRetry : null,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 160),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: _colorFor(status),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Center(child: _content(status)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            slot.displayName,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    });
  }

  /// Blue while idle (not started yet) or searching for the device, orange once found but still
  /// negotiating/reading, green as soon as real values come back, red for anything that needs the
  /// user's attention.
  Color _colorFor(SensorSlotStatus status) {
    switch (status) {
      case SensorSlotStatus.idle:
      case SensorSlotStatus.scanning:
        return Colors.blue;
      case SensorSlotStatus.found:
        return slot.values.isEmpty ? Colors.orange : Colors.green;
      case SensorSlotStatus.notFound:
      case SensorSlotStatus.bluetoothOff:
      case SensorSlotStatus.busy:
      case SensorSlotStatus.error:
        return Colors.red;
    }
  }

  Widget _content(SensorSlotStatus status) {
    switch (status) {
      case SensorSlotStatus.idle:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bluetooth, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              getAppLocalizations().sensorTapToConnect,
              style: const TextStyle(
                  fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        );
      case SensorSlotStatus.scanning:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              getAppLocalizations().scanning,
              style: const TextStyle(
                  fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              getAppLocalizations().sensorSecondsRemaining(slot.secondsRemaining.value),
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        );
      case SensorSlotStatus.found:
        return Obx(() {
          if (slot.values.isEmpty) {
            return const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            );
          }
          final values = slot.values.toList();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: values.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) => Text(
                '${values[index].parameterCode}: ${_format(values[index].value)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
          );
        });
      case SensorSlotStatus.bluetoothOff:
        return _errorContent(getAppLocalizations().bluetoothTurnedOff);
      case SensorSlotStatus.notFound:
        return _errorContent(getAppLocalizations().sensorNotFound);
      case SensorSlotStatus.busy:
        return _errorContent(getAppLocalizations().sensorConnectionBusy);
      case SensorSlotStatus.error:
        return Obx(() => _errorContent(slot.errorMessage.value.isEmpty
            ? getAppLocalizations().error
            : slot.errorMessage.value));
    }
  }

  Widget _errorContent(String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            message,
            style: const TextStyle(
                fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            softWrap: true,
          ),
        ),
        const SizedBox(height: 6),
        const Icon(Icons.refresh_outlined, size: 30, color: Colors.white),
      ],
    );
  }

  String _format(String value) {
    final decimal = num.tryParse(value)?.toDouble();
    if (decimal == null) return value;
    return decimal == decimal.roundToDouble()
        ? decimal.toStringAsFixed(0)
        : decimal.toStringAsFixed(2);
  }
}
