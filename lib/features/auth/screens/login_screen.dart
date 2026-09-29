import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../navigation/main_navigation_screen.dart';
import '../models/country_code.dart';
import '../widgets/rounded_password_input.dart';
import '../widgets/rounded_phone_input.dart';
import 'profile_setup_screen.dart';
import 'signup_screen.dart';
import '../../../core/services/auth_service.dart';

/// Login screen — Phone and password authentication
/// Follows the Quickox design system: Royal Blue primary, white background.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.promptAccountPicker = true,
  });

  final bool promptAccountPicker;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ── State ──────────────────────────────────────────────────────────────────
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  // ── Country data ───────────────────────────────────────────────────────────
  CountryCode _selectedCountry = CountryCode.defaultCountry;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await AuthService.instance.signInWithPhone(
      _phoneController.text.trim(),
      _passwordController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      (route) => false,
    );
  }

  void _forgotPassword() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      backgroundColor: AppColors.bgPrimary,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Icon(
                Icons.lock_reset_rounded,
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Forgot Password?',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Technician credentials are provided and managed by the Quickox Admin. Please contact your administrator or Quickox support to reset your password.',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              GradientButton(
                label: 'Understood',
                onPressed: () => Navigator.pop(ctx),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _googleLogin() async {
    setState(() => _isGoogleLoading = true);

    final user = await AuthService.instance.signInWithGoogle();
    
    if (!mounted) return;
    
    if (user == null) {
      setState(() => _isGoogleLoading = false);
      return;
    }

    final emailExists = await AuthService.instance.checkEmailExists(user.email);

    if (!mounted) return;
    setState(() => _isGoogleLoading = false);

    if (emailExists) {
      // Direct success notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Signed in as ${user.displayName} (${user.email})',
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

      // Navigate directly to main screen if email exists
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
            phoneNumber: user.phone ?? '',
            initialName: user.displayName,
            initialEmail: user.email,
          ),
        ),
      );
    }
  }

  void _createAccount() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const SignUpScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
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
                _Logo(),
                const SizedBox(height: AppSpacing.xl),

                // ── Welcome Text ──────────────────────────────────────────
                Text(AppStrings.welcomeBack, style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  AppStrings.loginSubtitle,
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
                  validator: (value) {
                    if (value == null || value.trim().length < 10) {
                      return 'Enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Rounded Password Field ────────────────────────────────
                RoundedPasswordInput(
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Password is required';
                    }
                    if (value.trim().length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onSubmitted: (_) => _handleLogin(),
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── Forgot Password Link ──────────────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _forgotPassword,
                    child: Text(
                      'Forgot Password?',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Login Button ──────────────────────────────────────────
                GradientButton(
                  label: AppStrings.logIn,
                  onPressed: _isLoading ? null : _handleLogin,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Divider ───────────────────────────────────────────────
                const OrDivider(),
                const SizedBox(height: AppSpacing.lg),

                // ── Social Buttons ────────────────────────────────────────
                SocialLoginButton(
                  label: _isGoogleLoading
                      ? 'Signing in with Google...'
                      : AppStrings.continueWithGoogle,
                  icon: const _GoogleIcon(),
                  isLoading: _isGoogleLoading,
                  onPressed: (_isLoading || _isGoogleLoading) ? null : _googleLogin,
                ),
                const SizedBox(height: AppSpacing.xxl),

                // ── Sign Up Link ──────────────────────────────────────────
                _SignUpFooter(onTap: _createAccount),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Private sub-widgets ────────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.logo,
      height: 90,
      fit: BoxFit.contain,
      errorBuilder: (_, e, s) => const Icon(
        Icons.home_repair_service_rounded,
        size: 72,
        color: AppColors.primary,
      ),
    );
  }
}


class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

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

class _SignUpFooter extends StatelessWidget {
  const _SignUpFooter({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(AppStrings.newToQuickox, style: AppTextStyles.bodyMd),
        GestureDetector(
          onTap: onTap,
          child: Text(AppStrings.createAccount, style: AppTextStyles.link),
        ),
      ],
    );
  }
}
