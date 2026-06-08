import 'package:expense_tracker/core/theme.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Change to ConsumerStatefulWidget
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

// 2. Move controllers and state variables inside the State class
class _SignupScreenState extends ConsumerState<SignupScreen> {
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  
  bool isPasswordHidden = true;

  // 3. Always dispose controllers in a stateful widget to prevent memory leaks
  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 4. ref is now globally available via ConsumerState, no need to pass it to build()
    final loading = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Icon(
                      Icons.square_rounded,
                      color: AppColors.textPlaceholder,
                      size: 60,
                    ),
                  ),
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 0, left: 25),
                  child: Text(
                    "Fill in your details to get started",
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: formkey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 0, left: 25),
                            child: Text(
                              "First Name",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.25,
                        ),
                        Expanded(
                          child: Text(
                            "Last Name",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.inputBg,
                            ),
                            child: TextFormField(
                              controller: nameController,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please Enter Name";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                hintText: "Rahul",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.inputBg,
                            ),
                            child: TextFormField(
                              controller: lastNameController,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                              ),
                              decoration: const InputDecoration(
                                hintText: "Sharma",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0, left: 25),
                        child: Text(
                          "Email Address",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.inputBg,
                        ),
                        child: TextFormField(
                          controller: emailController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !value.contains("@")) {
                              return "Please Enter Valid Email";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: "your@email.com",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0, left: 25),
                        child: Text(
                          "Phone Number",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.inputBg,
                        ),
                        child: TextFormField(
                          controller: phoneController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter phone number";
                            }
                            if (int.tryParse(value) == null) {
                              return "Only digits allowed";
                            }
                            if (value.length < 10 || value.length > 13) {
                              return "Invalid phone number";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: "+919066881581",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0, left: 25),
                        child: Text(
                          " Password",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.inputBg,
                        ),
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: isPasswordHidden,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please Enter Valid Password";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "******",
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                            // Added suffix icon to allow password visibility toggle
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordHidden
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordHidden = !isPasswordHidden;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: loading
                            ? null
                            : () async {
                                if (!formkey.currentState!.validate()) {
                                  return;
                                }
          
                                try {
                                  await ref
                                      .read(authProvider.notifier)
                                      .signUp(
                                        emailController.text.trim(),
                                        passwordController.text.trim(),
                                        int.parse(phoneController.text.trim()),
                                        lastNameController.text.trim(),
                                      );
          
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Account created successfully"),
                                      ),
                                    );
                                    Navigator.pop(
                                      context                                      
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                }
                              },
                        child: loading
                            ? const CircularProgressIndicator()
                            : const Text(
                                "Create Account",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 20,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Context now correctly resolves clean navigation
                              Navigator.pop(
                                context                              
                              );
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ),
        ),
      );
    }
  }