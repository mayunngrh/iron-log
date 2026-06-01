import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../features/auth/data/repositories/auth_repository.dart';
import '../widgets/iron_button.dart';
import 'login_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String username;
  final String firstName;
  final String lastName;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late List<TextEditingController> _otpControllers;
  late List<FocusNode> _focusNodes;
  final _repository = AuthRepository();
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleOtpInput(int index, String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    // Multiple digits means a paste (or autofill) — distribute across boxes.
    if (digits.length > 1) {
      _distributeDigits(index, digits);
      return;
    }

    if (value.isEmpty) return;

    // Keep only the single digit in this box.
    if (_otpControllers[index].text != digits) {
      _otpControllers[index].value = TextEditingValue(
        text: digits,
        selection: TextSelection.collapsed(offset: digits.length),
      );
    }

    if (index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else {
      FocusScope.of(context).unfocus();
      _handleVerifyOtp();
    }
  }

  void _distributeDigits(int startIndex, String digits) {
    for (int i = 0; i < 6; i++) {
      final digitIndex = i - startIndex;
      if (digitIndex >= 0 && digitIndex < digits.length) {
        _otpControllers[i].text = digits[digitIndex];
      }
    }

    final filledUpTo = startIndex + digits.length;
    if (filledUpTo >= 6) {
      FocusScope.of(context).unfocus();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _handleVerifyOtp();
      });
    } else {
      _focusNodes[filledUpTo].requestFocus();
    }
  }

  String _getOtpCode() {
    return _otpControllers.map((c) => c.text).join();
  }

  Future<void> _handleVerifyOtp() async {
    final otpCode = _getOtpCode();

    if (otpCode.length != 6) {
      _showSnack('Please enter all 6 digits');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _repository.verifyOtp(
        email: widget.email,
        otpCode: otpCode,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_username', widget.username);

        // 'data' may be a Map (with a token) or just a String message.
        final data = response['data'];
        if (data is Map && data['token'] != null) {
          await prefs.setString('auth_token', data['token'].toString());
        }

        if (mounted) {
          _showSnack('OTP verified successfully! Please sign in.');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } else {
        _showSnack(response['message'] ?? 'OTP verification failed');
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleResendOtp() async {
    setState(() => _isResending = true);
    try {
      final response = await _repository.resendOtp(email: widget.email);

      if (!mounted) return;

      if (response['success'] == true) {
        _showSnack('OTP resent to ${widget.email}');
        setState(() => _resendCountdown = 60);
        _startCountdown();
        _clearOtpFields();
      } else {
        _showSnack(response['message'] ?? 'Failed to resend OTP');
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _clearOtpFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCountdown > 0) {
        setState(() => _resendCountdown--);
        _startCountdown();
      }
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                      child: Center(
                        child: Text(
                          'OTP',
                          style: AppTextStyles.sectionTitle.copyWith(
                            fontSize: 20,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Verify OTP',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter the 6-digit code sent to ${widget.email}',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    6,
                    (index) => SizedBox(
                      width: 50,
                      height: 60,
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.sectionTitle.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.all(8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.inputBorder,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.inputBorder,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          _handleOtpInput(index, value);
                        },
                        onSubmitted: (_) {
                          if (index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                IronButton(
                  label: 'Verify OTP',
                  onPressed: _handleVerifyOtp,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Didn't receive code?",
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_resendCountdown > 0)
                        Text(
                          'Resend in ${_resendCountdown}s',
                          style: AppTextStyles.label.copyWith(
                            fontSize: 12,
                            color: AppColors.primary.withValues(alpha: 0.6),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: _isResending ? null : _handleResendOtp,
                          child: Text(
                            'Resend OTP',
                            style: AppTextStyles.label.copyWith(
                              fontSize: 12,
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Already verified? ',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: AppTextStyles.label.copyWith(
                            fontSize: 12,
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
