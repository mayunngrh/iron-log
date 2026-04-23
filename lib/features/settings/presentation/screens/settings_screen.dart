import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.settings_outlined,
                  color: AppColors.textSecondary, size: 48),
              const SizedBox(height: 16),
              Text('SETTINGS', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 8),
              Text('Coming soon', style: AppTextStyles.body),
            ],
          ),
        ),
      ),
    );
  }
}
