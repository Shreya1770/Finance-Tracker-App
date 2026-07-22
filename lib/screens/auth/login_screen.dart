import 'package:expense_tracker/core/theme.dart';
import 'package:expense_tracker/screens/auth/forget_screen.dart';
import 'package:expense_tracker/screens/auth/signUp_screen.dart';
import 'package:expense_tracker/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final formkey = GlobalKey<FormState>();
  bool isPaswordHidden = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: SingleChildScrollView(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Transform.translate(
              offset: const Offset(0, -60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Image.asset(
                        "assets/images/logo.png",
                        height: MediaQuery.of(context).size.height * 0.40,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -140),
                    child: Center(
                      child: Text(
                        "Your Smart Finance Tracker",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: formkey,
                    child: Transform.translate(
                      offset: const Offset(0, -80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              "Email",
                              style: TextStyle(
                                fontSize: 24,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2.0,
                              horizontal: 30.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.inputBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextFormField(
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !value.contains("@")) {
                                  return "Enter Valid Email";
                                }
                                return null;
                              },
                              controller: email,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                              ),
                              decoration: const InputDecoration(
                                hintText: "your@email.com",
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              "Password",
                              style: TextStyle(
                                fontSize: 24,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2.0,
                              horizontal: 30.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.inputBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Enter Valid Password";
                                }

                                return null;
                              },
                              controller: password,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                              ),
                              obscureText: isPaswordHidden,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPaswordHidden
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.textPrimary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isPaswordHidden = !isPaswordHidden;
                                    });
                                  },
                                ),
                                fillColor: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (!formkey.currentState!.validate()) {
                                      return;
                                    }
                                    try {
                                      await ref
                                          .read(authProvider.notifier)
                                          .login(
                                            email.text.trim(),
                                            password.text.trim(),
                                          );
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const HomeScreen(),
                                        ),
                                      );
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("Login Successfully"),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text(e.toString())),
                                        );
                                      }
                                    }
                                  },
                            child: isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.textPrimary,
                                    ),
                                  )
                                : const Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: OutlinedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                disabledBackgroundColor: AppColors.primary
                                    .withOpacity(0.5),
                                foregroundColor: AppColors.textPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SignupScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Create Account",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: OutlinedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                disabledBackgroundColor: AppColors.primary
                                    .withOpacity(0.5),
                                foregroundColor: AppColors.textPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Forget Password?",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
