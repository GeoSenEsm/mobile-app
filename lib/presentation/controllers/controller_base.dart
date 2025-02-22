import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ControllerBase extends GetxController {
  final Connectivity connectivity = Connectivity();

  Future<void> handleSomethingWentWrong(Object? error) async {
    String message;

    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        message = AppLocalizations.of(Get.context!)!
            .couldNotReachTheServer;
      } else if (error.type == DioExceptionType.unknown &&
          error.error is SocketException) {
        message = AppLocalizations.of(Get.context!)!
            .couldNotReachTheServer;
      } else {
        message =
            AppLocalizations.of(Get.context!)!.somethingWentWrong;
      }
    } else {
      message =
          AppLocalizations.of(Get.context!)!.somethingWentWrong; 
    }

    await Sentry.captureException(error);
    await popup(AppLocalizations.of(Get.context!)!.error, message);
  }

  Future<void> popup(String title, String message) async {
    await Get.defaultDialog(
      backgroundColor: Colors.white,
        title: title,
        middleText: message,
        confirm: ElevatedButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("Ok"),
        ));
  }

  Future<bool> hasInternetConnection() async {
    if (!await hasInternetConnectionNoDialog()) {
      await Get.defaultDialog(
          title: AppLocalizations.of(Get.context!)!.error,
          middleText: AppLocalizations.of(Get.context!)!.noInternetTryAgain,
          confirm: const Text("Ok"));
      return false;
    }

    return true;
  }

  Future<bool> hasInternetConnectionNoDialog() async {
    var connectivityResult = await connectivity.checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.ethernet)
    || connectivityResult.contains(ConnectivityResult.mobile)
    || connectivityResult.contains(ConnectivityResult.wifi);
  }
}
