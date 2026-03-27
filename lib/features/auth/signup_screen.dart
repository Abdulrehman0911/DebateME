import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/neon_text.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Set the display name
      await credential.user?.updateDisplayName(
        _displayNameController.text.trim(),
      );

      final uid = credential.user!.uid;
      final email = _emailController.text.trim();
      final username = email.split('@')[0];

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'username': username,
        'elo': 1000,
        'wins': 0,
        'losses': 0,
        'streak': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _mapFirebaseError(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'Email/Password sign-up is not enabled.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      default:
        return 'Sign-up failed. Please try again.';
    }
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.outfit(
        color: AppColors.mutedText,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: ShaderMask(
        shaderCallback: (bounds) =>
            AppColors.accentGradient.createShader(bounds),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surface.withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.divider.withOpacity(0.5),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.neonPurple,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.defeat,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.defeat,
          width: 1.5,
        ),
      ),
      errorStyle: GoogleFonts.outfit(
        color: AppColors.defeat,
        fontSize: 11,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // --- Ambient Glow Orbs ---
            Positioned(
              top: -80,
              left: -100,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.electricBlue.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              right: -60,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonPurple.withOpacity(0.05),
                ),
              ),
            ),

            // --- Main Content ---
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),

                      // --- Logo / Brand ---
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.electricBlue,
                              AppColors.neonPurple,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.electricBlue.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: -5,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_add_alt_1_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1, 1),
                            duration: 600.ms,
                            curve: Curves.easeOut,
                          ),
                      const SizedBox(height: 24),

                      // --- Title ---
                      const NeonText(
                        text: 'JOIN THE ARENA',
                        fontSize: 28,
                        glowColor: AppColors.electricBlue,
                        glowIntensity: 10,
                      ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                      const SizedBox(height: 8),
                      Text(
                        'CREATE YOUR DEBATER PROFILE',
                        style: GoogleFonts.outfit(
                          color: AppColors.mutedText.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                        ),
                      ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

                      const SizedBox(height: 32),

                      // --- Signup Form ---
                      GlassCard(
                        padding: const EdgeInsets.all(28),
                        borderColor: AppColors.electricBlue.withOpacity(0.15),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // --- Error Message ---
                              if (_errorMessage != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                    color: AppColors.defeat.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.defeat.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline_rounded,
                                        color: AppColors.defeat,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: GoogleFonts.outfit(
                                            color: AppColors.defeat,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                    .animate()
                                    .fadeIn(duration: 300.ms)
                                    .shakeX(amount: 4, duration: 400.ms),

                              // --- Display Name Field ---
                              TextFormField(
                                controller: _displayNameController,
                                style: GoogleFonts.spaceGrotesk(
                                  color: AppColors.primaryText,
                                  fontSize: 14,
                                ),
                                decoration: _buildInputDecoration(
                                  label: 'Display Name',
                                  icon: Icons.badge_outlined,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Display name is required';
                                  }
                                  if (value.trim().length < 2) {
                                    return 'Name must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // --- Email Field ---
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: GoogleFonts.spaceGrotesk(
                                  color: AppColors.primaryText,
                                  fontSize: 14,
                                ),
                                decoration: _buildInputDecoration(
                                  label: 'Email Address',
                                  icon: Icons.alternate_email_rounded,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value.trim())) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // --- Password Field ---
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: GoogleFonts.spaceGrotesk(
                                  color: AppColors.primaryText,
                                  fontSize: 14,
                                ),
                                decoration: _buildInputDecoration(
                                  label: 'Password',
                                  icon: Icons.lock_outline_rounded,
                                  suffixIcon: GestureDetector(
                                    onTap: () => setState(
                                        () => _obscurePassword = !_obscurePassword),
                                    child: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: AppColors.mutedText,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (value.trim().length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // --- Confirm Password Field ---
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirm,
                                style: GoogleFonts.spaceGrotesk(
                                  color: AppColors.primaryText,
                                  fontSize: 14,
                                ),
                                decoration: _buildInputDecoration(
                                  label: 'Confirm Password',
                                  icon: Icons.lock_person_rounded,
                                  suffixIcon: GestureDetector(
                                    onTap: () => setState(
                                        () => _obscureConfirm = !_obscureConfirm),
                                    child: Icon(
                                      _obscureConfirm
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: AppColors.mutedText,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value.trim() !=
                                      _passwordController.text.trim()) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 28),

                              // --- Signup Button ---
                              _isLoading
                                  ? Center(
                                      child: SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            AppColors.electricBlue,
                                          ),
                                        ),
                                      ),
                                    )
                                  : NeonButton(
                                      text: 'CREATE ACCOUNT',
                                      icon: Icons.rocket_launch_rounded,
                                      gradientColors: [
                                        AppColors.electricBlue,
                                        AppColors.neonPurple,
                                      ],
                                      onPressed: _signup,
                                    ),
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 400.ms)
                          .slideY(begin: 0.1, duration: 500.ms),

                      const SizedBox(height: 28),

                      // --- Toggle to Login ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: GoogleFonts.outfit(
                              color: AppColors.mutedText,
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            child: ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppColors.accentGradient
                                      .createShader(bounds),
                              child: Text(
                                'Log In',
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 500.ms, delay: 600.ms),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
