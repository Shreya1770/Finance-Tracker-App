import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class SignupScreen extends ConsumerWidget {

  SignupScreen({super.key});

  final emailController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  @override
  Widget build(BuildContext context,
      WidgetRef ref) {

    final loading = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Signup"),
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

            SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {

                await ref
                    .read(authProvider.notifier)
                    .signUp(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                  99884466333,
                  "Srivastava",
            );

                Navigator.pop(context);
              },
              child: loading
                  ? CircularProgressIndicator()
                  : Text("Signup"),
            )
          ],
        ),
      ),
    );
  }
}