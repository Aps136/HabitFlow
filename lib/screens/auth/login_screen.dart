import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../provider/habit_provider.dart';
import 'dart:ui';
import '../../widgets/glass_card.dart';
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  bool _obscurePass = true;
  String _error = '';
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    setState(() { _loading = true; _error = ''; });
    try {
      final auth = ref.read(authServiceProvider);
      if (_isLogin) {
        await auth.signIn(_emailCtrl.text.trim(), _passCtrl.text.trim());
      } else {
        await auth.signUp(_emailCtrl.text.trim(), _passCtrl.text.trim());
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _googleSignIn() async {
    setState(() { _loading = true; _error = ''; });
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
    } catch (e) {
      setState(() => _error = e.toString());
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassCard(
        borderRadius: 28,
        opacity: 0.08,
        borderColor: AppTheme.primary.withOpacity(0.25),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  // Logo + glow
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary.withOpacity(0.12),
                        ),
                      ),
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.accent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.5),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.bolt_rounded,
                            size: 40, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // App name
                  Text('HabitFlow',
                      style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1)),
                  const SizedBox(height: 6),

                  // Tagline
                  Text('Small steps. Big transformations.',
                      style: GoogleFonts.poppins(
                          color: AppTheme.accentLight,
                          fontSize: 14,
                          fontStyle: FontStyle.italic)),
                  const SizedBox(height: 40),

                  // Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                          color: AppTheme.primary.withOpacity(0.25), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Sign In / Sign Up toggle
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: ['Sign In', 'Sign Up'].map((label) {
                              final active = (label == 'Sign In') == _isLogin;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _isLogin = label == 'Sign In';
                                    _error = '';
                                  }),
                                  //create a polished fade in effect
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                    decoration: BoxDecoration(
                                      gradient: active
                                          ? const LinearGradient(
                                          colors: [AppTheme.primary, AppTheme.accent])
                                          : null,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(label,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                            color: active
                                                ? Colors.white
                                                : AppTheme.textSecondary,
                                            fontWeight: active
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            fontSize: 14)),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Email field
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon:
                            Icon(Icons.email_outlined, color: AppTheme.primary),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Password field
                        TextField(
                          controller: _passCtrl,
                          obscureText: _obscurePass,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: AppTheme.primary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePass
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.textSecondary,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePass = !_obscurePass),
                            ),
                          ),
                        ),

                        // Error message
                        if (_error.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppTheme.error.withOpacity(0.3)),
                            ),
                            child: Text(_error,
                                style: GoogleFonts.poppins(
                                    color: AppTheme.error, fontSize: 12)),
                          ),
                        ],
                        const SizedBox(height: 22),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            child: _loading
                                ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                                : Text(_isLogin ? 'Sign In' : 'Create Account'),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Divider
                        Row(children: [
                          const Expanded(
                              child: Divider(color: AppTheme.surfaceLight)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('or',
                                style: TextStyle(
                                    color: AppTheme.textSecondary, fontSize: 13)),
                          ),
                          const Expanded(
                              child: Divider(color: AppTheme.surfaceLight)),
                        ]),
                        const SizedBox(height: 16),

                        // Google button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _loading ? null : _googleSignIn,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: AppTheme.primary.withOpacity(0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 22, height: 22,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Center(
                                    child: Text('G',
                                        style: TextStyle(
                                            color: Color(0xFFE91E8C),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text('Continue with Google',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Footer
                  Text('By continuing, you agree to our Terms of Service',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary.withOpacity(0.6),
                          fontSize: 11)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}