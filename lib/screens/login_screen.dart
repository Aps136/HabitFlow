import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService();
  bool _isLogin = true;
  bool _loading = false;
  String _error = '';

  Future<void> _submit() async {
    setState(() { _loading = true; _error = ''; });
    try {
      if (_isLogin) {
        await _auth.signIn(_emailController.text.trim(), _passwordController.text.trim());
      } else {
        await _auth.signUp(_emailController.text.trim(), _passwordController.text.trim());
      }
    } catch (e) {
      setState(() { _error = e.toString(); });
    }
    setState(() { _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.bolt, size: 64, color: Colors.deepPurpleAccent),
              const SizedBox(height: 12),
              Text('HabitFlow',
                  style: GoogleFonts.poppins(
                      fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text(_isLogin ? 'Welcome back!' : 'Create your account',
                  style: GoogleFonts.poppins(color: Colors.white54)),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Password'),
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(_error, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isLogin ? 'Sign In' : 'Sign Up',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin ? "Don't have an account? Sign Up" : "Already have an account? Sign In",
                  style: const TextStyle(color: Colors.deepPurpleAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}