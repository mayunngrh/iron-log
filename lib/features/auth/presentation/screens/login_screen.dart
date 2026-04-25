import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/repositories/user_stats_repository.dart';
import '../../../../features/auth/data/repositories/auth_repository.dart';
import '../widgets/iron_button.dart';
import '../widgets/iron_text_field.dart';
import 'register_screen.dart';
import '../../../main/presentation/screens/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repository = AuthRepository();
  final _userStatsRepository = UserStatsRepository();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnack('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final identifier = _emailController.text.trim();

      await _repository.login(
        identifier: identifier,
        password: _passwordController.text,
      );

      // Store username for later use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_username', identifier);

      // Create/update user stats locally with hardcoded name for now
      final existingStats = await _userStatsRepository.getUserStats(identifier);
      if (existingStats == null) {
        await _userStatsRepository.createUserStats(
          username: identifier,
          firstName: 'Mayun',
          lastName: 'Suryatama',
        );
      }

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      String errorMessage = 'Login failed';
      if (e is ApiException) {
        final statusText = _getStatusCodeText(e.statusCode);
        errorMessage = '$statusText : ${e.message}';
      }
      if (mounted) {
        _showSnack(errorMessage);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getStatusCodeText(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 409:
        return 'Conflict';
      case 422:
        return 'Unprocessable Entity';
      case 429:
        return 'Too Many Requests';
      case 500:
        return 'Server Error';
      case 502:
        return 'Bad Gateway';
      case 503:
        return 'Service Unavailable';
      default:
        return 'Error';
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppColors.cardBackground,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 48),
              _buildLogo(),
              const SizedBox(height: 36),
              _buildFormCard(),
              const SizedBox(height: 28),
              _buildFooter(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo_icon.png',
          height: 80,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 12),
        Text('FORGE YOUR LEGACY', style: AppTextStyles.tagline),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text('ENTER THE SANCTUM', style: AppTextStyles.sectionTitle),
            ],
          ),
          const SizedBox(height: 24),
          Text('EMAIL OR USERNAME', style: AppTextStyles.label),
          const SizedBox(height: 8),
          IronTextField(
            controller: _emailController,
            hint: 'ENTER EMAIL OR USERNAME',
            prefixIcon: Icons.person_rounded,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PASSKEY', style: AppTextStyles.label),
              GestureDetector(
                onTap: () {},
                child: Text('FORGOT?', style: AppTextStyles.forgotText),
              ),
            ],
          ),
          const SizedBox(height: 8),
          IronTextField(
            controller: _passwordController,
            hint: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            suffixIcon: _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            onSuffixTap: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
          const SizedBox(height: 24),
          IronButton(
            label: 'LOGIN',
            isLoading: _isLoading,
            onPressed: _handleLogin,
          ),
          const SizedBox(height: 22),
          _buildDivider(),
          const SizedBox(height: 22),
          IronOutlinedButton(
            label: 'CONTINUE WITH GOOGLE',
            onPressed: () {},
            leadingWidget: _googleLogo(),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('OR', style: AppTextStyles.label),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }

  Widget _googleLogo() {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Color(0xFF4285F4),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Don't have an account? ", style: AppTextStyles.body),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: Text('Sign Up', style: AppTextStyles.bodyBold),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('PRIVACY', style: AppTextStyles.footerLink),
            const SizedBox(width: 20),
            Text('TERMS', style: AppTextStyles.footerLink),
            const SizedBox(width: 20),
            Text('SUPPORT', style: AppTextStyles.footerLink),
          ],
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.inputBorder),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bug_report_outlined,
                    color: AppColors.textSecondary, size: 14),
                const SizedBox(width: 6),
                Text('DEBUG — SKIP TO HOME', style: AppTextStyles.footerLink),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
