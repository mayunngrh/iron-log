import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/session.dart';
import '../../data/repositories/session_repository.dart';

enum HistoryPeriod {
  week,
  month,
  year,
  all,
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _sessionRepository = SessionRepository();

  HistoryPeriod _selectedPeriod = HistoryPeriod.month;

  List<Session> _sessions = [];
  double _totalVolume = 0;
  int _totalSessions = 0;
  int _totalReps = 0;
  double _previousPeriodVolume = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      final now = DateTime.now();
      final ranges = _getDateRange(_selectedPeriod, now);
      final start = ranges['start']!;
      final end = ranges['end']!;
      final prevStart = ranges['prevStart']!;
      final prevEnd = ranges['prevEnd']!;

      final summary =
          await _sessionRepository.getSummaryForDateRange(start, end);
      final prevSummary =
          await _sessionRepository.getSummaryForDateRange(prevStart, prevEnd);

      setState(() {
        _sessions = summary['sessions'] as List<Session>;
        _totalSessions = summary['totalSessions'] as int;
        _totalVolume = summary['totalVolume'] as double;
        _totalReps = summary['totalReps'] as int;
        _previousPeriodVolume = prevSummary['totalVolume'] as double;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading history: $e');
      setState(() => _loading = false);
    }
  }

  Map<String, DateTime> _getDateRange(HistoryPeriod period, DateTime now) {
    DateTime start;
    DateTime end = now;
    DateTime prevStart;
    DateTime prevEnd;

    switch (period) {
      case HistoryPeriod.week:
        start = now.subtract(const Duration(days: 7));
        prevStart = start.subtract(const Duration(days: 7));
        prevEnd = start;
      case HistoryPeriod.month:
        start = DateTime(now.year, now.month, 1);
        prevStart = DateTime(now.year, now.month - 1, 1);
        prevEnd = DateTime(now.year, now.month, 0, 23, 59, 59);
      case HistoryPeriod.year:
        start = DateTime(now.year, 1, 1);
        prevStart = DateTime(now.year - 1, 1, 1);
        prevEnd = DateTime(now.year - 1, 12, 31, 23, 59, 59);
      case HistoryPeriod.all:
        start = DateTime(2020, 1, 1);
        prevStart = DateTime(2020, 1, 1);
        prevEnd = DateTime(2020, 1, 1);
    }

    return {
      'start': start,
      'end': end,
      'prevStart': prevStart,
      'prevEnd': prevEnd,
    };
  }

  String _periodLabel(HistoryPeriod period) {
    switch (period) {
      case HistoryPeriod.week:
        return 'WEEK';
      case HistoryPeriod.month:
        return 'MONTH';
      case HistoryPeriod.year:
        return 'YEAR';
      case HistoryPeriod.all:
        return 'ALL TIME';
    }
  }

  String _periodSummaryLabel() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case HistoryPeriod.week:
        return 'WEEKLY SUMMARY';
      case HistoryPeriod.month:
        return 'MONTHLY SUMMARY • ${_getMonthName(now.month)}';
      case HistoryPeriod.year:
        return 'YEARLY SUMMARY • ${now.year}';
      case HistoryPeriod.all:
        return 'ALL TIME SUMMARY';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
    ];
    return months[month - 1];
  }

  String _getMonthAbbr(int month) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPeriodSelector(),
                    const SizedBox(height: 16),
                    Text(_periodSummaryLabel(),
                        style: AppTextStyles.label.copyWith(fontSize: 11)),
                    const SizedBox(height: 12),
                    _buildVolumeCard(),
                    const SizedBox(height: 12),
                    _buildSecondaryStats(),
                    const SizedBox(height: 24),
                    if (_sessions.isNotEmpty) _buildVolumeChart(),
                    const SizedBox(height: 24),
                    _buildRecentSessions(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu_rounded,
                color: AppColors.textSecondary, size: 26),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
          Text('HISTORY',
              style: AppTextStyles.screenTitle
                  .copyWith(color: AppColors.primary)),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: const Icon(Icons.shield_outlined,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: const Icon(Icons.person_rounded,
                color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.inputBorder, width: 0.5),
      ),
      child: Row(
        children: HistoryPeriod.values.map((p) {
          final selected = _selectedPeriod == p;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedPeriod = p);
                _loadData();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _periodLabel(p),
                    style: AppTextStyles.label.copyWith(
                      fontSize: 11,
                      color: selected ? Colors.white : AppColors.textSecondary,
                      fontWeight:
                          selected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVolumeCard() {
    final volumeKg = _totalVolume.toStringAsFixed(0);
    double? changePercent;
    if (_previousPeriodVolume > 0 && _selectedPeriod != HistoryPeriod.all) {
      changePercent =
          ((_totalVolume - _previousPeriodVolume) / _previousPeriodVolume) *
              100;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL VOLUME',
                  style: AppTextStyles.label.copyWith(fontSize: 10)),
              const Icon(Icons.fitness_center_rounded,
                  color: AppColors.textSecondary, size: 22),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(_formatNumber(_totalVolume),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1,
                  )),
              const SizedBox(width: 6),
              Text('KG',
                  style: AppTextStyles.label.copyWith(
                      color: AppColors.primary, fontSize: 13)),
            ],
          ),
          if (changePercent != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  changePercent >= 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: changePercent >= 0
                      ? const Color(0xFF4CAF50)
                      : AppColors.primary,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(1)}% VS LAST ${_periodLabel(_selectedPeriod)}',
                  style: AppTextStyles.label.copyWith(
                    fontSize: 10,
                    color: changePercent >= 0
                        ? const Color(0xFF4CAF50)
                        : AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
          if (_totalVolume == 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(volumeKg,
                  style: const TextStyle(
                      color: Colors.transparent, fontSize: 0)),
            ),
        ],
      ),
    );
  }

  Widget _buildSecondaryStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'WORKOUTS',
            value: '$_totalSessions',
            sub: _intensityLabel(),
            isHighlight: false,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            label: 'TOTAL REPS',
            value: _formatNumber(_totalReps.toDouble()),
            sub: _intensityLabel(),
            isHighlight: true,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String sub,
    required bool isHighlight,
  }) {
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
          Text(label, style: AppTextStyles.label.copyWith(fontSize: 10)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1,
              )),
          const SizedBox(height: 8),
          Row(
            children: [
              if (isHighlight) ...[
                const Icon(Icons.bolt_rounded,
                    color: AppColors.primary, size: 14),
                const SizedBox(width: 4),
              ],
              Text(sub,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 9,
                    color:
                        isHighlight ? AppColors.primary : AppColors.textSecondary,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  String _intensityLabel() {
    if (_totalSessions == 0) return 'NO DATA';
    if (_totalSessions < 4) return 'STARTING OUT';
    if (_totalSessions < 8) return 'BUILDING';
    if (_totalSessions < 12) return 'CONSISTENT';
    if (_totalSessions < 20) return 'INTENSE';
    return 'ELITE INTENSITY';
  }

  Widget _buildVolumeChart() {
    if (_sessions.length < 2) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Need at least 2 sessions for volume progression',
            style: AppTextStyles.body.copyWith(fontSize: 12),
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < _sessions.length; i++) {
      spots.add(FlSpot(i.toDouble(), _sessions[i].totalWeightLifted));
    }

    final maxVolume =
        _sessions.map((s) => s.totalWeightLifted).reduce((a, b) => a > b ? a : b);
    final maxPRSession = _sessions
        .reduce((a, b) => a.totalWeightLifted > b.totalWeightLifted ? a : b);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('VOLUME PROGRESSION',
                  style: AppTextStyles.label.copyWith(fontSize: 11)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'PEAK: ${_formatNumber(maxPRSession.totalWeightLifted)} KG',
                  style: AppTextStyles.label
                      .copyWith(fontSize: 9, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: (_sessions.length / 4).ceilToDouble(),
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= _sessions.length) {
                          return const SizedBox();
                        }
                        final date = _sessions[i].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${_getMonthAbbr(date.month)} ${date.day}',
                            style: AppTextStyles.label.copyWith(fontSize: 9),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                minY: 0,
                maxY: maxVolume * 1.1,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: AppColors.primary,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.3),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                    shadow: Shadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessions() {
    if (_sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.fitness_center_rounded,
                  color: AppColors.textSecondary, size: 40),
              const SizedBox(height: 12),
              Text('NO SESSIONS THIS PERIOD',
                  style: AppTextStyles.label.copyWith(fontSize: 11)),
            ],
          ),
        ),
      );
    }

    final recent = _sessions.reversed.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RECENT SESSIONS',
            style: AppTextStyles.label.copyWith(fontSize: 11)),
        const SizedBox(height: 12),
        ...recent.map((session) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildSessionCard(session),
            )),
      ],
    );
  }

  Widget _buildSessionCard(Session session) {
    final day = session.date.day.toString().padLeft(2, '0');
    final month = _getMonthAbbr(session.date.month);
    final minutes = (session.durationSeconds / 60).round();
    final volume = _formatNumber(session.totalWeightLifted);

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
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(day,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1,
                    )),
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
                  Text(session.workoutName,
                      style: AppTextStyles.sectionTitle.copyWith(fontSize: 14)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          color: AppColors.primary, size: 13),
                      const SizedBox(width: 4),
                      Text('$minutes MIN',
                          style: AppTextStyles.label.copyWith(fontSize: 10)),
                      const SizedBox(width: 14),
                      const Icon(Icons.monitor_weight_outlined,
                          color: AppColors.textSecondary, size: 13),
                      const SizedBox(width: 4),
                      Text('$volume KG',
                          style: AppTextStyles.label.copyWith(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 20),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    final str = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
