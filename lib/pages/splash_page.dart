import 'package:flutter/material.dart';

import '../widgets/app_loading.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AppLoadingIndicator(message: 'Loading your account…'),
    );
  }
}
