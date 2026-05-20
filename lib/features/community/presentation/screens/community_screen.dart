import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/models/shared_session.dart';
import '../../../../core/repositories/shared_session_repository.dart';
import '../../../../core/repositories/user_follow_repository.dart';
import '../../../../core/repositories/session_like_repository.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _sharedSessionRepository = SharedSessionRepository();
  late final SessionLikeRepository _sessionLikeRepository;
  final _searchController = TextEditingController();

  List<SharedSession> _sessions = [];
  List<SharedSession> _filteredSessions = [];
  bool _loading = true;
  String _currentUsername = '';
  Map<int, bool> _likedSessions = {};
  Map<int, int> _likeCounts = {};

  @override
  void initState() {
    super.initState();
    _sessionLikeRepository = SessionLikeRepository();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('current_username') ?? '';
    setState(() => _currentUsername = username);
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      final sessions = await _sharedSessionRepository.getAllSharedSessions();

      final likedMap = <int, bool>{};
      final likeCountMap = <int, int>{};

      for (final session in sessions) {
        if (session.id != null) {
          likedMap[session.id!] =
              await _sessionLikeRepository.isLiked(session.id!, _currentUsername);
          likeCountMap[session.id!] =
              await _sessionLikeRepository.getLikeCount(session.id!);
        }
      }

      if (mounted) {
        setState(() {
          _sessions = sessions;
          _filteredSessions = sessions;
          _likedSessions = likedMap;
          _likeCounts = likeCountMap;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
      debugPrint('Error loading sessions: $e');
    }
  }

  void _filterSessions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSessions = _sessions;
      } else {
        _filteredSessions = _sessions
            .where((s) =>
                s.workoutName.toLowerCase().contains(query.toLowerCase()) ||
                s.userDisplayName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _toggleLike(SharedSession session) async {
    if (session.id == null) return;

    final isLiked = _likedSessions[session.id] ?? false;

    try {
      if (isLiked) {
        await _sessionLikeRepository.unlikeSession(session.id!, _currentUsername);
      } else {
        await _sessionLikeRepository.likeSession(session.id!, _currentUsername);
      }

      final newCount = await _sessionLikeRepository.getLikeCount(session.id!);

      if (mounted) {
        setState(() {
          _likedSessions[session.id!] = !isLiked;
          _likeCounts[session.id!] = newCount;
        });
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _filterSessions,
                decoration: InputDecoration(
                  hintText: 'Search workouts or users...',
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredSessions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fitness_center_rounded,
                                size: 64,
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No sessions yet',
                                style: AppTextStyles.sectionTitle,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Be the first to share your workout!',
                                style: AppTextStyles.body,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredSessions.length,
                          itemBuilder: (context, index) =>
                              _buildSessionCard(_filteredSessions[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(SharedSession session) {
    final isLiked = _likedSessions[session.id] ?? false;
    final likeCount = _likeCounts[session.id] ?? 0;
    final hasPhoto = session.sessionPhotoPath != null && session.sessionPhotoPath!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 110,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              color: AppColors.cardBackground,
            ),
            child: hasPhoto
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: Image.file(
                      File(session.sessionPhotoPath!),
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.fitness_center_rounded,
                    size: 50,
                    color: AppColors.primary.withValues(alpha: 0.6),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.workoutName.toUpperCase(),
                        style: AppTextStyles.sectionTitle.copyWith(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'by ${session.userDisplayName}',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 10,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          session.methodology ?? 'WORKOUT',
                          style: AppTextStyles.label.copyWith(
                            fontSize: 8,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatItem('Duration', session.formattedDuration),
                          _StatItem('Volume', '${session.totalWeightLifted.toInt()} kg'),
                          _StatItem('Sets', '${session.totalSetsCompleted}'),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () => _showSessionDetail(session),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                          ),
                          child: const Text(
                            'See Detail',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () => _toggleLike(session),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLiked
                                ? AppColors.primary
                                : AppColors.cardBackground,
                            padding: EdgeInsets.zero,
                          ),
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isLiked ? Colors.white : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        likeCount.toString(),
                        style: AppTextStyles.label.copyWith(fontSize: 9),
                      ),
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

  void _showSessionDetail(SharedSession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _SessionDetailSheet(session: session),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.background,
      child: Row(
        children: [
          const Icon(Icons.people_alt_rounded,
              color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Text(
            'COMMUNITY FEED',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            fontSize: 9,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

class _SessionDetailSheet extends StatefulWidget {
  final SharedSession session;

  const _SessionDetailSheet({required this.session});

  @override
  State<_SessionDetailSheet> createState() => _SessionDetailSheetState();
}

class _SessionDetailSheetState extends State<_SessionDetailSheet> {
  late UserFollowRepository _followRepository;
  late SessionLikeRepository _likeRepository;
  bool _isFollowing = false;
  bool _isLiked = false;
  int _likeCount = 0;
  String _currentUsername = '';

  @override
  void initState() {
    super.initState();
    _initRepositories();
    _loadData();
  }

  void _initRepositories() {
    _followRepository = UserFollowRepository();
    _likeRepository = SessionLikeRepository();
  }

  SharedSession get session => widget.session;

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUsername = prefs.getString('current_username') ?? '';

    if (session.id != null && _currentUsername.isNotEmpty && session.username != _currentUsername) {
      final isFollowing = await _followRepository.isFollowing(_currentUsername, session.username);
      final isLiked = await _likeRepository.isLiked(session.id!, _currentUsername);
      final likeCount = await _likeRepository.getLikeCount(session.id!);

      if (mounted) {
        setState(() {
          _isFollowing = isFollowing;
          _isLiked = isLiked;
          _likeCount = likeCount;
        });
      }
    }
  }

  Future<void> _toggleFollow() async {
    try {
      if (_isFollowing) {
        await _followRepository.unfollowUser(_currentUsername, session.username);
      } else {
        await _followRepository.followUser(_currentUsername, session.username);
      }

      if (mounted) {
        setState(() {
          _isFollowing = !_isFollowing;
        });
      }
    } catch (e) {
      debugPrint('Error toggling follow: $e');
    }
  }

  Future<void> _toggleLike() async {
    if (session.id == null) return;

    try {
      if (_isLiked) {
        await _likeRepository.unlikeSession(session.id!, _currentUsername);
      } else {
        await _likeRepository.likeSession(session.id!, _currentUsername);
      }

      final newCount = await _likeRepository.getLikeCount(session.id!);

      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
          _likeCount = newCount;
        });
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SESSION DETAILS',
                    style: AppTextStyles.sectionTitle,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.cardBackground,
                ),
                child: session.sessionPhotoPath != null && session.sessionPhotoPath!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(session.sessionPhotoPath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.fitness_center_rounded,
                        size: 80,
                        color: AppColors.primary.withValues(alpha: 0.6),
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                session.workoutName.toUpperCase(),
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: 4),
              Text(
                'by ${session.userDisplayName}',
                style: AppTextStyles.body
                    .copyWith(fontSize: 12, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  session.methodology ?? 'WORKOUT',
                  style: AppTextStyles.label.copyWith(
                    fontSize: 10,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'STATS',
                style: AppTextStyles.label
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _DetailStatBox('Duration', session.formattedDuration),
                  _DetailStatBox(
                      'Volume', '${session.totalWeightLifted.toInt()} kg'),
                  _DetailStatBox('Sets', '${session.totalSetsCompleted}'),
                ],
              ),
              const SizedBox(height: 20),
              if (session.description != null &&
                  session.description!.isNotEmpty) ...[
                Text(
                  'DESCRIPTION',
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  session.description!,
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 20),
              ],
              if (session.exercises.isNotEmpty) ...[
                Text(
                  'EXERCISES',
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                ...session.exercises.asMap().entries.map((entry) {
                  final exercise = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          exercise['name'] ?? 'Exercise',
                          style: AppTextStyles.body.copyWith(fontSize: 11),
                        ),
                        Text(
                          '${exercise['sets'] ?? 0} sets',
                          style: AppTextStyles.label.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
              ],
              if (_currentUsername.isNotEmpty && session.username != _currentUsername) ...[
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: _toggleFollow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFollowing
                                ? AppColors.primary
                                : AppColors.cardBackground,
                          ),
                          child: Text(
                            _isFollowing ? 'FOLLOWING' : 'FOLLOW',
                            style: TextStyle(
                              color: _isFollowing
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: _toggleLike,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isLiked
                                ? AppColors.primary
                                : AppColors.cardBackground,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 18,
                                color: _isLiked
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _likeCount.toString(),
                                style: TextStyle(
                                  color: _isLiked
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${session.workoutName} added to your workouts!'),
                        backgroundColor: AppColors.primary,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('ADD TO WORKOUTS'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailStatBox extends StatelessWidget {
  final String label;
  final String value;

  const _DetailStatBox(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                fontSize: 9,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
