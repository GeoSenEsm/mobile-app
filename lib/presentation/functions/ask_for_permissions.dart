import 'package:permission_handler/permission_handler.dart';
import 'package:survey_frontend/presentation/screens/home/widgets/request.dart';

Future<void> askForPermissions() async {
  final statuses = await [
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.notification,
    Permission.location,
  ].request();
  if (statuses.values.any((status) => !status.isGranted)) {
    await buildManyDenyDialog();
  }
  if (!await Permission.locationAlways.isGranted) {
    await buildLocationDenyDialog();
  }
}
