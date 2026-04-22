import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/presentation/screens/login_screen.dart';

void main() {
  runApp(const IronSanctumApp());
}

class IronSanctumApp extends StatelessWidget {
  const IronSanctumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IronLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
