import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../features/auth/data/repositories/auth_repository.dart';
import '../widgets/iron_button.dart';
import '../widgets/iron_text_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repository = AuthRepository();
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
      await _repository.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // TODO: navigate to home screen on success
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.cardBackground,
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
        SizedBox(
          height: 72,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.security_rounded, color: AppColors.primary, size: 68),
              Positioned(
                right: 80,
                top: 10,
                child: Icon(Icons.flight, color: AppColors.primary, size: 28),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text('IronLog', style: AppTextStyles.brandName),
        const SizedBox(height: 6),
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
          Text('ATHLETE EMAIL', style: AppTextStyles.label),
          const SizedBox(height: 8),
          IronTextField(
            controller: _emailController,
            hint: 'RANK_ONE@IRON.COM',
            prefixIcon: Icons.alternate_email,
            keyboardType: TextInputType.emailAddress,
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
      ],
    );
  }
}
