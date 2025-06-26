import 'package:flutter/material.dart';
import 'package:survey_frontend/presentation/screens/privacy_policy/widgets/privacy_policy_content.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: const Column(
          children: [Expanded(child: PrivacyPolicyContent())],
        ));
  }
}
