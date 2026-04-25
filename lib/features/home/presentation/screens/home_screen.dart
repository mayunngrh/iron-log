import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/models/user_stats.dart';
import '../../../../core/repositories/user_stats_repository.dart';
import '../../../history/data/models/session.dart';
import '../../../history/data/repositories/session_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _userStatsRepository = UserStatsRepository();
  final _sessionRepository = SessionRepository();

  UserStats? _userStats;
  List<Session> _recentSessions = [];
  Map<String, double> _personalRecords = {};
  Set<DateTime> _sessionDates = {};
  Map<DateTime, int> _streakIntensity = {};
  int _currentStreak = 0;
  bool _loading = true;

  // User can select which 3 exercises to display as PRs
  List<String> _selectedPRExercises = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('current_username') ?? 'test_user';

      final userStats = await _userStatsRepository.getUserStats(username);
      final recentSessions = await _sessionRepository.getRecentSessions(limit: 5);
      final prs = await _sessionRepository.getPersonalRecords();
      final allSessions = await _sessionRepository.getAllSessions();

      final sessionDates = allSessions
          .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
          .toSet();

      final streak = _calculateStreak(sessionDates);
      final streakIntensity = _calculateStreakIntensity(sessionDates);

      setState(() {
        _userStats = userStats;
        _recentSessions = recentSessions;
        _personalRecords = prs;
        _sessionDates = sessionDates;
        _streakIntensity = streakIntensity;
        _currentStreak = streak;

        // Default to top 3 PRs by weight
        final sortedPRs = prs.entries.toList();
        sortedPRs.sort((a, b) => b.value.compareTo(a.value));
        _selectedPRExercises = sortedPRs
            .take(3)
            .map((e) => e.key)
            .toList();

        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading home data: $e');
      setState(() => _loading = false);
    }
  }

  int _calculateStreak(Set<DateTime> sessionDates) {
    if (sessionDates.isEmpty) return 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    int streak = 0;
    DateTime checkDate = todayDate;

    if (!sessionDates.contains(checkDate)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (sessionDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  Map<DateTime, int> _calculateStreakIntensity(Set<DateTime> sessionDates) {
    final intensityMap = <DateTime, int>{};
    final processed = <DateTime>{};

    for (final date in sessionDates) {
      if (processed.contains(date)) continue;

      // Find the start of the streak group (walk backwards)
      DateTime streakStart = date;
      while (sessionDates
          .contains(streakStart.subtract(const Duration(days: 1)))) {
        streakStart = streakStart.subtract(const Duration(days: 1));
      }

      // Collect all consecutive days in this streak group
      final streakDays = <DateTime>[];
      DateTime current = streakStart;
      while (sessionDates.contains(current)) {
        streakDays.add(current);
        current = current.add(const Duration(days: 1));
      }

      // Intensity = streak length, capped at 5
      final intensity = streakDays.length > 5 ? 5 : streakDays.length;

      // Apply same intensity to ALL days in this streak group
      for (final d in streakDays) {
        intensityMap[d] = intensity;
        processed.add(d);
      }
    }

    return intensityMap;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_userStats != null) _buildExpProgressCard(),
                    const SizedBox(height: 24),
                    if (_personalRecords.isNotEmpty) _buildPRCards(),
                    const SizedBox(height: 24),
                    _buildConsistencyCalendar(),
                    const SizedBox(height: 24),
                    if (_recentSessions.isNotEmpty) _buildRecentSessions(),
                    if (_recentSessions.isEmpty) _buildEmptyState(),
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
    final rankLabel = _userStats?.getRank().label ?? 'BRONZE';
    final rankColor = _getRankColor(_userStats?.getRank() ?? Rank.bronze);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.background,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.inputBorder, width: 1.5),
            ),
            child: const Icon(Icons.person_rounded,
                color: AppColors.textSecondary, size: 24),
          ),
          const SizedBox(width: 10),
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.security_rounded, color: rankColor, size: 34),
              const Icon(Icons.bolt, color: Colors.white, size: 15),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_userStats?.firstName} ${_userStats?.lastName}'.toUpperCase(),
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 14),
              ),
              Text(
                '${rankLabel.toUpperCase()}  •  LVL ${_userStats?.level}',
                style: AppTextStyles.forgotText
                    .copyWith(fontSize: 11, color: rankColor),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded,
                color: AppColors.textSecondary, size: 24),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu_rounded,
                color: AppColors.textSecondary, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildExpProgressCard() {
    final expProgress = _userStats!.getExpProgress();
    final expNeeded = _userStats!.getExpNeededForNextLevel();
    final progressPercent = expNeeded > 0 ? expProgress / expNeeded : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('LEVEL ${_userStats!.level} PROGRESS',
                  style: AppTextStyles.label),
              Text('$expProgress / $expNeeded EXP',
                  style:
                      AppTextStyles.label.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressPercent.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.inputBorder,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Level ${_userStats!.level + 1} at $expNeeded EXP',
            style: AppTextStyles.body.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPRCards() {
    final topPRs = <String, double>{};
    for (final exercise in _selectedPRExercises) {
      if (_personalRecords.containsKey(exercise)) {
        topPRs[exercise] = _personalRecords[exercise]!;
      }
    }

    if (topPRs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('PERSONAL RECORDS', style: AppTextStyles.sectionTitle),
            Text('${topPRs.length} EXERCISES',
                style: AppTextStyles.label.copyWith(fontSize: 11)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ...topPRs.entries
                .map((entry) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: entry == topPRs.entries.first ? 0 : 6,
                          right: entry == topPRs.entries.last ? 0 : 6,
                        ),
                        child: _buildPRCard(
                          name: entry.key,
                          weight: entry.value,
                        ),
                      ),
                    )),
          ],
        ),
      ],
    );
  }

  Widget _buildPRCard({required String name, required double weight}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name.toUpperCase(),
            style: AppTextStyles.label.copyWith(color: AppColors.primary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              height: 1.1,
            ),
          ),
          Text('KG',
              style: AppTextStyles.label.copyWith(
                color: AppColors.primary,
                fontSize: 10,
              )),
        ],
      ),
    );
  }

  Widget _buildConsistencyCalendar() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    // weekday: Monday = 1, Sunday = 7
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    // Build calendar grid (weeks of days)
    final weeks = <List<DateTime?>>[];
    var currentWeek = <DateTime?>[];

    // Pad start with nulls for days before the 1st
    for (int i = 1; i < firstWeekday; i++) {
      currentWeek.add(null);
    }

    for (int day = 1; day <= daysInMonth; day++) {
      currentWeek.add(DateTime(now.year, now.month, day));
      if (currentWeek.length == 7) {
        weeks.add(currentWeek);
        currentWeek = <DateTime?>[];
      }
    }

    // Fill end with nulls
    if (currentWeek.isNotEmpty) {
      while (currentWeek.length < 7) {
        currentWeek.add(null);
      }
      weeks.add(currentWeek);
    }

    const dayHeaders = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final monthName = _getFullMonthName(now.month);
    final completedDaysInMonth = _sessionDates
        .where((d) => d.year == now.year && d.month == now.month)
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text('TRAINING CONSISTENCY', style: AppTextStyles.label),
              const Spacer(),
              Text(
                '$_currentStreak DAY STREAK',
                style: AppTextStyles.forgotText
                    .copyWith(fontSize: 11, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$monthName ${now.year}',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
              ),
              Text(
                '$completedDaysInMonth / $daysInMonth DAYS',
                style: AppTextStyles.label.copyWith(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(dayHeaders.length, (i) {
              final isWeekend = i >= 5;
              return SizedBox(
                width: 36,
                child: Center(
                  child: Text(
                    dayHeaders[i],
                    style: AppTextStyles.label.copyWith(
                      fontSize: 11,
                      color: isWeekend
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          ...weeks.map((week) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:
                      week.map((day) => _buildDayCell(day, today)).toList(),
                ),
              )),
        ],
      ),
    );
  }

  String _getFullMonthName(int month) {
    const months = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
    ];
    return months[month - 1];
  }

  Widget _buildDayCell(DateTime? day, DateTime today) {
    if (day == null) {
      return const SizedBox(width: 36, height: 36);
    }

    final hasSession = _sessionDates.contains(day);
    final isToday = day == today;
    final isFuture = day.isAfter(today);
    final dayNum = day.day.toString();

    if (hasSession) {
      // Glowing red circle with day number, intensity based on streak position (1-5)
      final intensity = _streakIntensity[day] ?? 1;
      final intensityFactor = intensity / 5.0; // 0.2, 0.4, 0.6, 0.8, 1.0

      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.15 * intensityFactor),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: intensityFactor),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.5 * intensityFactor),
              blurRadius: 8 * intensityFactor,
              spreadRadius: 1 * intensityFactor,
            ),
          ],
        ),
        child: Center(
          child: Text(
            dayNum,
            style: TextStyle(
              color: AppColors.primary.withValues(alpha: intensityFactor),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    if (isToday) {
      // Today (no session): outlined red circle with bold number
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.7),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            dayNum,
            style: TextStyle(
              color: AppColors.primary.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    if (isFuture) {
      // Future day: faded number
      return SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Text(
            dayNum,
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.4),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // Past day with no session: dim number
    return SizedBox(
      width: 36,
      height: 36,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayNum,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessions() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('RECENT SESSIONS', style: AppTextStyles.sectionTitle),
            Text('${_recentSessions.length} LOGGED',
                style: AppTextStyles.forgotText.copyWith(fontSize: 11)),
          ],
        ),
        const SizedBox(height: 12),
        ..._recentSessions.map((session) {
          final day = session.date.day.toString().padLeft(2, '0');
          final month = _getMonthAbbr(session.date.month);
          final minutes = (session.durationSeconds / 60).toStringAsFixed(0);
          final volume =
              session.totalWeightLifted.toStringAsFixed(0);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildSessionCard(
              day: day,
              month: month,
              name: session.workoutName,
              desc: '${session.exercises.length} exercises',
              minutes: int.parse(minutes),
              volume: volume,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSessionCard({
    required String day,
    required String month,
    required String name,
    required String desc,
    required int minutes,
    required String volume,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              border: const Border(
                left: BorderSide(color: AppColors.primary, width: 3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(month, style: AppTextStyles.label.copyWith(fontSize: 10)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: AppTextStyles.sectionTitle.copyWith(
                          fontSize: 14, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(desc, style: AppTextStyles.body),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          color: AppColors.primary, size: 14),
                      const SizedBox(width: 4),
                      Text('$minutes MIN',
                          style: AppTextStyles.label.copyWith(fontSize: 10)),
                      const SizedBox(width: 14),
                      const Icon(Icons.monitor_weight_outlined,
                          color: AppColors.textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Text('$volume KG',
                          style: AppTextStyles.label.copyWith(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.fitness_center_rounded,
                color: AppColors.textSecondary, size: 48),
            const SizedBox(height: 16),
            Text('NO SESSIONS YET', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),
            Text('Complete your first workout to see your progress here',
                style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }

  String _getMonthAbbr(int month) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return months[month - 1];
  }

  Color _getRankColor(Rank rank) {
    switch (rank) {
      case Rank.bronze:
        return const Color(0xFFCD7F32);
      case Rank.silver:
        return const Color(0xFFC0C0C0);
      case Rank.gold:
        return const Color(0xFFFFD700);
      case Rank.platinum:
        return const Color(0xFFE5E4E2);
      case Rank.mythical:
        return AppColors.primary;
    }
  }
}
