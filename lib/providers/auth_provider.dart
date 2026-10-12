import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart' as app_user;

/// Provider that wraps AuthService and exposes auth state to the widget tree
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _authService.addListener(_onAuthChanged);
  }

  void _onAuthChanged() => notifyListeners();

  app_user.User? get currentUser => _authService.currentUser;
  bool get isAuthenticated => _authService.isAuthenticated;
  bool get isLoading => _authService.isLoading;

  Future<bool> signIn(String email, String password) async {
    try {
      final user = await _authService.signIn(email, password);
      return user != null;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    required app_user.UserRole role,
  }) async {
    try {
      final user = await _authService.register(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );
      return user != null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() => _authService.signOut();

  void switchDemoRole(app_user.UserRole role) {
    _authService.switchDemoRole(role);
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    super.dispose();
  }
}
