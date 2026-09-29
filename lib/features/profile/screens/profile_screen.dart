import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/screens/login_screen.dart';
import '../../bookings/screens/bookings_screen.dart';
import '../../membership/screens/membership_screen.dart';
import '../../services/screens/services_screen.dart';

/// User Profile & Account Settings Screen with neutral grey-white background,
/// left-aligned "My Profile" header, and updated options.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4D4D8),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF18181B),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(color: Color(0xFFF2F2F4)),
              ...['English', 'Hindi', 'Bengali', 'Marathi'].map(
                (lang) => ListTile(
                  title: Text(
                    lang,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: lang == _selectedLanguage
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: lang == _selectedLanguage
                          ? AppColors.primary
                          : const Color(0xFF18181B),
                    ),
                  ),
                  trailing: lang == _selectedLanguage
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => _selectedLanguage = lang);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Row(
          children: [
            Icon(Icons.person_remove_outlined, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Account Deletion'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete your account? All your personal profile, records, and active sessions will be permanently erased. This action cannot be undone.',
          style: TextStyle(fontSize: 14, color: Color(0xFF52525B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFFA1A1AA))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.instance.logout();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deletion request has been submitted.'),
                    backgroundColor: Color(0xFFEF4444),
                  ),
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Log Out'),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out from Quickox?',
          style: TextStyle(fontSize: 14, color: Color(0xFF52525B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFFA1A1AA))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.instance.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Neutral grey-white background (non-blue)
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xs),

              // ── Header (Title + Subtitle) ──────────────────────────────────
              const Text(
                'My Profile',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF18181B),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Manage your account and preferences',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF71717A),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── User Summary Header Card ───────────────────────────────────
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x05000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Builder(
                  builder: (context) {
                    final user = AuthService.instance.currentUser;
                    return Row(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              child: Text(
                                user?.initials ?? 'RS',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      user?.displayName ?? 'Rahul Sharma',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF18181B),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (user?.isGoogleUser == true) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F0FE),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: const Color(0xFFD2E3FC),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Image.asset(
                                            AppAssets.google,
                                            width: 11,
                                            height: 11,
                                            errorBuilder: (_, _, _) => const Icon(
                                              Icons.g_mobiledata,
                                              size: 11,
                                              color: Color(0xFF4285F4),
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          const Text(
                                            'Google',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1A73E8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'PRO',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.email ?? 'rahul.sharma@gmail.com',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF71717A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.phone ?? '+91 98765 43210',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF18181B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          onPressed: () => _showInfoSnackBar('Edit profile info'),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Section 1: Account / Personal Info ─────────────────────────
              _GroupCard(
                children: [
                  _ProfileListItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Personal Information',
                    onTap: () => _showInfoSnackBar('Opening Personal Information'),
                  ),
                  const Divider(height: 1, thickness: 0.8, indent: 52, color: Color(0xFFF2F2F4)),
                  _ProfileListItem(
                    icon: Icons.location_on_outlined,
                    title: 'Saved Addresses',
                    onTap: () => _showInfoSnackBar('Opening Saved Addresses'),
                  ),
                  const Divider(height: 1, thickness: 0.8, indent: 52, color: Color(0xFFF2F2F4)),
                  _ProfileListItem(
                    icon: Icons.phone_outlined,
                    title: 'Emergency Contacts',
                    onTap: () => _showInfoSnackBar('Opening Emergency Contacts'),
                  ),
                ],
              ),

              // ── Section 2: BOOKINGS & SERVICES ────────────────────────────
              const _SectionHeader(title: 'BOOKINGS & SERVICES'),
              _GroupCard(
                children: [
                  _ProfileListItem(
                    icon: Icons.calendar_today_outlined,
                    title: 'My Bookings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BookingsScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, thickness: 0.8, indent: 52, color: Color(0xFFF2F2F4)),
                  _ProfileListItem(
                    icon: Icons.home_repair_service_outlined,
                    title: 'Services',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ServicesScreen()),
                      );
                    },
                  ),
                ],
              ),

              // ── Section 3: MEMBERSHIP & OFFERS ────────────────────────────
              const _SectionHeader(title: 'MEMBERSHIP & OFFERS'),
              _GroupCard(
                children: [
                  _ProfileListItem(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Membership Plans',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MembershipScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, thickness: 0.8, indent: 52, color: Color(0xFFF2F2F4)),
                  _ProfileListItem(
                    icon: Icons.local_offer_outlined,
                    title: 'Offers',
                    onTap: () => _showInfoSnackBar('Opening Offers'),
                  ),
                ],
              ),

              // ── Section 4: SUPPORT & SECURITY ─────────────────────────────
              const _SectionHeader(title: 'SUPPORT & SECURITY'),
              _GroupCard(
                children: [
                  _ProfileListItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Help Center',
                    onTap: () => _showInfoSnackBar('Opening Help Center'),
                  ),
                  const Divider(height: 1, thickness: 0.8, indent: 52, color: Color(0xFFF2F2F4)),
                  _ProfileListItem(
                    icon: Icons.shield_outlined,
                    title: 'Privacy & Security',
                    onTap: () => _showInfoSnackBar('Opening Privacy & Security'),
                  ),
                  const Divider(height: 1, thickness: 0.8, indent: 52, color: Color(0xFFF2F2F4)),
                  _ProfileListItem(
                    icon: Icons.person_remove_outlined,
                    title: 'Account Deletion',
                    onTap: _showDeleteAccountDialog,
                  ),
                ],
              ),

              // ── Section 5: APP SETTINGS ───────────────────────────────────
              const _SectionHeader(title: 'APP SETTINGS'),
              _GroupCard(
                children: [
                  _ProfileListItem(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    trailing: CupertinoSwitch(
                      value: _notificationsEnabled,
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: const Color(0xFFE4E4E7),
                      onChanged: (val) {
                        setState(() => _notificationsEnabled = val);
                      },
                    ),
                  ),
                  const Divider(height: 1, thickness: 0.8, indent: 52, color: Color(0xFFF2F2F4)),
                  _ProfileListItem(
                    icon: Icons.language_rounded,
                    title: 'Language',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedLanguage,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF71717A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: Color(0xFFD4D4D8),
                        ),
                      ],
                    ),
                    onTap: _showLanguagePicker,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Section 6: Log Out Button ──────────────────────────────────
              Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x05000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _showLogoutDialog,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Log Out',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 18, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _ProfileListItem extends StatelessWidget {
  const _ProfileListItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF18181B),
                  ),
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: Color(0xFFD4D4D8),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
