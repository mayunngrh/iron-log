import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../workouts/presentation/screens/workouts_screen.dart';
import '../../../history/presentation/screens/history_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    WorkoutsScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.inputBorder, width: 0.5),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.label.copyWith(fontSize: 10),
        unselectedLabelStyle: AppTextStyles.label.copyWith(fontSize: 10),
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Icon(Icons.home_rounded, size: 26),
            ),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Icon(Icons.fitness_center_rounded, size: 24),
            ),
            label: 'WORKOUTS',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Icon(Icons.history_rounded, size: 26),
            ),
            label: 'HISTORY',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Icon(Icons.settings_outlined, size: 24),
            ),
            label: 'SETTINGS',
          ),
        ],
      ),
    );
  }
}
