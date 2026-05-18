import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_alt_rounded,
                      size: 64,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'COMMUNITY',
                      style: AppTextStyles.sectionTitle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Coming soon',
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: AppColors.background,
      child: Row(
        children: [
          Expanded(
            child: Text(
              'COMMUNITY',
              style: AppTextStyles.sectionTitle,
            ),
          ),
        ],
      ),
    );
  }
}
