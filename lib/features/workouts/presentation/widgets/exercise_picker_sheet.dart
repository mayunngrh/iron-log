import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/exercise.dart';
import '../../data/repositories/workout_repository.dart';

class ExercisePickerSheet extends StatefulWidget {
  final List<int> excludeIds;

  const ExercisePickerSheet({super.key, this.excludeIds = const []});

  @override
  State<ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<ExercisePickerSheet> {
  final _repo = WorkoutRepository();
  final _searchController = TextEditingController();

  List<Exercise> _all = [];
  List<Exercise> _filtered = [];
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
    final all = await _repo.getAllExercises();
    final filtered = all.where((e) => !widget.excludeIds.contains(e.id)).toList();
    setState(() {
      _all = filtered;
      _filtered = filtered;
      _loading = false;
    });
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _all;
      } else {
        _filtered = _all
            .where((e) => e.name.contains(query.toUpperCase()))
            .toList();
      }
    });
  }

  Map<String, List<Exercise>> get _grouped {
    final map = <String, List<Exercise>>{};
    for (final e in _filtered) {
      map.putIfAbsent(e.muscleGroup, () => []).add(e);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(),
              _buildSearch(),
              const Divider(color: AppColors.inputBorder, height: 1),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary))
                    : _filtered.isEmpty
                        ? _buildEmpty()
                        : _buildList(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.inputBorder,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
      child: Row(
        children: [
          Text('SELECT EXERCISE', style: AppTextStyles.sectionTitle),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close_rounded,
                color: AppColors.textSecondary),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearch,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'SEARCH EXERCISES...',
          hintStyle: AppTextStyles.label.copyWith(fontSize: 12),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textSecondary, size: 20),
          filled: true,
          fillColor: AppColors.inputBackground,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.inputBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5)),
        ),
      ),
    );
  }

  Widget _buildList(ScrollController controller) {
    final groups = _grouped;
    final keys = groups.keys.toList();

    return ListView.builder(
      controller: controller,
      itemCount: keys.length,
      itemBuilder: (context, i) {
        final group = keys[i];
        final exercises = groups[group]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                group.toUpperCase(),
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontSize: 10,
                ),
              ),
            ),
            ...exercises.map((e) => _buildExerciseTile(e)),
          ],
        );
      },
    );
  }

  Widget _buildExerciseTile(Exercise exercise) {
    return InkWell(
      onTap: () => Navigator.pop(context, exercise),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(color: AppColors.inputBorder, width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.fitness_center_rounded,
                  color: AppColors.primary, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.name,
                      style: AppTextStyles.sectionTitle
                          .copyWith(fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(exercise.autoTag,
                      style: AppTextStyles.body.copyWith(fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.add_rounded,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded,
              color: AppColors.textSecondary, size: 40),
          const SizedBox(height: 12),
          Text('NO EXERCISES FOUND', style: AppTextStyles.label),
        ],
      ),
    );
  }
}
