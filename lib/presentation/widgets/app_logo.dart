import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget{
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
            _getLogoAssetPath(),
            width: 145,
            height: 145);
  }

  String _getLogoAssetPath() {
    String appType = const String.fromEnvironment('APP_TYPE', defaultValue: 'geosenesm');
    return 'assets/$appType/logo.png';
  }

}