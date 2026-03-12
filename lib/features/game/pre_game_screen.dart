import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PreGameScreen extends StatelessWidget {
  const PreGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Match Setup'),
      ),
      body: const Center(
        child: Text(
          'Pre-Game Configuration\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
