import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/exercise.dart';
import '../../data/models/workout.dart';
import '../../data/repositories/workout_repository.dart';
import '../widgets/exercise_picker_sheet.dart';

class _SetDraft {
  final TextEditingController repsCtrl;
  final TextEditingController weightCtrl;

  _SetDraft()
      : repsCtrl = TextEditingController(),
        weightCtrl = TextEditingController();

  void dispose() {
    repsCtrl.dispose();
    weightCtrl.dispose();
  }

  ExerciseSet toSet(int weId, int setNum) => ExerciseSet(
        workoutExerciseId: weId,
        setNumber: setNum,
        reps: int.tryParse(repsCtrl.text.trim()) ?? 0,
        weight: double.tryParse(weightCtrl.text.trim()) ?? 0.0,
      );
}

class _ExerciseDraft {
  final Exercise exercise;
  final String tag;
  final List<_SetDraft> sets;

  _ExerciseDraft(this.exercise, this.tag) : sets = [];

  void dispose() {
    for (final s in sets) {
      s.dispose();
    }
  }

  WorkoutExercise toWorkoutExercise(int orderIndex) => WorkoutExercise(
        workoutId: 0,
        exercise: exercise,
        orderIndex: orderIndex,
        tag: tag,
        sets: sets
            .asMap()
            .entries
            .map((e) => e.value.toSet(0, e.key + 1))
            .toList(),
      );
}

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _repo = WorkoutRepository();

  String _methodology = 'STRENGTH';
  final List<_ExerciseDraft> _exercises = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    for (final d in _exercises) {
      d.dispose();
    }
    super.dispose();
  }

  int get _estimatedDuration {
    if (_exercises.isEmpty) return 30;
    final totalSets =
        _exercises.fold<int>(0, (sum, d) => sum + d.sets.length);
    return totalSets == 0 ? _exercises.length * 15 : totalSets * 3;
  }

  Future<void> _openExercisePicker() async {
    final exercise = await showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExercisePickerSheet(
        excludeIds: _exercises.map((e) => e.exercise.id).toList(),
      ),
    );
    if (exercise != null) {
      setState(() {
        _exercises.add(_ExerciseDraft(exercise, exercise.autoTag));
      });
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showSnack('Please enter a session name');
      return;
    }
    if (_exercises.isEmpty) {
      _showSnack('Add at least one exercise');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final workout = Workout(
        name: name,
        methodology: _methodology,
        estimatedDuration: _estimatedDuration,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: DateTime.now(),
      );
      final exercisesForSave = _exercises
          .asMap()
          .entries
          .map((e) => e.value.toWorkoutExercise(e.key))
          .toList();
      await _repo.saveWorkout(workout, exercisesForSave);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showSnack('Failed to save workout');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.cardBackground,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSessionIdentity(),
                    const SizedBox(height: 28),
                    _buildMethodology(),
                    const SizedBox(height: 28),
                    _buildProtocol(),
                    const SizedBox(height: 28),
                    _buildEstDuration(),
                    const SizedBox(height: 28),
                    _buildSessionNotes(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(color: AppColors.inputBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text('CANCEL',
                style: AppTextStyles.label.copyWith(
                    fontSize: 12, color: AppColors.textPrimary)),
          ),
          const Spacer(),
          Text('NEW SESSION', style: AppTextStyles.screenTitle),
          const Spacer(),
          GestureDetector(
            onTap: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2))
                : Text('SAVE',
                    style: AppTextStyles.forgotText.copyWith(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ── Session Identity ──────────────────────────────────────────────────────

  Widget _buildSessionIdentity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SESSION IDENTITY', style: AppTextStyles.label),
        const SizedBox(height: 10),
        TextField(
          controller: _nameController,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
          decoration: InputDecoration(
            hintText: 'New Session',
            hintStyle: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.inputBorder,
              height: 1.2,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          textCapitalization: TextCapitalization.words,
          maxLines: 2,
          minLines: 1,
        ),
      ],
    );
  }

  // ── Methodology ───────────────────────────────────────────────────────────

  Widget _buildMethodology() {
    final options = [
      {'label': 'STRENGTH', 'icon': Icons.fitness_center_rounded},
      {'label': 'HYPERTROPHY', 'icon': Icons.bolt_rounded},
      {'label': 'CARDIO', 'icon': Icons.favorite_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('METHODOLOGY', style: AppTextStyles.label),
        const SizedBox(height: 12),
        Row(
          children: options.map((o) {
            final label = o['label'] as String;
            final icon = o['icon'] as IconData;
            final active = _methodology == label;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: o == options.last ? 0 : 10,
                ),
                child: GestureDetector(
                  onTap: () => setState(() => _methodology = label),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: active
                            ? AppColors.primary
                            : AppColors.inputBorder,
                        width: active ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(icon,
                            color: active
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 24),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          style: AppTextStyles.label.copyWith(
                            fontSize: 9,
                            color: active
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Protocol ─────────────────────────────────────────────────────────────

  Widget _buildProtocol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('PROTOCOL', style: AppTextStyles.label),
            if (_exercises.isNotEmpty)
              Text(
                '${_exercises.length} EXERCISE${_exercises.length == 1 ? '' : 'S'}',
                style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary, fontSize: 10),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_exercises.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _exercises.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = _exercises.removeAt(oldIndex);
                _exercises.insert(newIndex, item);
              });
            },
            itemBuilder: (context, i) => _buildExerciseRow(i),
          ),
        const SizedBox(height: 10),
        _buildAppendButton(),
      ],
    );
  }

  Widget _buildExerciseRow(int index) {
    final draft = _exercises[index];
    return Container(
      key: ValueKey(draft.exercise.id),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.inputBorder, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.drag_indicator_rounded,
                  color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(draft.exercise.name,
                        style: AppTextStyles.sectionTitle.copyWith(fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(draft.tag,
                        style: AppTextStyles.body.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () =>
                    setState(() {
                      draft.dispose();
                      _exercises.removeAt(index);
                    }),
                child: const Icon(Icons.close_rounded,
                    color: AppColors.textSecondary, size: 20),
              ),
            ],
          ),
          if (draft.sets.isNotEmpty) ...[
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text('SET',
                        style: AppTextStyles.sectionTitle.copyWith(fontSize: 11, color: AppColors.textSecondary)),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text('REPS',
                        style: AppTextStyles.sectionTitle.copyWith(fontSize: 11, color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 80,
                    child: Text('WEIGHT',
                        style: AppTextStyles.sectionTitle.copyWith(fontSize: 11, color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
            ...draft.sets.asMap().entries.map((e) => _buildSetRow(index, e.key, e.value)),
          ],
          const SizedBox(height: 12),
          _buildAddSetButton(index),
        ],
      ),
    );
  }

  Widget _buildSetRow(int exIdx, int setIdx, _SetDraft draft) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              'SET ${setIdx + 1}',
              style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: 14, color: AppColors.primary),
            ),
          ),
          _compactField(draft.repsCtrl, width: 70, hint: '0', isInt: true),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('×',
                style: AppTextStyles.sectionTitle.copyWith(
                    fontSize: 18, color: AppColors.textSecondary)),
          ),
          _compactField(draft.weightCtrl, width: 80, hint: '0', isInt: false),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text('KG',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 12)),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () =>
                setState(() {
                  draft.dispose();
                  _exercises[exIdx].sets.removeAt(setIdx);
                }),
            child: const Icon(Icons.close_rounded,
                color: AppColors.textSecondary, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _compactField(TextEditingController ctrl,
      {required double width,
      required String hint,
      required bool isInt}) {
    return SizedBox(
      width: width,
      height: 48,
      child: TextField(
        controller: ctrl,
        keyboardType: isInt
            ? TextInputType.number
            : const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body.copyWith(fontSize: 16),
          filled: true,
          fillColor: AppColors.cardBackground,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: AppColors.inputBorder, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildAddSetButton(int index) {
    return GestureDetector(
      onTap: () => setState(() => _exercises[index].sets.add(_SetDraft())),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.inputBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 6),
            Text('ADD SET',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 13, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppendButton() {
    return GestureDetector(
      onTap: _openExercisePicker,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded,
                color: AppColors.textSecondary, size: 18),
            const SizedBox(width: 8),
            Text('APPEND EXERCISE',
                style: AppTextStyles.label.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // ── Est. Duration ─────────────────────────────────────────────────────────

  Widget _buildEstDuration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('EST. DURATION', style: AppTextStyles.label),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.timer_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                '$_estimatedDuration min',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Session Notes ─────────────────────────────────────────────────────────

  Widget _buildSessionNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SESSION NOTES', style: AppTextStyles.label),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _notesController,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 13),
            maxLines: 3,
            minLines: 3,
            decoration: InputDecoration(
              hintText: 'Focus on controlled eccentrics...',
              hintStyle: AppTextStyles.body.copyWith(fontSize: 12),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 12, right: 8, top: 14),
                child: Icon(Icons.description_rounded,
                    color: AppColors.primary, size: 18),
              ),
              prefixIconConstraints: const BoxConstraints(),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.inputBorder)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5)),
              contentPadding: const EdgeInsets.fromLTRB(0, 14, 16, 14),
              filled: true,
              fillColor: AppColors.surface,
            ),
          ),
        ),
      ],
    );
  }
}
