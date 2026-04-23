import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline_rounded,
                  color: AppColors.textSecondary, size: 48),
              const SizedBox(height: 16),
              Text('START SESSION', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 8),
              Text('Coming soon', style: AppTextStyles.body),
            ],
          ),
        ),
      ),
    );
  }
}
