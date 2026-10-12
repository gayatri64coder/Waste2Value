import 'package:flutter/material.dart';
import '../../../core/config/firebase_bootstrap.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../domain/models/user_profile.dart';
import '../../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const AuthScreen({super.key, required this.onAuthenticated});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthRepository _authRepo = AuthRepository();
  bool _isSignUp = false;

  final TextEditingController _emailController =
      TextEditingController(text: 'citizen@waste2value.org');
  final TextEditingController _passwordController =
      TextEditingController(text: 'password123');
  final TextEditingController _nameController =
      TextEditingController(text: 'Maya Patel');
  UserRole _selectedRole = UserRole.citizen;

  String? _errorMessage;

  void _handleSubmit() async {
    setState(() => _errorMessage = null);

    try {
      if (_isSignUp) {
        await _authRepo.register(
          email: _emailController.text,
          password: _passwordController.text,
          displayName: _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : 'Eco Citizen',
          role: _selectedRole,
        );
      } else {
        await _authRepo.signIn(
          _emailController.text,
          _passwordController.text,
        );
      }
      widget.onAuthenticated();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFirebaseReady = FirebaseBootstrap.isInitialized;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Icon
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryGreen, AppTheme.accentMint],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('♻️', style: TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'waste2value',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const Text(
                  'Electronic Waste Management & Circular Valuation',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMutedLight,
                  ),
                ),
                const SizedBox(height: 20),

                // Firebase configuration readiness badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isFirebaseReady
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isFirebaseReady
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFirebaseReady
                            ? Icons.cloud_done_rounded
                            : Icons.cloud_off_rounded,
                        size: 16,
                        color: isFirebaseReady
                            ? const Color(0xFF065F46)
                            : const Color(0xFF92400E),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          isFirebaseReady
                              ? 'Firebase Auth Active'
                              : 'Offline Dev Mode (Firebase Pending google-services.json)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isFirebaseReady
                                ? const Color(0xFF065F46)
                                : const Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Toggle between Sign In / Sign Up
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _isSignUp = false),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: !_isSignUp
                                            ? AppTheme.primaryGreen
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Sign In',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: !_isSignUp
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                      color: !_isSignUp
                                          ? AppTheme.primaryGreen
                                          : AppTheme.textMutedLight,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _isSignUp = true),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: _isSignUp
                                            ? AppTheme.primaryGreen
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Create Account',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: _isSignUp
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                      color: _isSignUp
                                          ? AppTheme.primaryGreen
                                          : AppTheme.textMutedLight,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                  color: Color(0xFFB91C1C), fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        if (_isSignUp) ...[
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<UserRole>(
                            initialValue: _selectedRole,
                            decoration: const InputDecoration(
                              labelText: 'Role Persona',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            items: UserRole.values.map((r) {
                              return DropdownMenuItem(
                                value: r,
                                child: Text(r.label),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedRole = val);
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                        ],

                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            backgroundColor: AppTheme.primaryGreen,
                          ),
                          onPressed: _authRepo.isLoading ? null : _handleSubmit,
                          child: _authRepo.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  _isSignUp ? 'Get Started' : 'Sign In',
                                  style: const TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w700),
                                ),
                        ),
                        const SizedBox(height: 12),

                        // Fast-track Demo Sign In button for development ease
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                          ),
                          onPressed: () {
                            _emailController.text = 'citizen@waste2value.org';
                            _handleSubmit();
                          },
                          child: const Text('Continue with Demo Account (Instant)'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
