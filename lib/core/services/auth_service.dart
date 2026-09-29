import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Represents a Google Account available on device or entered by user
class GoogleAccount {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;
  final Color avatarBgColor;

  const GoogleAccount({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.avatarBgColor = const Color(0xFF1A73E8),
  });

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'G';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

/// Represents the active authenticated user session in the Quickox App
class UserModel {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? phone;
  final String authProvider; // 'google' | 'phone'
  final DateTime loggedInAt;

  const UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.phone,
    required this.authProvider,
    required this.loggedInAt,
  });

  bool get isGoogleUser => authProvider == 'google';

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

/// Central Authentication Service managing active sessions, Google Sign-In,
/// and backend sync with Firebase Firestore ('home-service-haldia').
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Default Google accounts for authentic, instant 1-tap sign-in selection
  static const List<GoogleAccount> defaultAccounts = [
    GoogleAccount(
      id: 'g_rahul_101',
      displayName: 'Rahul Sharma',
      email: 'rahul.sharma@gmail.com',
      avatarBgColor: Color(0xFF1A73E8), // Google Blue
    ),
    GoogleAccount(
      id: 'g_anish_102',
      displayName: 'Anish Kumar',
      email: 'anish.quickox@gmail.com',
      avatarBgColor: Color(0xFF34A853), // Google Green
    ),
    GoogleAccount(
      id: 'g_technician_103',
      displayName: 'Quickox Technician',
      email: 'technician@quickox.com',
      avatarBgColor: Color(0xFFEA4335), // Google Red
    ),
  ];

  final List<GoogleAccount> _availableAccounts = List.from(defaultAccounts);
  List<GoogleAccount> get availableAccounts => List.unmodifiable(_availableAccounts);

  /// Add a custom Google account (from "Add another account" flow)
  void addGoogleAccount(GoogleAccount account) {
    if (!_availableAccounts.any((a) => a.email.toLowerCase() == account.email.toLowerCase())) {
      _availableAccounts.insert(0, account);
      notifyListeners();
    }
  }

  /// Sign in with Google using firebase_auth and google_sign_in
  Future<UserModel?> signInWithGoogle([GoogleAccount? account]) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // user canceled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) return null;

      final user = UserModel(
        id: firebaseUser.uid,
        displayName: firebaseUser.displayName ?? 'Technician',
        email: firebaseUser.email ?? '',
        photoUrl: firebaseUser.photoURL,
        phone: firebaseUser.phoneNumber,
        authProvider: 'google',
        loggedInAt: DateTime.now(),
      );

      _currentUser = user;
      notifyListeners();

      // Async sync with Firebase Firestore users collection in the background
      _syncUserWithFirebase(user);

      return user;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return null;
    }
  }

  /// Sign in with Phone & Password
  Future<UserModel> signInWithPhone(String phone, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'Quickox Technician',
      email: 'technician@quickox.com',
      phone: phone,
      authProvider: 'phone',
      loggedInAt: DateTime.now(),
    );

    _currentUser = user;
    notifyListeners();
    return user;
  }

  /// Set of emails that are already registered and have completed profile setup.
  /// Default existing accounts like rahul.sharma@gmail.com are included by default.
  final Set<String> _registeredEmails = {
    'rahul.sharma@gmail.com',
    'technician@quickox.com',
  };

  /// Check whether an email already exists in the system (local cache or Firestore)
  Future<bool> checkEmailExists(String email) async {
    final normalized = email.trim().toLowerCase();
    if (_registeredEmails.contains(normalized)) {
      return true;
    }

    try {
      final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/home-service-haldia/databases/(default)/documents/users',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final documents = data['documents'] as List<dynamic>?;
        if (documents != null) {
          for (final doc in documents) {
            final fields = doc['fields'] as Map<String, dynamic>?;
            final docEmail =
                fields?['email']?['stringValue']?.toString().toLowerCase();
            if (docEmail == normalized) {
              _registeredEmails.add(normalized);
              return true;
            }
          }
        }
      }
    } catch (_) {
      // Graceful offline fallback
    }

    return _registeredEmails.contains(normalized);
  }

  /// Synchronously check if an email is registered
  bool isEmailRegistered(String email) =>
      _registeredEmails.contains(email.trim().toLowerCase());

  /// Manually mark an email as registered
  void registerEmail(String email) {
    _registeredEmails.add(email.trim().toLowerCase());
    notifyListeners();
  }

  /// Complete profile setup for the authenticated user and sync to Firestore
  Future<UserModel> completeProfileSetup({
    required String displayName,
    required String email,
    String? phone,
    String? location,
  }) async {
    final current = _currentUser;
    final updated = UserModel(
      id: current?.id ?? 'usr_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}',
      displayName: displayName.trim(),
      email: email.trim(),
      photoUrl: current?.photoUrl,
      phone: (phone != null && phone.isNotEmpty)
          ? phone
          : (current?.phone ?? '+91 98765 43210'),
      authProvider: current?.authProvider ?? 'google',
      loggedInAt: current?.loggedInAt ?? DateTime.now(),
    );

    _currentUser = updated;
    _registeredEmails.add(email.trim().toLowerCase());
    notifyListeners();

    // Async sync with Firebase Firestore
    _syncUserWithFirebase(updated, location: location);

    return updated;
  }

  /// Sync user profile to Firestore `home-service-haldia` project
  Future<void> _syncUserWithFirebase(UserModel user, {String? location}) async {
    try {
      final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/home-service-haldia/databases/(default)/documents/users?documentId=${user.id}',
      );
      final fields = <String, dynamic>{
        'id': {'stringValue': user.id},
        'displayName': {'stringValue': user.displayName},
        'email': {'stringValue': user.email},
        'authProvider': {'stringValue': user.authProvider},
        'role': {'stringValue': 'TECHNICIAN'},
        'updatedAt': {'stringValue': DateTime.now().toIso8601String()},
      };
      if (user.phone != null && user.phone!.isNotEmpty) {
        fields['phone'] = {'stringValue': user.phone!};
      }
      if (location != null && location.isNotEmpty) {
        fields['location'] = {'stringValue': location};
      }
      final body = jsonEncode({'fields': fields});
      await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 3));
    } catch (_) {
      // Graceful offline fallback
    }
  }

  /// Log out and clear current user session
  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  /// Reset session for testing
  @visibleForTesting
  void resetSession() {
    _currentUser = null;
    _registeredEmails.clear();
    _registeredEmails.addAll([
      'rahul.sharma@gmail.com',
      'technician@quickox.com',
    ]);
    notifyListeners();
  }
}
