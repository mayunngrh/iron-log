import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/models/user_stats.dart';
import '../../../../core/repositories/user_stats_repository.dart';
import '../../../history/data/repositories/session_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userStatsRepository = UserStatsRepository();
  final _sessionRepository = SessionRepository();

  UserStats? _userStats;
  int _totalSessions = 0;
  double _totalVolume = 0;
  int _totalReps = 0;
  int _totalSets = 0;
  bool _loading = true;

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
      final allSessions = await _sessionRepository.getAllSessions();

      int totalReps = 0;
      int totalSets = 0;
      double totalVolume = 0;

      for (final session in allSessions) {
        totalVolume += session.totalWeightLifted;
        totalSets += session.totalSetsCompleted;
        for (final exercise in session.exercises) {
          totalReps += exercise.totalReps;
        }
      }

      setState(() {
        _userStats = userStats;
        _totalSessions = allSessions.length;
        _totalVolume = totalVolume;
        _totalReps = totalReps;
        _totalSets = totalSets;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading profile data: $e');
      setState(() => _loading = false);
    }
  }

  void _showEditMetricsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _EditMetricsSheet(
        userStats: _userStats,
        onSave: (updatedStats) {
          _userStatsRepository.updateUserStats(updatedStats);
          setState(() => _userStats = updatedStats);
          Navigator.pop(context);
        },
      ),
    );
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildBodyMetricsCard(),
              const SizedBox(height: 24),
              _buildStatsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final rankColor = _getRankColor(_userStats?.getRank() ?? Rank.bronze);
    final rankLabel = _userStats?.getRank().label ?? 'BRONZE';

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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.inputBorder, width: 1.5),
                ),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.textSecondary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_userStats?.firstName} ${_userStats?.lastName}'
                          .toUpperCase(),
                      style: AppTextStyles.sectionTitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$rankLabel • LVL ${_userStats?.level}',
                      style: AppTextStyles.label.copyWith(color: rankColor),
                    ),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.security_rounded, color: rankColor, size: 32),
                  const Icon(Icons.bolt, color: Colors.white, size: 14),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildExpProgressBar(),
        ],
      ),
    );
  }

  Widget _buildExpProgressBar() {
    final expProgress = _userStats?.getExpProgress() ?? 0;
    final expNeeded = _userStats?.getExpNeededForNextLevel() ?? 1;
    final progressPercent = expNeeded > 0 ? expProgress / expNeeded : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('LEVEL ${_userStats?.level} PROGRESS',
                style: AppTextStyles.label),
            Text('$expProgress / $expNeeded EXP',
                style:
                    AppTextStyles.label.copyWith(color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progressPercent.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: AppColors.inputBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildBodyMetricsCard() {
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
              Text('BODY METRICS', style: AppTextStyles.sectionTitle),
              IconButton(
                onPressed: _showEditMetricsSheet,
                icon:
                    const Icon(Icons.edit_outlined, color: AppColors.primary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_userStats?.height != null || _userStats?.weight != null)
            Column(
              children: [
                if (_userStats?.height != null)
                  _buildMetricRow('Height', '${_userStats!.height!.toInt()} cm'),
                if (_userStats?.weight != null)
                  _buildMetricRow('Weight', '${_userStats!.weight!.toStringAsFixed(1)} kg'),
                if (_userStats?.bmi != null)
                  _buildMetricRow(
                    'BMI',
                    '${_userStats!.bmi!.toStringAsFixed(1)} ${_userStats!.bmiCategory}',
                    valueColor: _getBmiColor(_userStats!.bmiCategory),
                  ),
              ],
            )
          else
            Text('No body metrics added yet',
                style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.7))),
          const SizedBox(height: 12),
          if (_userStats?.age != null || _userStats?.gender != null)
            Column(
              children: [
                if (_userStats?.age != null)
                  _buildMetricRow('Age', '${_userStats!.age} years'),
                if (_userStats?.gender != null)
                  _buildMetricRow('Gender', _userStats!.gender!.label),
              ],
            ),
          const SizedBox(height: 12),
          if (_userStats?.bodyFatPercentage != null)
            _buildMetricRow(
                'Body Fat', '${_userStats!.bodyFatPercentage!.toStringAsFixed(1)}%'),
          if (_userStats?.fitnessGoal != null)
            _buildMetricRow('Goal', _userStats!.fitnessGoal!.label),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.label),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
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
          Text('CAREER STATS', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  label: 'SESSIONS',
                  value: _totalSessions.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  label: 'VOLUME',
                  value: '${_totalVolume.toStringAsFixed(0)} KG',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  label: 'REPS',
                  value: _totalReps.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  label: 'SETS',
                  value: _totalSets.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder, width: 0.5),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              )),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.label.copyWith(fontSize: 9)),
        ],
      ),
    );
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

  Color _getBmiColor(String? category) {
    if (category == null) return AppColors.textSecondary;
    switch (category) {
      case 'UNDERWEIGHT':
        return const Color(0xFF2196F3);
      case 'NORMAL':
        return const Color(0xFF4CAF50);
      case 'OVERWEIGHT':
        return const Color(0xFFFFC107);
      case 'OBESE':
        return const Color(0xFFF44336);
      default:
        return AppColors.textSecondary;
    }
  }
}

class _EditMetricsSheet extends StatefulWidget {
  final UserStats? userStats;
  final Function(UserStats) onSave;

  const _EditMetricsSheet({required this.userStats, required this.onSave});

  @override
  State<_EditMetricsSheet> createState() => _EditMetricsSheetState();
}

class _EditMetricsSheetState extends State<_EditMetricsSheet> {
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;
  late TextEditingController _bodyFatController;

  Gender? _selectedGender;
  FitnessGoal? _selectedGoal;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController(
      text: widget.userStats?.height?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: widget.userStats?.weight?.toString() ?? '',
    );
    _ageController = TextEditingController(
      text: widget.userStats?.age?.toString() ?? '',
    );
    _bodyFatController = TextEditingController(
      text: widget.userStats?.bodyFatPercentage?.toString() ?? '',
    );
    _selectedGender = widget.userStats?.gender;
    _selectedGoal = widget.userStats?.fitnessGoal;
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _bodyFatController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final stats = widget.userStats;
    if (stats == null) return;

    final height =
        _heightController.text.isEmpty ? null : double.tryParse(_heightController.text);
    final weight =
        _weightController.text.isEmpty ? null : double.tryParse(_weightController.text);
    final age = _ageController.text.isEmpty ? null : int.tryParse(_ageController.text);
    final bodyFat = _bodyFatController.text.isEmpty
        ? null
        : double.tryParse(_bodyFatController.text);

    final updatedStats = UserStats(
      id: stats.id,
      username: stats.username,
      firstName: stats.firstName,
      lastName: stats.lastName,
      level: stats.level,
      totalExp: stats.totalExp,
      createdAt: stats.createdAt,
      height: height,
      weight: weight,
      age: age,
      gender: _selectedGender,
      bodyFatPercentage: bodyFat,
      fitnessGoal: _selectedGoal,
    );

    widget.onSave(updatedStats);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('EDIT BODY METRICS', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 16),
          _buildTextField('Height (cm)', _heightController),
          const SizedBox(height: 12),
          _buildTextField('Weight (kg)', _weightController),
          const SizedBox(height: 12),
          _buildTextField('Age', _ageController),
          const SizedBox(height: 12),
          _buildGenderSelector(),
          const SizedBox(height: 12),
          _buildTextField('Body Fat %', _bodyFatController),
          const SizedBox(height: 12),
          _buildGoalSelector(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.inputBorder),
                  ),
                  child: Text('CANCEL', style: AppTextStyles.label),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text('SAVE',
                      style: AppTextStyles.label.copyWith(
                          color: Colors.white, letterSpacing: 2)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.5)),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.inputBorder, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.inputBorder, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Row(
          children: Gender.values.map((gender) {
            final isSelected = _selectedGender == gender;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(gender.label),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(
                        () => _selectedGender = selected ? gender : null);
                  },
                  backgroundColor: AppColors.inputBackground,
                  selectedColor: AppColors.primary,
                  labelStyle: AppTextStyles.label.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 10,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.inputBorder,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGoalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fitness Goal', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: FitnessGoal.values.map((goal) {
            final isSelected = _selectedGoal == goal;
            return ChoiceChip(
              label: Text(goal.label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedGoal = selected ? goal : null);
              },
              backgroundColor: AppColors.inputBackground,
              selectedColor: AppColors.primary,
              labelStyle: AppTextStyles.label.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 10,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.inputBorder,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
