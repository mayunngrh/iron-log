import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/workout.dart';
import '../../data/repositories/workout_repository.dart';
import 'add_workout_screen.dart';
import '../../../start/presentation/screens/workout_session_screen.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final _repo = WorkoutRepository();
  final _searchController = TextEditingController();

  List<Workout> _workouts = [];
  List<Workout> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final workouts = await _repo.getAllWorkouts();
    setState(() {
      _workouts = workouts;
      _filtered = workouts;
      _loading = false;
    });
  }

  void _onSearch(String query) {
    setState(() {
      _filtered = query.isEmpty
          ? _workouts
          : _workouts
              .where((w) =>
                  w.name.toUpperCase().contains(query.toUpperCase()))
              .toList();
    });
  }

  Future<void> _goToAddWorkout() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddWorkoutScreen()),
    );
    if (saved == true) _load();
  }

  Future<void> _deleteWorkout(Workout workout) async {
    await _repo.deleteWorkout(workout.id!);
    _load();
  }

  void _startSession(Workout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WorkoutSessionScreen(workout: workout)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroBanner(),
                          const SizedBox(height: 16),
                          _buildSearchBar(),
                          const SizedBox(height: 16),
                          if (_workouts.isEmpty)
                            _buildEmptyState()
                          else if (_filtered.isEmpty)
                            _buildNoResults()
                          else ...[
                            ..._filtered.map((w) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildWorkoutCard(w),
                                )),
                            _buildAddFromCommunity(),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu_rounded,
                color: AppColors.textSecondary, size: 26),
            onPressed: () {},
          ),
          const Spacer(),
          Text('IRON SANCTUM', style: AppTextStyles.screenTitle),
          const Spacer(),
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

  // ── Hero Banner ───────────────────────────────────────────────────────────

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'WORKOUT\n',
                  style: AppTextStyles.heroHeading.copyWith(
                    fontSize: 36,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                TextSpan(
                  text: 'LIBRARY',
                  style: AppTextStyles.heroHeading.copyWith(
                    fontSize: 36,
                    color: AppColors.primary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_workouts.length} TOTAL SESSION${_workouts.length == 1 ? '' : 'S'} SAVED',
            style: AppTextStyles.label.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _goToAddWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              label: Text('CREATE NEW SESSION',
                  style: AppTextStyles.buttonText),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: _onSearch,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'SEARCH TEMPLATES...',
              hintStyle: AppTextStyles.label.copyWith(fontSize: 12),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.textSecondary, size: 20),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AppColors.inputBorder, width: 1)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: const Icon(Icons.tune_rounded,
              color: AppColors.textSecondary, size: 20),
        ),
      ],
    );
  }

  // ── Workout Card ──────────────────────────────────────────────────────────

  static const _methodologyIcons = {
    'STRENGTH': Icons.fitness_center_rounded,
    'HYPERTROPHY': Icons.bolt_rounded,
    'CARDIO': Icons.favorite_rounded,
    'RECOVERY': Icons.self_improvement_rounded,
  };

  Widget _buildWorkoutCard(Workout workout) {
    final icon = _methodologyIcons[workout.methodology] ??
        Icons.fitness_center_rounded;

    return Dismissible(
      key: ValueKey(workout.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 24),
      ),
      confirmDismiss: (_) async {
        return await _showDeleteConfirm(workout.name);
      },
      onDismissed: (_) => _deleteWorkout(workout),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 18),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    workout.methodology,
                    style: AppTextStyles.label.copyWith(fontSize: 9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(workout.name,
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 20)),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.fitness_center_rounded,
                    color: AppColors.textSecondary, size: 13),
                const SizedBox(width: 5),
                Text(
                  '${workout.exerciseCount} EXERCISE${workout.exerciseCount == 1 ? '' : 'S'}',
                  style: AppTextStyles.label.copyWith(fontSize: 10),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.timer_outlined,
                    color: AppColors.textSecondary, size: 13),
                const SizedBox(width: 5),
                Text(
                  '~${workout.estimatedDuration} MIN',
                  style: AppTextStyles.label.copyWith(fontSize: 10),
                ),
              ],
            ),
            if (workout.exercises.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(color: AppColors.inputBorder, height: 1),
              const SizedBox(height: 12),
              ...workout.exercises.map((we) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          we.exercise.name,
                          style: AppTextStyles.sectionTitle.copyWith(
                              fontSize: 13, color: AppColors.textPrimary),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: CustomPaint(
                              painter: _DottedLinePainter(),
                              size: const Size(double.infinity, 1),
                            ),
                          ),
                        ),
                        Text(
                          '${we.sets.length} set${we.sets.length == 1 ? '' : 's'}',
                          style: AppTextStyles.label.copyWith(
                              fontSize: 11, color: AppColors.primary),
                        ),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                onPressed: () => _startSession(workout),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: AppColors.inputBorder, width: 1),
                  backgroundColor: AppColors.cardBackground,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('START SESSION',
                    style: AppTextStyles.buttonText.copyWith(fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirm(String name) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete Workout',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 16)),
        content: Text('Remove "$name" from your library?',
            style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCEL', style: AppTextStyles.label),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('DELETE',
                style: AppTextStyles.forgotText.copyWith(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ── Empty / No-Results States ─────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.fitness_center_rounded,
              color: AppColors.textSecondary, size: 48),
          const SizedBox(height: 16),
          Text('NO WORKOUTS YET', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          Text('Tap CREATE NEW SESSION to start',
              style: AppTextStyles.body),
          const SizedBox(height: 32),
          _buildAddFromCommunity(),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded,
                color: AppColors.textSecondary, size: 40),
            const SizedBox(height: 12),
            Text('NO RESULTS FOUND', style: AppTextStyles.label),
          ],
        ),
      ),
    );
  }

  Widget _buildAddFromCommunity() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          children: [
            const Icon(Icons.add_rounded,
                color: AppColors.textSecondary, size: 28),
            const SizedBox(height: 6),
            Text('ADD FROM COMMUNITY',
                style: AppTextStyles.label.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.inputBorder
      ..strokeWidth = 1;

    const dashWidth = 3.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DottedLinePainter oldDelegate) => false;
}
