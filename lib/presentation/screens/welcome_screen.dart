import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/l10n/app_localizations.dart';
import 'package:survey_frontend/presentation/controllers/welcome_screen_controller.dart';
import 'package:survey_frontend/presentation/widgets/app_logo.dart';

class WelcomeScreen extends GetView<WelcomeScreenController> {
  const WelcomeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 50, right: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          const AppLogo(),
          const SizedBox(height: 10,),
            Text(
              AppLocalizations.of(context)!.weNeedInformation,
          style: const TextStyle(fontSize: 25),
          textAlign: TextAlign.center,),
          const SizedBox(height: 10,),
          ElevatedButton(
            onPressed: controller.letsGo, 
              child: Text(AppLocalizations.of(context)!.letsStart),
            )
        ],),
      ),
    );
  }
}