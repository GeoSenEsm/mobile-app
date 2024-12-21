import 'package:flutter/material.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';

class SensorScanningCircle extends StatefulWidget {
  const SensorScanningCircle({super.key});

  @override
  State<SensorScanningCircle> createState() => _SensorScanningCircleState();
}

class _SensorScanningCircleState extends State<SensorScanningCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 1.0, curve: Curves.easeInSine)),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: 200 * _animation.value,
            height: 200 * _animation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor,
            ),
            child: Center(
                child: Text(
              getAppLocalizations().scanning,
              style: const TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            )),
          );
        },
      ),
    );
  }
}
