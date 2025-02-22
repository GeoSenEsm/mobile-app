import 'package:flutter/material.dart';
class TimeCircle extends StatelessWidget {
  final int time;
  final String unit;
  final int timeUnit;
  const TimeCircle(
      {super.key,
      required this.time,
      required this.unit,
      required this.timeUnit});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 110,
          height: 110,
          child: CircularProgressIndicator(
            value: time / timeUnit,
            strokeWidth: 8,
            backgroundColor: Theme.of(context).primaryColorLight,
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColorDark),
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              time.toString(),
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              textScaler: const TextScaler.linear(1),
            ),
            Text(
              unit,
              style: const TextStyle(fontSize: 16),
              textScaler: const TextScaler.linear(1),
            ),
          ],
        ),
      ],
    );
  }
}
