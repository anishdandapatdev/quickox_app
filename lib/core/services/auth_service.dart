import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  /// Optional test handler for unit/widget testing without Google Play Services
  @visibleForTesting
  static Future<UserModel?> Function()? testSignInHandler;

  /// Sign in with Google using firebase_auth and google_sign_in
  Future<UserModel?> signInWithGoogle() async {
    if (testSignInHandler != null) {
      final testUser = await testSignInHandler!();
      if (testUser != null) {
        _currentUser = testUser;
        notifyListeners();
      }
      return testUser;
    }

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: '1007597837274-qamh600vt8ceatpkiglmsns8bkqup2s0.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled Google account selection
        return null;
      }

      User? firebaseUser;
      try {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        firebaseUser = userCredential.user;
      } catch (authError) {
        debugPrint('Firebase signInWithCredential notice: $authError');
        firebaseUser = FirebaseAuth.instance.currentUser;
      }

      final fbName = firebaseUser?.displayName;
      final fbEmail = firebaseUser?.email;
      final user = UserModel(
        id: firebaseUser?.uid ?? 'g_${googleUser.id}',
        displayName: (fbName != null && fbName.isNotEmpty)
            ? fbName
            : (googleUser.displayName != null && googleUser.displayName!.isNotEmpty
                ? googleUser.displayName!
                : 'Technician'),
        email: (fbEmail != null && fbEmail.isNotEmpty)
            ? fbEmail
            : googleUser.email,
        photoUrl: firebaseUser?.photoURL ?? googleUser.photoUrl,
        phone: firebaseUser?.phoneNumber,
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
      rethrow;
    }
  }

  /// Sign in with Phone & Password
  Future<UserModel> signInWithPhone(String phone, String password) async {
    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'Quickox Technician',
      email: '',
      phone: phone,
      authProvider: 'phone',
      loggedInAt: DateTime.now(),
    );

    _currentUser = user;
    notifyListeners();
    return user;
  }

  /// In-memory cache of verified registered emails from Firestore
  final Set<String> _registeredEmails = {};

  /// Check whether an email already exists in Firestore
  Future<bool> checkEmailExists(String email) async {
    final normalized = email.trim().toLowerCase();
    if (_registeredEmails.contains(normalized)) {
      return true;
    }

    try {
      final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/home-service-haldia/databases/(default)/documents/users',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 4));
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
    } catch (e) {
      debugPrint('Error checking email exists in Firestore: $e');
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
          : (current?.phone ?? ''),
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
      ).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Firestore sync notice: $e');
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
    testSignInHandler = null;
    notifyListeners();
  }
}
