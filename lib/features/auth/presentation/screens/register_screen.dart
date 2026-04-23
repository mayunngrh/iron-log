import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../features/auth/data/models/register_request.dart';
import '../../../../features/auth/data/repositories/auth_repository.dart';
import '../widgets/iron_button.dart';
import '../widgets/iron_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _repository = AuthRepository();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showSnack('Please fill in all fields');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnack('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _repository.register(
        RegisterRequest(
          email: _emailController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          password: _passwordController.text,
          username: _usernameController.text.trim(),
        ),
      );
      if (mounted) Navigator.pop(context);
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('IronLog', style: AppTextStyles.screenTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildHeroSection(),
            const SizedBox(height: 32),
            _buildForm(),
            const SizedBox(height: 24),
            _buildFooter(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 110,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            gradient: const RadialGradient(
              center: Alignment.topCenter,
              radius: 1.2,
              colors: [Color(0xFF3A1010), AppColors.surface],
            ),
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/logo_icon.png',
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('ASCEND YOUR LIMITS', style: AppTextStyles.heroHeading),
        const SizedBox(height: 6),
        Text('FORGE YOUR LEGACY IN IRON', style: AppTextStyles.heroSubtitle),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FIRST NAME', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  IronTextField(
                    controller: _firstNameController,
                    hint: 'FIRST NAME',
                    keyboardType: TextInputType.name,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LAST NAME', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  IronTextField(
                    controller: _lastNameController,
                    hint: 'LAST NAME',
                    keyboardType: TextInputType.name,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('IRON CALLSIGN', style: AppTextStyles.label),
        const SizedBox(height: 8),
        IronTextField(controller: _usernameController, hint: 'USERNAME'),
        const SizedBox(height: 16),
        Text('DIGITAL SIGNAL', style: AppTextStyles.label),
        const SizedBox(height: 8),
        IronTextField(
          controller: _emailController,
          hint: 'EMAIL ADDRESS',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        Text('SANCTUM KEY', style: AppTextStyles.label),
        const SizedBox(height: 8),
        IronTextField(
          controller: _passwordController,
          hint: 'PASSWORD',
          obscureText: _obscurePassword,
          suffixIcon: _obscurePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          onSuffixTap: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
        const SizedBox(height: 16),
        Text('CONFIRM KEY', style: AppTextStyles.label),
        const SizedBox(height: 8),
        IronTextField(
          controller: _confirmPasswordController,
          hint: 'CONFIRM PASSWORD',
          obscureText: _obscureConfirm,
          suffixIcon: _obscureConfirm
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          onSuffixTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
        ),
        const SizedBox(height: 28),
        IronButton(
          label: 'CREATE ACCOUNT',
          isLoading: _isLoading,
          onPressed: _handleRegister,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account? ', style: AppTextStyles.body),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text('LOGIN', style: AppTextStyles.forgotText),
        ),
      ],
    );
  }
}
