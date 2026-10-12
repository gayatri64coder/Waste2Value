import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/config/firebase_bootstrap.dart';
import '../../domain/models/user_profile.dart';

/// Authentication repository managing user sessions.
///
/// DUAL-MODE ARCHITECTURE:
/// - If Firebase is initialized with real credentials: delegates to FirebaseAuth.
/// - If Firebase credentials are pending: provides safe offline development sessions
///   without inventing fake credentials or throwing unhandled exceptions.
class AuthRepository extends ChangeNotifier {
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;
  AuthRepository._internal() {
    _initAuthListener();
  }

  UserProfile? _currentUser;
  bool _isLoading = false;

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  void _initAuthListener() {
    if (FirebaseBootstrap.isInitialized) {
      try {
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (user != null) {
            _currentUser = UserProfile(
              id: user.uid,
              email: user.email ?? 'user@waste2value.org',
              displayName: user.displayName ?? 'Eco Citizen',
              role: UserRole.citizen,
            );
          } else {
            _currentUser = null;
          }
          notifyListeners();
        });
        return;
      } catch (e) {
        debugPrint('[waste2value] FirebaseAuth listener fallback: $e');
      }
    }

    // Default development demo user for pre-Firebase development
    _currentUser = const UserProfile(
      id: 'demo_user_001',
      email: 'citizen@waste2value.org',
      displayName: 'Maya Patel',
      role: UserRole.citizen,
      greenCredits: 380,
      totalKgRecycled: 28.4,
      co2SavedKg: 86.5,
      treesPlantedEquivalent: 4,
      phoneNumber: '+91 98765 43210',
      defaultAddress: 'Flat 402, Green Meadows, Bengaluru, KA',
      badges: [
        'Urban Miner',
        'Battery Guardian',
        'Circular Economy Pioneer',
      ],
    );
  }

  /// Sign In with Email and Password
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (FirebaseBootstrap.isInitialized) {
        final credential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final user = credential.user;
        if (user != null) {
          _currentUser = UserProfile(
            id: user.uid,
            email: user.email ?? email,
            displayName: user.displayName ?? 'Eco User',
            role: UserRole.citizen,
          );
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Safe offline simulated authentication for development
        await Future.delayed(const Duration(milliseconds: 600));
        _currentUser = UserProfile(
          id: 'dev_usr_${DateTime.now().millisecondsSinceEpoch}',
          email: email.trim(),
          displayName: email.split('@').first.capitalize(),
          role: UserRole.citizen,
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('[waste2value] Sign In error: $e');
      rethrow;
    }
  }

  /// Register new user account
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (FirebaseBootstrap.isInitialized) {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final user = credential.user;
        if (user != null) {
          await user.updateDisplayName(displayName);
          _currentUser = UserProfile(
            id: user.uid,
            email: user.email ?? email,
            displayName: displayName,
            role: role,
          );
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
        _currentUser = UserProfile(
          id: 'dev_usr_${DateTime.now().millisecondsSinceEpoch}',
          email: email.trim(),
          displayName: displayName,
          role: role,
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('[waste2value] Register error: $e');
      rethrow;
    }
  }

  /// Quick role switcher for testing multi-role workflows in development
  void switchDemoRole(UserRole role) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      role: role,
      displayName: role == UserRole.recycler
          ? 'EcoSmelt Recycling Facility'
          : role == UserRole.business
              ? 'TechCorp Logistics'
              : 'Maya Patel',
    );
    notifyListeners();
  }

  /// Sign Out
  Future<void> signOut() async {
    if (FirebaseBootstrap.isInitialized) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        debugPrint('[waste2value] SignOut exception: $e');
      }
    }
    _currentUser = null;
    notifyListeners();
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return '';
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
