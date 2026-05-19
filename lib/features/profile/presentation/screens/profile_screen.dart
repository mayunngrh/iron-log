import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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

  void _showPhotoSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Select Photo Source', style: AppTextStyles.sectionTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text('Take Photo', style: AppTextStyles.body),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: Text('Choose from Gallery', style: AppTextStyles.body),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    _saveProfilePhoto(pickedFile);
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    _saveProfilePhoto(pickedFile);
  }

  Future<void> _saveProfilePhoto(XFile? pickedFile) async {
    if (pickedFile != null && _userStats != null) {
      final updatedStats = UserStats(
        id: _userStats!.id,
        username: _userStats!.username,
        firstName: _userStats!.firstName,
        lastName: _userStats!.lastName,
        level: _userStats!.level,
        totalExp: _userStats!.totalExp,
        createdAt: _userStats!.createdAt,
        height: _userStats!.height,
        weight: _userStats!.weight,
        age: _userStats!.age,
        gender: _userStats!.gender,
        bodyFatPercentage: _userStats!.bodyFatPercentage,
        fitnessGoal: _userStats!.fitnessGoal,
        profilePhotoPath: pickedFile.path,
      );

      await _userStatsRepository.updateUserStats(updatedStats);
      setState(() => _userStats = updatedStats);
    }
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
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildBodyMetricsCard(),
                    const SizedBox(height: 24),
                    _buildStatsCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface.withValues(alpha: 0.8),
            AppColors.background,
          ],
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.inputBorder, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _userStats?.profilePhotoPath != null
                      ? Image.file(
                          File(_userStats!.profilePhotoPath!),
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppColors.inputBackground,
                          child: const Icon(
                            Icons.person_rounded,
                            size: 70,
                            color: AppColors.textSecondary,
                          ),
                        ),
                ),
              ),
              GestureDetector(
                onTap: _showPhotoSourceDialog,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    border: Border.all(color: AppColors.background, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _userStats != null
                ? '${_userStats!.firstName} ${_userStats!.lastName}'.toUpperCase()
                : 'USER PROFILE',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary, width: 0.5),
                ),
                child: Text(
                  'LEVEL ${_userStats?.level ?? 1}',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB800).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFB800), width: 0.5),
                ),
                child: Text(
                  '${_userStats?.totalExp ?? 0} EXP',
                  style: AppTextStyles.label.copyWith(
                    color: const Color(0xFFFFB800),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
  late int _selectedHeight;
  late int _selectedWeight;
  late int _selectedAge;
  late TextEditingController _bodyFatController;

  late FixedExtentScrollController _heightController;
  late FixedExtentScrollController _weightController;
  late FixedExtentScrollController _ageController;

  Gender? _selectedGender;
  FitnessGoal? _selectedGoal;

  @override
  void initState() {
    super.initState();
    _selectedHeight = (widget.userStats?.height?.toInt() ?? 170);
    _selectedWeight = (widget.userStats?.weight?.toInt() ?? 70);
    _selectedAge = (widget.userStats?.age ?? 25);

    _heightController = FixedExtentScrollController(initialItem: _selectedHeight - 120);
    _weightController = FixedExtentScrollController(initialItem: _selectedWeight - 40);
    _ageController = FixedExtentScrollController(initialItem: _selectedAge - 15);

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
      height: _selectedHeight.toDouble(),
      weight: _selectedWeight.toDouble(),
      age: _selectedAge,
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('EDIT BODY METRICS', style: AppTextStyles.sectionTitle),
                IconButton(
                  icon: const Icon(Icons.keyboard_hide, color: AppColors.textSecondary),
                  onPressed: () => FocusScope.of(context).unfocus(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildNumberPicker('Height (cm)', _selectedHeight, 120, 220, _heightController),
            const SizedBox(height: 12),
            _buildWeightPicker('Weight (kg)', _selectedWeight, _weightController),
            const SizedBox(height: 12),
            _buildNumberPicker('Age', _selectedAge, 15, 100, _ageController),
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
      ),
    );
  }

  Widget _buildNumberPicker(
    String label,
    int value,
    int min,
    int max,
    FixedExtentScrollController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.inputBorder, width: 0.5),
          ),
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 40,
            diameterRatio: 1.2,
            onSelectedItemChanged: (index) {
              setState(() {
                if (label.contains('Height')) {
                  _selectedHeight = min + index;
                } else if (label.contains('Age')) {
                  _selectedAge = min + index;
                }
              });
            },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                final itemValue = min + index;
                final isSelected = itemValue == value;
                return Center(
                  child: Text(
                    '$itemValue',
                    style: AppTextStyles.body.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: isSelected ? 18 : 16,
                    ),
                  ),
                );
              },
              childCount: max - min + 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightPicker(
    String label,
    int value,
    FixedExtentScrollController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.inputBorder, width: 0.5),
          ),
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 40,
            diameterRatio: 1.2,
            onSelectedItemChanged: (index) {
              setState(() {
                _selectedWeight = 40 + index;
              });
            },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                final itemValue = 40 + index;
                final isSelected = itemValue == value;
                return Center(
                  child: Text(
                    '$itemValue',
                    style: AppTextStyles.body.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: isSelected ? 18 : 16,
                    ),
                  ),
                );
              },
              childCount: 61,
            ),
          ),
        ),
      ],
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
            suffixIcon: IconButton(
              icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
              onPressed: () => FocusScope.of(context).unfocus(),
            ),
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
