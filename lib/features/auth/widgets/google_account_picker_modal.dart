import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';

/// Authentic Google Account Chooser Modal Bottom Sheet
/// Matches the native Google Identity / Google Play Services UI:
/// - Google Logo header
/// - 'Choose an account' title & 'to continue to Quickox' subtitle
/// - Account items with initials avatar, name, and email
/// - 'Add another account' option
/// - Google privacy & terms disclaimer
class GoogleAccountPickerModal extends StatefulWidget {
  const GoogleAccountPickerModal({super.key});

  /// Displays the Google Account Chooser bottom sheet and returns the selected account
  static Future<GoogleAccount?> show(BuildContext context) {
    return showModalBottomSheet<GoogleAccount>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const GoogleAccountPickerModal(),
    );
  }

  @override
  State<GoogleAccountPickerModal> createState() => _GoogleAccountPickerModalState();
}

class _GoogleAccountPickerModalState extends State<GoogleAccountPickerModal> {
  void _selectAccount(GoogleAccount account) {
    Navigator.of(context).pop(account);
  }

  Future<void> _showAddAccountDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final addedAccount = await showDialog<GoogleAccount>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Image.asset(
              AppAssets.google,
              width: 22,
              height: 22,
              errorBuilder: (_, _, _) => const Icon(
                Icons.g_mobiledata_rounded,
                color: Color(0xFF4285F4),
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Add Google Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F1F1F),
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your Google account details to sign in directly without OTP.',
                style: TextStyle(fontSize: 13, color: Color(0xFF5F6368)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'e.g. Vikram Malhotra',
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFDADCE0)),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Google Email Address',
                  hintText: 'e.g. user@gmail.com',
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFDADCE0)),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!v.contains('@') || !v.contains('.')) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF5F6368))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A73E8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final name = nameController.text.trim();
                final email = emailController.text.trim().toLowerCase();
                final newAccount = GoogleAccount(
                  id: 'g_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}',
                  displayName: name,
                  email: email,
                  avatarBgColor: const Color(0xFFF2994A),
                );
                AuthService.instance.addGoogleAccount(newAccount);
                Navigator.pop(dialogCtx, newAccount);
              }
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );

    if (addedAccount != null && mounted) {
      _selectAccount(addedAccount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = AuthService.instance.availableAccounts;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Drag Handle ──────────────────────────────────────────
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Header: Google "G" Logo + Titles ──────────────────────
            Row(
              children: [
                Image.asset(
                  AppAssets.google,
                  width: 24,
                  height: 24,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.g_mobiledata_rounded,
                    size: 26,
                    color: Color(0xFF4285F4),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose an account',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F1F1F),
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'to continue to Quickox',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5F6368),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Color(0xFF5F6368)),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 8),

            // ── Account Items ─────────────────────────────────────────
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: accounts.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 56, color: Color(0xFFF1F3F4)),
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: account.avatarBgColor,
                      child: Text(
                        account.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text(
                      account.displayName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                    subtitle: Text(
                      account.email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5F6368),
                      ),
                    ),
                    onTap: () => _selectAccount(account),
                  );
                },
              ),
            ),

            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // ── Add another account ───────────────────────────────────
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              leading: const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFF1F3F4),
                child: Icon(
                  Icons.person_add_alt_1_outlined,
                  size: 20,
                  color: Color(0xFF1F1F1F),
                ),
              ),
              title: const Text(
                'Add another account',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F1F1F),
                ),
              ),
              onTap: _showAddAccountDialog,
            ),

            const SizedBox(height: 12),

            // ── Google Disclaimer Footer ──────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'To continue, Google will share your name, email address, language preference, and profile picture with Quickox. Quickox verifies technicians and customers automatically without SMS OTP.',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.4,
                  color: Color(0xFF747775),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
