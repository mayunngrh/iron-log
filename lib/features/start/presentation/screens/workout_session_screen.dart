import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../workouts/data/models/workout.dart';
import '../../../history/data/models/session.dart';
import '../../../history/data/repositories/session_repository.dart';

enum SessionPhase {
  warmupCountdown,
  sessionOverview,
  preSetCountdown,
  activeSet,
  completed,
}

const _motivationalQuotes = [
  (text: 'Every rep builds the legacy', author: 'Iron Creed'),
  (text: 'Pain is temporary, legacy is forever', author: 'Ancient Iron'),
  (text: 'Leave no doubt', author: 'Mind Over Matter'),
  (text: 'The iron remembers everything', author: 'Iron Sanctum'),
  (text: 'Comfort is the enemy of progress', author: 'Steel Truth'),
  (text: 'Your limits are imaginary', author: 'Breaking Chains'),
];

class WorkoutSessionScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutSessionScreen({super.key, required this.workout});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  late Workout _workout;
  SessionPhase _phase = SessionPhase.warmupCountdown;
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 0;
  late List<List<bool>> _completedSets;
  Timer? _masterTimer;
  int _countdownSeconds = 10;
  int _restSecondsRemaining = 0;
  int _elapsedSessionSeconds = 0;
  int _activeSetElapsedSeconds = 0;
  bool _isRestOverlayVisible = false;

  static const int _warmupRestSeconds = 30;
  static const int _regularRestSeconds = 90;
  static const int _nudgeThresholdSeconds = 90;

  @override
  void initState() {
    super.initState();
    _workout = widget.workout;
    _initCompletionGrid();
    _startMasterTimer();
  }

  @override
  void dispose() {
    _masterTimer?.cancel();
    super.dispose();
  }

  // ── Initialization ────────────────────────────────────────────────────────

  void _initCompletionGrid() {
    _completedSets = _workout.exercises
        .map((we) => List<bool>.filled(we.sets.length, false))
        .toList();
  }

  void _startMasterTimer() {
    _masterTimer = Timer.periodic(const Duration(seconds: 1), _handleTimerTick);
  }

  // ── Timer Logic ───────────────────────────────────────────────────────────

  void _handleTimerTick(Timer t) {
    if (!mounted) return;

    setState(() {
      _elapsedSessionSeconds++;

      switch (_phase) {
        case SessionPhase.warmupCountdown:
          _countdownSeconds--;
          if (_countdownSeconds == 0) {
            startRest(isFirst: true);
          }

        case SessionPhase.preSetCountdown:
          _countdownSeconds--;
          if (_countdownSeconds == 0) {
            _activeSetElapsedSeconds = 0;
            _phase = SessionPhase.activeSet;
          }

        case SessionPhase.activeSet:
          _activeSetElapsedSeconds++;
          if (_activeSetElapsedSeconds == _nudgeThresholdSeconds) {
            _showNudgeSnackbar();
          }

        case SessionPhase.sessionOverview:
          if (_isRestOverlayVisible && _restSecondsRemaining > 0) {
            _restSecondsRemaining--;
            if (_restSecondsRemaining == 0) {
              _isRestOverlayVisible = false;
              _startPreSetCountdown();
            }
          }

        case SessionPhase.completed:
          t.cancel();
      }
    });
  }

  // ── Phase Transitions ─────────────────────────────────────────────────────

  void _startPreSetCountdown() {
    setState(() {
      _countdownSeconds = 3;
      _phase = SessionPhase.preSetCountdown;
    });
  }

  void startRest({required bool isFirst}) {
    setState(() {
      _restSecondsRemaining =
          isFirst ? _warmupRestSeconds : _regularRestSeconds;
      _isRestOverlayVisible = true;
      _phase = SessionPhase.sessionOverview;
    });
  }

  void _completeSession() async {
    setState(() {
      _phase = SessionPhase.completed;
    });
    _masterTimer?.cancel();

    await _saveSessionToDatabase();
  }

  Future<void> _saveSessionToDatabase() async {
    try {
      final sessionRepository = SessionRepository();

      double totalWeightLifted = 0;
      int totalSetsCompleted = 0;
      final sessionExercises = <SessionExercise>[];

      for (int i = 0; i < _workout.exercises.length; i++) {
        final workoutExercise = _workout.exercises[i];
        double maxWeightInExercise = 0;
        int exerciseSetsCompleted = 0;

        for (int j = 0; j < workoutExercise.sets.length; j++) {
          if (_completedSets[i][j]) {
            final set = workoutExercise.sets[j];
            final setWeight = set.weight * set.reps;
            totalWeightLifted += setWeight;
            maxWeightInExercise = maxWeightInExercise > set.weight
                ? maxWeightInExercise
                : set.weight;
            exerciseSetsCompleted++;
          }
        }

        totalSetsCompleted += exerciseSetsCompleted;

        if (exerciseSetsCompleted > 0) {
          sessionExercises.add(
            SessionExercise(
              sessionId: 0,
              exerciseName: workoutExercise.exercise.name,
              setsCompleted: exerciseSetsCompleted,
              totalWeight: totalWeightLifted,
              maxWeightInSet: maxWeightInExercise,
            ),
          );
        }
      }

      final expGained = totalWeightLifted.toInt();

      final session = Session(
        workoutId: _workout.id!,
        workoutName: _workout.name,
        date: DateTime.now(),
        durationSeconds: _elapsedSessionSeconds,
        totalWeightLifted: totalWeightLifted,
        totalSetsCompleted: totalSetsCompleted,
        expGained: expGained,
        exercises: sessionExercises,
      );

      await sessionRepository.saveSession(session);

      // Note: Update user stats when user data is available (from login)
      // await userStatsRepository.addExp(username, expGained);
    } catch (e) {
      debugPrint('Error saving session: $e');
    }
  }

  void _cancelSession() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Abandon Session?',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 16)),
        content: Text('Your progress will not be saved.',
            style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CONTINUE', style: AppTextStyles.label),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _masterTimer?.cancel();
              Navigator.pop(context);
            },
            child: Text('QUIT',
                style: AppTextStyles.forgotText.copyWith(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ── Set Actions ───────────────────────────────────────────────────────────

  void finishSet() {
    setState(() {
      _completedSets[_currentExerciseIndex][_currentSetIndex] = true;

      if (_allSetsCompleted) {
        _completeSession();
      } else {
        _advanceToNextSet();
        startRest(isFirst: false);
      }
    });
  }

  void _advanceToNextSet() {
    final currentExerciseSets = _workout.exercises[_currentExerciseIndex].sets;
    if (_currentSetIndex < currentExerciseSets.length - 1) {
      _currentSetIndex++;
    } else if (_currentExerciseIndex < _workout.exercises.length - 1) {
      _currentExerciseIndex++;
      _currentSetIndex = 0;
    }
  }


  // ── Rest Controls ─────────────────────────────────────────────────────────

  void adjustRest(int deltaSeconds) {
    setState(() {
      _restSecondsRemaining =
          (_restSecondsRemaining + deltaSeconds).clamp(0, 600);
    });
  }

  void startNextSetManually() {
    setState(() {
      _isRestOverlayVisible = false;
    });
    _startPreSetCountdown();
  }

  // ── Nudge ─────────────────────────────────────────────────────────────────

  void _showNudgeSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('STILL GOING? TAP FINISH SET WHEN READY.',
            style: AppTextStyles.label),
        backgroundColor: AppColors.cardBackground,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _elapsedLabel => _formatTime(_elapsedSessionSeconds);

  WorkoutExercise get _currentExercise =>
      _workout.exercises[_currentExerciseIndex];

  ExerciseSet get _currentSet => _currentExercise.sets[_currentSetIndex];

  bool get _allSetsCompleted =>
      _completedSets.every((exSets) => exSets.every((done) => done));

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: switch (_phase) {
          SessionPhase.warmupCountdown => _buildWarmupCountdown(),
          SessionPhase.preSetCountdown => _buildPreSetCountdown(),
          SessionPhase.activeSet => _buildActiveSet(),
          SessionPhase.sessionOverview => _buildSessionOverview(),
          SessionPhase.completed => _buildCompletionSummary(),
        },
      ),
    );
  }

  // ── Phase 1: Warm Up Countdown ────────────────────────────────────────────

  Widget _buildWarmupCountdown() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: const Icon(Icons.close_rounded,
                color: AppColors.textSecondary, size: 24),
            onPressed: _cancelSession,
          ),
        ),
        const Spacer(),
        Text('WARM UP',
            style: AppTextStyles.label.copyWith(
                fontSize: 11, letterSpacing: 4, color: AppColors.textSecondary)),
        const SizedBox(height: 24),
        Text('$_countdownSeconds',
            style: GoogleFonts.oswald(
              fontSize: 140,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              shadows: [
                Shadow(
                    color: AppColors.primary.withValues(alpha: 0.8),
                    blurRadius: 30),
                Shadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 60),
              ],
            )),
        const SizedBox(height: 24),
        Text('PREPARE FOR WAR',
            style: AppTextStyles.heroHeading.copyWith(
                fontSize: 18, letterSpacing: 6, color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        Text('NEXT SET: ${_workout.exercises.first.exercise.name}',
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
        const Spacer(),
      ],
    );
  }

  // ── Phase 2: Session Overview ─────────────────────────────────────────────

  Widget _buildSessionOverview() {
    return Stack(
      children: [
        Column(
          children: [
            _buildSessionAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  children: [
                    _buildSessionNameCard(),
                    const SizedBox(height: 16),
                    ..._workout.exercises.asMap().entries.map((e) =>
                        _buildExerciseCard(e.key, e.value)),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_isRestOverlayVisible)
          Positioned(bottom: 0, left: 0, right: 0, child: _buildRestOverlay()),
      ],
    );
  }

  Widget _buildSessionAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.inputBorder)),
      ),
      child: Row(
        children: [
          Text('IRON SANCTUM', style: AppTextStyles.screenTitle),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.timer_outlined,
                  color: AppColors.primary, size: 16),
              const SizedBox(width: 6),
              Text(_elapsedLabel,
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 14)),
            ],
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.close_rounded,
                color: AppColors.textSecondary, size: 24),
            onPressed: _cancelSession,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionNameCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A1515), Color(0xFF1A1010)],
        ),
        border: Border.all(color: AppColors.inputBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ACTIVE SESSION',
              style: AppTextStyles.label.copyWith(
                  fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(_workout.name.toUpperCase(),
              style: AppTextStyles.heroHeading.copyWith(fontSize: 28)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.timer_outlined,
                  color: AppColors.textSecondary, size: 13),
              const SizedBox(width: 6),
              Text('~${_workout.estimatedDuration} MIN',
                  style: AppTextStyles.label.copyWith(fontSize: 10)),
              const SizedBox(width: 16),
              const Icon(Icons.fitness_center_rounded,
                  color: AppColors.textSecondary, size: 13),
              const SizedBox(width: 6),
              Text('${_workout.exerciseCount} EXERCISES',
                  style: AppTextStyles.label.copyWith(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(int exIdx, WorkoutExercise we) {
    final isCurrentExercise = exIdx == _currentExerciseIndex;
    final completedCount = _completedSets[exIdx].where((d) => d).length;
    final totalSets = we.sets.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentExercise ? AppColors.primary : AppColors.inputBorder,
          width: isCurrentExercise ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(we.exercise.name,
                        style: AppTextStyles.sectionTitle.copyWith(
                            fontSize: 15, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(we.tag,
                        style: AppTextStyles.body.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text('$completedCount/$totalSets',
                  style: AppTextStyles.forgotText.copyWith(fontSize: 11)),
            ],
          ),
          if (isCurrentExercise) ...[
            const SizedBox(height: 14),
            const Divider(color: AppColors.inputBorder, height: 1),
            const SizedBox(height: 12),
            ...we.sets.asMap().entries.map((e) =>
                _buildSetRow(exIdx, e.key, e.value,
                    _completedSets[exIdx][e.key])),
          ],
        ],
      ),
    );
  }

  Widget _buildSetRow(int exIdx, int setIdx, ExerciseSet set, bool completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: completed ? AppColors.cardBackground : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: completed ? AppColors.primary : AppColors.inputBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SET ${setIdx + 1}',
                    style: AppTextStyles.sectionTitle.copyWith(
                        fontSize: 12, color: AppColors.primary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${set.reps} REPS',
                        style: AppTextStyles.label.copyWith(fontSize: 10)),
                    const SizedBox(width: 12),
                    Text('${set.weight.toStringAsFixed(set.weight % 1 == 0 ? 0 : 1)} KG',
                        style: AppTextStyles.label.copyWith(fontSize: 10)),
                  ],
                ),
              ],
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: completed ? AppColors.primary : AppColors.cardBackground,
                shape: BoxShape.circle,
                border: Border.all(
                  color: completed ? AppColors.primary : AppColors.inputBorder,
                  width: 1.5,
                ),
              ),
              child: Icon(Icons.check_rounded,
                  color: completed ? Colors.white : AppColors.textSecondary,
                  size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestOverlay() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.inputBorder)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('REST PERIOD REMAINING',
                style: AppTextStyles.label.copyWith(
                    fontSize: 10, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Text(_formatTime(_restSecondsRemaining),
                style: GoogleFonts.oswald(
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _adjustButton(Icons.remove_rounded,
                    () => adjustRest(-15)),
                const SizedBox(width: 12),
                _adjustButton(Icons.add_rounded, () => adjustRest(15)),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => adjustRest(30),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.inputBorder),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  child: Text('+30S',
                      style: AppTextStyles.label.copyWith(fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: startNextSetManually,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('START NEXT SET', style: AppTextStyles.buttonText),
              ),
            ),
            const SizedBox(height: 8),
            Text('EARN YOUR SANCTUARY',
                style: AppTextStyles.forgotText.copyWith(
                    fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _adjustButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }

  // ── Phase 3: Pre-Set Countdown ────────────────────────────────────────────

  Widget _buildPreSetCountdown() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: const Icon(Icons.close_rounded,
                color: AppColors.textSecondary, size: 24),
            onPressed: _cancelSession,
          ),
        ),
        const Spacer(),
        Text(_currentExercise.exercise.name.toUpperCase(),
            style: AppTextStyles.label.copyWith(
                fontSize: 11, letterSpacing: 4, color: AppColors.textSecondary)),
        const SizedBox(height: 24),
        Text('$_countdownSeconds',
            style: GoogleFonts.oswald(
              fontSize: 140,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              shadows: [
                Shadow(
                    color: AppColors.primary.withValues(alpha: 0.8),
                    blurRadius: 30),
                Shadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 60),
              ],
            )),
        const SizedBox(height: 24),
        Text('PREPARE FOR WAR',
            style: AppTextStyles.heroHeading.copyWith(
                fontSize: 18, letterSpacing: 6)),
        const SizedBox(height: 16),
        Text('NEXT SET: ${_currentExercise.exercise.name}',
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        Text(
          'SET ${_currentSetIndex + 1} OF ${_currentExercise.sets.length}',
          style: AppTextStyles.forgotText.copyWith(fontSize: 12),
        ),
        const Spacer(),
      ],
    );
  }

  // ── Phase 4: Active Set ───────────────────────────────────────────────────

  Widget _buildActiveSet() {
    return Column(
      children: [
        _buildActiveSetTopBar(),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('CURRENTLY TRAINING',
                  style: AppTextStyles.label.copyWith(
                      fontSize: 10, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Text(_currentExercise.exercise.name.toUpperCase(),
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 18)),
              const SizedBox(height: 24),
              Text('${_currentSet.reps}',
                  style: GoogleFonts.oswald(
                    fontSize: 120,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  )),
              Text('REPS',
                  style: AppTextStyles.label.copyWith(
                      fontSize: 14, letterSpacing: 6)),
              const SizedBox(height: 28),
              _buildSetProgressBar(),
              const SizedBox(height: 32),
              _buildMotivationalQuote(),
            ],
          ),
        ),
        _buildActiveSetBottom(),
      ],
    );
  }

  Widget _buildActiveSetTopBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.inputBorder)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CURRENTLY TRAINING',
                  style: AppTextStyles.label.copyWith(fontSize: 9)),
              Text(_currentExercise.exercise.name.toUpperCase(),
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 14)),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close_rounded,
                color: AppColors.textSecondary, size: 24),
            onPressed: _cancelSession,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSetProgressBar() {
    final progress =
        (_currentSetIndex + 1) / _currentExercise.sets.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('RPE TARGET: 9',
                style: AppTextStyles.label.copyWith(fontSize: 10)),
            Text(
              'SET ${_currentSetIndex + 1}/${_currentExercise.sets.length}',
              style: AppTextStyles.forgotText.copyWith(fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.inputBorder,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationalQuote() {
    final quoteIdx = (_elapsedSessionSeconds ~/ 30) % _motivationalQuotes.length;
    final quote = _motivationalQuotes[quoteIdx];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: const Border(left: BorderSide(color: AppColors.primary, width: 3)),
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('"${quote.text}"',
              style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                  height: 1.6)),
          const SizedBox(height: 8),
          Text('— ${quote.author}',
              style: AppTextStyles.label.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildActiveSetBottom() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.inputBorder)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statChip('WEIGHT',
                  '${_currentSet.weight.toStringAsFixed(_currentSet.weight % 1 == 0 ? 0 : 1)} KG'),
              _statChip(
                  'LAST SET', _formatTime(_activeSetElapsedSeconds)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: finishSet,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('FINISH SET',
                  style:
                      AppTextStyles.buttonText.copyWith(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          Text(label,
              style: AppTextStyles.label.copyWith(
                  fontSize: 9, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value,
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 16)),
        ],
      ),
    );
  }

  // ── Phase 5: Completion Summary ───────────────────────────────────────────

  Widget _buildCompletionSummary() {
    final totalSets = _completedSets.expand((l) => l).length;
    final totalVolume = _workout.exercises.fold<double>(
      0,
      (sum, ex) => sum +
          ex.sets.fold<double>(
            0,
            (s, set) => s + (set.reps * set.weight),
          ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          const Icon(Icons.emoji_events_rounded,
              color: AppColors.primary, size: 64),
          const SizedBox(height: 16),
          Text('SESSION COMPLETE',
              style: AppTextStyles.heroHeading.copyWith(fontSize: 28)),
          const SizedBox(height: 8),
          Text('IRON NEVER FORGETS YOUR EFFORT',
              style: AppTextStyles.label.copyWith(fontSize: 10)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _completionStatChip(
                  'ELAPSED', _formatTime(_elapsedSessionSeconds)),
              _completionStatChip('TOTAL SETS', '$totalSets'),
              _completionStatChip('VOLUME', '${totalVolume.toStringAsFixed(0)} KG'),
            ],
          ),
          const SizedBox(height: 32),
          ..._workout.exercises.asMap().entries.map((e) =>
              _buildExerciseSummaryRow(e.key, e.value)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text('BACK TO LIBRARY', style: AppTextStyles.buttonText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _completionStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          Text(label,
              style: AppTextStyles.label.copyWith(
                  fontSize: 8, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(value,
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildExerciseSummaryRow(int exIdx, WorkoutExercise we) {
    final completed =
        _completedSets[exIdx].where((d) => d).length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(we.exercise.name,
                      style: AppTextStyles.sectionTitle.copyWith(fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(we.tag,
                      style: AppTextStyles.body.copyWith(fontSize: 10)),
                ],
              ),
            ),
            Text('$completed/${we.sets.length}',
                style: AppTextStyles.forgotText.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
