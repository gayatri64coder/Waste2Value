import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/firebase_bootstrap.dart';
import '../../models/user_model.dart' as app_user;

/// Abstract interface for auth operations (enables easy mocking/testing)
abstract class IAuthService {
  Future<app_user.User?> signIn(String email, String password);
  Future<app_user.User?> register({
    required String email,
    required String password,
    required String displayName,
    required app_user.UserRole role,
  });
  Future<void> signOut();
  Future<void> updateDisplayName(String name);
  app_user.User? get currentUser;
  bool get isAuthenticated;
  Stream<app_user.User?> get authStateStream;
}

/// Firebase-backed authentication service with graceful offline fallback
class AuthService extends ChangeNotifier implements IAuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _initAuthListener();
  }

  app_user.User? _currentUser;
  bool _isLoading = false;

  @override
  app_user.User? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;

  bool get isLoading => _isLoading;

  @override
  Stream<app_user.User?> get authStateStream {
    if (FirebaseBootstrap.isInitialized) {
      return FirebaseAuth.instance.authStateChanges().map((fbUser) {
        if (fbUser == null) return null;
        return app_user.User(
          id: fbUser.uid,
          email: fbUser.email ?? '',
          displayName: fbUser.displayName ?? 'Eco Citizen',
        );
      });
    }
    return Stream.value(_currentUser);
  }

  void _initAuthListener() {
    if (FirebaseBootstrap.isInitialized) {
      try {
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (user != null) {
            _currentUser = app_user.User(
              id: user.uid,
              email: user.email ?? 'user@waste2value.org',
              displayName: user.displayName ?? 'Eco Citizen',
            );
          } else {
            _currentUser = null;
          }
          notifyListeners();
        });
        return;
      } catch (e) {
        debugPrint('[W2V:AuthService] Firebase listener error: $e');
      }
    }

    // Development fallback — default demo user
    _currentUser = const app_user.User(
      id: 'demo_user_001',
      email: 'citizen@waste2value.org',
      displayName: 'Maya Patel',
      role: app_user.UserRole.citizen,
      greenCredits: 380,
      totalKgRecycled: 28.4,
      co2SavedKg: 86.5,
      treesPlantedEquivalent: 4,
      phoneNumber: '+91 98765 43210',
      defaultAddress: 'Flat 402, Green Meadows, Bengaluru, KA',
      badges: ['Urban Miner', 'Battery Guardian', 'Circular Economy Pioneer'],
    );
  }

  @override
  Future<app_user.User?> signIn(String email, String password) async {
    _setLoading(true);
    try {
      if (FirebaseBootstrap.isInitialized) {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final fbUser = credential.user;
        if (fbUser != null) {
          // Try to load extended profile from Firestore
          final profile = await _loadProfileFromFirestore(fbUser.uid);
          _currentUser = profile ??
              app_user.User(
                id: fbUser.uid,
                email: fbUser.email ?? email,
                displayName: fbUser.displayName ?? 'Eco User',
              );
          notifyListeners();
          return _currentUser;
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 700));
        _currentUser = app_user.User(
          id: 'dev_${DateTime.now().millisecondsSinceEpoch}',
          email: email.trim(),
          displayName: email.split('@').first,
        );
        notifyListeners();
        return _currentUser;
      }
    } catch (e) {
      debugPrint('[W2V:AuthService] signIn error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
    return null;
  }

  @override
  Future<app_user.User?> register({
    required String email,
    required String password,
    required String displayName,
    required app_user.UserRole role,
  }) async {
    _setLoading(true);
    try {
      if (FirebaseBootstrap.isInitialized) {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final fbUser = credential.user;
        if (fbUser != null) {
          await fbUser.updateDisplayName(displayName);
          final newUser = app_user.User(
            id: fbUser.uid,
            email: email.trim(),
            displayName: displayName,
            role: role,
            createdAt: DateTime.now(),
          );
          await _saveProfileToFirestore(newUser);
          _currentUser = newUser;
          notifyListeners();
          return newUser;
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 700));
        _currentUser = app_user.User(
          id: 'dev_${DateTime.now().millisecondsSinceEpoch}',
          email: email.trim(),
          displayName: displayName,
          role: role,
          createdAt: DateTime.now(),
        );
        notifyListeners();
        return _currentUser;
      }
    } catch (e) {
      debugPrint('[W2V:AuthService] register error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    if (FirebaseBootstrap.isInitialized) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        debugPrint('[W2V:AuthService] signOut error: $e');
      }
    }
    _currentUser = null;
    notifyListeners();
  }

  @override
  Future<void> updateDisplayName(String name) async {
    if (FirebaseBootstrap.isInitialized) {
      try {
        await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
      } catch (e) {
        debugPrint('[W2V:AuthService] updateDisplayName error: $e');
      }
    }
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(displayName: name);
      notifyListeners();
    }
  }

  Future<app_user.User?> _loadProfileFromFirestore(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return app_user.User.fromMap(doc.data()!, uid);
      }
    } catch (e) {
      debugPrint('[W2V:AuthService] Firestore profile load error: $e');
    }
    return null;
  }

  Future<void> _saveProfileToFirestore(app_user.User user) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('[W2V:AuthService] Firestore profile save error: $e');
    }
  }

  /// Development helper: switch demo role for multi-role testing
  void switchDemoRole(app_user.UserRole role) {
    if (_currentUser == null) return;
    final displayNames = {
      app_user.UserRole.recycler: 'EcoSmelt Recycling Facility',
      app_user.UserRole.enterprise: 'TechCorp Logistics Ltd.',
      app_user.UserRole.collector: 'Agent Rahul Sharma',
      app_user.UserRole.reviewer: 'Dr. Priya Nair (Auditor)',
    };
    _currentUser = _currentUser!.copyWith(
      role: role,
      displayName: displayNames[role] ?? 'Maya Patel',
    );
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
