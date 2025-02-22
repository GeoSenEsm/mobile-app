import 'package:flutter/material.dart';

class SensorScanningErrorCircle extends StatelessWidget {
  final String errorMessage;
  final void Function()? onRetry;

  const SensorScanningErrorCircle({super.key, required this.errorMessage, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if (onRetry != null){
          onRetry!();
        }
      },
      child: Container(
        width: 200,
        height: 200,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 150,
              child: Text(
                errorMessage,
                style: const TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Icon(
                Icons.refresh_outlined,
                size: 50,
                color: Colors.white,
              )
          ],
        )),
      ),
    );
  }
}
