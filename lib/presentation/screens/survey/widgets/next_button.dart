import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';

class NextButton extends StatelessWidget {
  final VoidCallback nextAction;
  final String text;
  final RxBool hasToScrollDown;
  const NextButton(
      {super.key,
      required this.nextAction,
      required this.text,
      required this.hasToScrollDown});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5))
      ]),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              if (!hasToScrollDown.value) {
                return const SizedBox(
                  height: 0,
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  getAppLocalizations().scrollToTheVeryBottom,
                  style: const TextStyle(fontSize: 18),
                ),
              );
            }),
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasToScrollDown.value ? null : nextAction,
                child: Text(text),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
