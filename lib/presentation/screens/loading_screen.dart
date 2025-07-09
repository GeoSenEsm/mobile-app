import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/l10n/app_localizations.dart';
import 'package:survey_frontend/presentation/controllers/loading_controller.dart';
import 'package:survey_frontend/presentation/widgets/app_logo.dart';

class LoadingScreen extends GetView<LoadingController>{
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.goToNextPage();
    });
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const AppLogo(),
            Obx((){
              if (controller.retryButtonVisible.value){
                return ElevatedButton(
                  onPressed: controller.goToNextPage, 
                  child: Text(AppLocalizations.of(context)!.errorRetry)
                );
              } else{
                return CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                );
              }
            })
            
          ],)
      )
    );
  }
}