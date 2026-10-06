import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../models/country_code.dart';
import '../widgets/rounded_phone_input.dart';
import '../../navigation/main_navigation_screen.dart';
import '../../../core/services/auth_service.dart';
import 'otp_verification_screen.dart';
import 'profile_setup_screen.dart';

/// Customer Sign Up Screen: Phone number, Send OTP, and Sign in with Google
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  CountryCode _selectedCountry = CountryCode.defaultCountry;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    final valid = _phoneController.text.trim().length >= 10;
    if (valid != _isValid) setState(() => _isValid = valid);
  }

  @override
  void dispose() {
    _phoneController
      ..removeListener(_onPhoneChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate sending OTP request
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _isLoading = false);

    final fullPhone = '${_selectedCountry.code} ${_phoneController.text.trim()}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(phoneNumber: fullPhone),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);

    UserModel? user;
    try {
      user = await AuthService.instance.signInWithGoogle();
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      if (!mounted) return;
      setState(() => _isGoogleLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Google Sign-In failed: ${e.toString().replaceAll('Exception:', '').trim()}',
          ),
          backgroundColor: const Color(0xFFB91C1C),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!mounted) return;

    if (user == null) {
      // User canceled Google account selection
      setState(() => _isGoogleLoading = false);
      return;
    }

    final validUser = user;
    final emailExists = await AuthService.instance.checkEmailExists(validUser.email);

    if (!mounted) return;
    setState(() => _isGoogleLoading = false);

    if (emailExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Signed in as ${validUser.displayName} (${validUser.email})',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1F1F1F),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      // Direct navigate to main screen if email exists
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } else {
      // Direct to profile setup page if email does not exist yet
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileSetupScreen(
            phoneNumber: validUser.phone ?? '',
            initialName: validUser.displayName,
            initialEmail: validUser.email,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.xl),
                // ── Logo ──────────────────────────────────────────────────
                Image.asset(
                  AppAssets.logo,
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (_, e, s) => const Icon(
                    Icons.home_repair_service_rounded,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Title & Subtitle ──────────────────────────────────────
                Text(AppStrings.signUpTitle, style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  AppStrings.signUpSubtitle,
                  style: AppTextStyles.bodyMd,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),

                // ── Rounded Phone Field ───────────────────────────────────
                RoundedPhoneInput(
                  controller: _phoneController,
                  selectedCountry: _selectedCountry,
                  onCountryChanged: (c) =>
                      setState(() => _selectedCountry = c),
                  validator: (v) {
                    if (v == null || v.trim().length < 10) {
                      return 'Enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Send OTP Button ───────────────────────────────────────
                GradientButton(
                  label: AppStrings.sendOtp,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleSendOtp,
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Divider ───────────────────────────────────────────────
                const OrDivider(),
                const SizedBox(height: AppSpacing.lg),

                // ── Sign in with Google Button ────────────────────────────
                SocialLoginButton(
                  label: _isGoogleLoading
                      ? 'Signing in with Google...'
                      : AppStrings.continueWithGoogle,
                  icon: const _GoogleLetterIcon(),
                  isLoading: _isGoogleLoading,
                  onPressed: (_isLoading || _isGoogleLoading) ? null : _handleGoogleSignIn,
                ),
                const SizedBox(height: AppSpacing.xxl),

                // ── Already have account footer ───────────────────────────
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      AppStrings.alreadyHaveAccount,
                      style: AppTextStyles.bodyMd,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        AppStrings.logIn,
                        style: AppTextStyles.link,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleLetterIcon extends StatelessWidget {
  const _GoogleLetterIcon();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.google,
      width: 22,
      height: 22,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const Icon(
        Icons.g_mobiledata_rounded,
        size: 22,
        color: Color(0xFF4285F4),
      ),
    );
  }
}
