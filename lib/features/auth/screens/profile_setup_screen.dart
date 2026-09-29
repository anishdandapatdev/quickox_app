import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../navigation/main_navigation_screen.dart';
import '../widgets/rounded_text_input.dart';

/// User Profile Setup Screen after OTP verification or Google Sign-In
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({
    super.key,
    this.phoneNumber = '',
    this.initialName,
    this.initialEmail,
  });

  final String phoneNumber;
  final String? initialName;
  final String? initialEmail;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _locationController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser;
    final defaultName = widget.initialName ?? user?.displayName ?? '';
    final defaultEmail = widget.initialEmail ?? user?.email ?? '';

    _nameController = TextEditingController(text: defaultName);
    _emailController = TextEditingController(text: defaultEmail);
    _locationController = TextEditingController(text: 'Haldia Central, WB');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _useCurrentLocation() {
    setState(() {
      _locationController.text = 'Haldia Central, Purba Medinipur, WB';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location detected: Haldia Central'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleCompleteSetup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final location = _locationController.text.trim();

    // Complete setup in AuthService (updates current user, marks email as registered, syncs with Firestore)
    await AuthService.instance.completeProfileSetup(
      displayName: name,
      email: email,
      phone: widget.phoneNumber.isNotEmpty ? widget.phoneNumber : null,
      location: location,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Profile setup complete! Welcome, $name.',
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

    // Navigate to Main Screen with 5 bottom navigation tabs
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.sm),

                // ── Avatar with Camera badge ─────────────────────────────────
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: AuthService.instance.currentUser != null
                          ? Text(
                              AuthService.instance.currentUser!.initials,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            )
                          : const Icon(
                              Icons.person_rounded,
                              size: 52,
                              color: AppColors.primary,
                            ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Title & Subtitle ─────────────────────────────────────────
                Text(AppStrings.profileSetupTitle, style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  AppStrings.profileSetupSubtitle,
                  style: AppTextStyles.bodyMd,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),

                // ── Name Field ───────────────────────────────────────────────
                RoundedTextInput(
                  controller: _nameController,
                  labelText: AppStrings.fullName,
                  hintText: AppStrings.fullNameHint,
                  prefixIcon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (val) {
                    if (val == null || val.trim().length < 2) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Email / Gmail Field ──────────────────────────────────────
                RoundedTextInput(
                  controller: _emailController,
                  labelText: AppStrings.email,
                  hintText: AppStrings.emailHint,
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your email or Gmail address';
                    }
                    if (!val.contains('@') || !val.contains('.')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Location / Address Field ─────────────────────────────────
                RoundedTextInput(
                  controller: _locationController,
                  labelText: AppStrings.location,
                  hintText: AppStrings.locationHint,
                  prefixIcon: Icons.location_on_outlined,
                  suffixWidget: GestureDetector(
                    onTap: _useCurrentLocation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.my_location_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Current',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your location or address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),

                // ── Submit Button ────────────────────────────────────────────
                GradientButton(
                  label: AppStrings.completeSetup,
                  isLoading: _isLoading,
                  onPressed: _handleCompleteSetup,
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
