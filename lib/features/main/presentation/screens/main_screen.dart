import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../workouts/presentation/screens/workouts_screen.dart';
import '../../../community/presentation/screens/community_screen.dart';
import '../../../history/presentation/screens/history_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CommunityScreen(),
    WorkoutsScreen(),
    HistoryScreen(),
    ProfileScreen(),
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
    final isWorkoutActive = _currentIndex == 2;
    return Container(
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 76,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(
                          color: AppColors.inputBorder, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      _navItem(
                          icon: Icons.home_rounded, label: 'HOME', index: 0),
                      _navItem(
                          icon: Icons.people_alt_rounded,
                          label: 'COMMUNITY',
                          index: 1),
                      const Expanded(child: SizedBox()),
                      _navItem(
                          icon: Icons.history_rounded,
                          label: 'HISTORY',
                          index: 3),
                      _navItem(
                          icon: Icons.person_rounded,
                          label: 'PROFILE',
                          index: 4),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -24,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _currentIndex = 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isWorkoutActive
                              ? AppColors.primary
                              : AppColors.surface,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.fitness_center_rounded,
                          size: 30,
                          color: isWorkoutActive
                              ? Colors.white
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'WORKOUTS',
                        style: AppTextStyles.label.copyWith(
                          fontSize: 9,
                          color: isWorkoutActive
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _currentIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                fontSize: 9,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
