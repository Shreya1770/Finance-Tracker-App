import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class ForgotPasswordScreen
    extends ConsumerWidget {

  ForgotPasswordScreen({super.key});

  final emailController =
  TextEditingController();

  @override
  Widget build(BuildContext context,
      WidgetRef ref) {

    final loading = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Forgot Password",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {

                await ref
                    .read(authProvider.notifier)
                    .forgotpassword(
                  emailController.text.trim(),
                );

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Reset email sent",
                    ),
                  ),
                );
              },
              child: loading
                  ? CircularProgressIndicator()
                  : const Text(
                  "Send Reset Link"),
            )
          ],
        ),
      ),
    );
  }
}