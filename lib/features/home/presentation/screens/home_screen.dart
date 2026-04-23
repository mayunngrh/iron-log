import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

// ---------------------------------------------------------------------------
// Dummy data — replace with real models once backend is ready
// ---------------------------------------------------------------------------

const _streakDays = 4;

// 0 = missed, 1 = completed, 2 = today, 3 = future/empty
const _consistencyGrid = [
  [0, 1, 1, 0, 1, 0, 0],
  [1, 1, 0, 1, 0, 0, 0],
  [0, 1, 1, 1, 1, 2, 3],
];

const _sbdRecords = [
  {'name': 'SQUAT', 'weight': 185, 'progress': 0.78, 'highlighted': false},
  {'name': 'BENCH', 'weight': 142, 'progress': 0.60, 'highlighted': false},
  {'name': 'DEADLIFT', 'weight': 220, 'progress': 0.92, 'highlighted': true},
];

const _recentSessions = [
  {
    'day': '24',
    'month': 'OCT',
    'name': 'HEAVY PUSH DAY',
    'desc': 'Chest, Shoulders, Triceps',
    'minutes': 74,
    'volume': '12,400',
    'active': true,
  },
  {
    'day': '22',
    'month': 'OCT',
    'name': 'BACK & PULL VOLUME',
    'desc': 'Hypertrophy focus',
    'minutes': 62,
    'volume': '9,850',
    'active': false,
  },
];

const _quote =
    '"THE IRON NEVER LIES TO YOU. THE IRON IS THE ';
const _quoteHighlight = 'GREAT REFERENCE POINT';
const _quoteSuffix = '."';
const _quoteAuthor = '— HENRY ROLLINS';

// ---------------------------------------------------------------------------

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    _buildConsistencyCard(),
                    const SizedBox(height: 24),
                    _buildSBDPillars(),
                    const SizedBox(height: 24),
                    _buildRecentSessions(),
                    const SizedBox(height: 24),
                    _buildQuote(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
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
              Icon(Icons.security_rounded, color: AppColors.primary, size: 34),
              const Icon(Icons.bolt, color: Colors.white, size: 15),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MARCUS VANE',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 14)),
              Text('ELITE  •  LVL 42',
                  style: AppTextStyles.forgotText.copyWith(fontSize: 11)),
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

  // ── Training Consistency ──────────────────────────────────────────────────

  Widget _buildConsistencyCard() {
    const dayHeaders = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text('TRAINING CONSISTENCY', style: AppTextStyles.label),
              const Spacer(),
              Text(
                '$_streakDays DAY STREAK',
                style: AppTextStyles.forgotText.copyWith(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Day-of-week headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: dayHeaders
                .map((d) => SizedBox(
                      width: 32,
                      child: Center(
                        child: Text(
                          d,
                          style: AppTextStyles.label.copyWith(
                            fontSize: 11,
                            color: d == 'S' &&
                                    dayHeaders.indexOf(d) == 6
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Grid rows
          ..._consistencyGrid.map((week) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: week.map((status) => _buildDayCell(status)).toList(),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDayCell(int status) {
    switch (status) {
      case 1: // completed
        return Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
        );
      case 2: // today
        return Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary,
              width: 1.5,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: const Icon(Icons.play_arrow_rounded,
              color: AppColors.textSecondary, size: 16),
        );
      case 3: // future
        return Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.inputBorder, width: 1),
          ),
        );
      default: // 0 = missed
        return Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.inputBorder,
              shape: BoxShape.circle,
            ),
          ),
        );
    }
  }

  // ── SBD Pillars ───────────────────────────────────────────────────────────

  Widget _buildSBDPillars() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('THE SBD PILLARS', style: AppTextStyles.sectionTitle),
            Text('1RM RECORDS', style: AppTextStyles.label),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: _sbdRecords
              .map((r) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: r == _sbdRecords.first ? 0 : 6,
                        right: r == _sbdRecords.last ? 0 : 6,
                      ),
                      child: _buildSBDCard(
                        name: r['name'] as String,
                        weight: r['weight'] as int,
                        progress: (r['progress'] as num).toDouble(),
                        highlighted: r['highlighted'] as bool,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSBDCard({
    required String name,
    required int weight,
    required double progress,
    required bool highlighted,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: highlighted
            ? Border.all(color: AppColors.primary, width: 1.5)
            : Border.all(color: AppColors.inputBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppTextStyles.label.copyWith(
              color: highlighted ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$weight',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: highlighted ? AppColors.primary : AppColors.textPrimary,
              height: 1.1,
            ),
          ),
          Text('KG',
              style: AppTextStyles.label.copyWith(
                color:
                    highlighted ? AppColors.primary : AppColors.textSecondary,
                fontSize: 10,
              )),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: AppColors.inputBorder,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  // ── Recent Sessions ───────────────────────────────────────────────────────

  Widget _buildRecentSessions() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('RECENT SESSIONS', style: AppTextStyles.sectionTitle),
            Text('VIEW HISTORY',
                style: AppTextStyles.forgotText.copyWith(fontSize: 11)),
          ],
        ),
        const SizedBox(height: 12),
        ..._recentSessions.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildSessionCard(
                day: s['day'] as String,
                month: s['month'] as String,
                name: s['name'] as String,
                desc: s['desc'] as String,
                minutes: s['minutes'] as int,
                volume: s['volume'] as String,
                active: s['active'] as bool,
              ),
            )),
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
    required bool active,
  }) {
    final dimColor =
        active ? AppColors.textPrimary : AppColors.textSecondary;
    final dimSub =
        active ? AppColors.textSecondary : AppColors.textSecondary.withValues(alpha: 0.5);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Date block
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
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: active ? AppColors.textPrimary : AppColors.textSecondary,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(month,
                    style: AppTextStyles.label.copyWith(fontSize: 10)),
              ],
            ),
          ),
          // Info block
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: AppTextStyles.sectionTitle.copyWith(
                          fontSize: 14, color: dimColor)),
                  const SizedBox(height: 2),
                  Text(desc,
                      style:
                          AppTextStyles.body.copyWith(color: dimSub)),
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

  // ── Quote ─────────────────────────────────────────────────────────────────

  Widget _buildQuote() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.5,
                letterSpacing: 0.5,
              ),
              children: [
                const TextSpan(text: _quote),
                TextSpan(
                  text: _quoteHighlight,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: _quoteSuffix),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _quoteAuthor,
            style: AppTextStyles.label.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
