import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_tutorial/constants.dart';
import 'package:tiktok_tutorial/controllers/auth_controller.dart';
import 'package:tiktok_tutorial/views/widgets/text_input_field.dart';
import 'dart:io';

class SignupScreen extends StatefulWidget {
  SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  // Access the AuthController
  final AuthController authController = Get.find<AuthController>();

  void _register() {
    authController.registerUser(
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      authController.profilePhoto, // or null if not picking an image
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Tiktok', style: TextStyle(fontSize: 35, color: buttonColor)),
            const SizedBox(height: 10),
            const Text('Register', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
            const SizedBox(height: 25),
            // Username
            TextInputField(
              controller: _usernameController,
              labelText: 'Username',
              icon: Icons.person,
            ),
            const SizedBox(height: 20),
            // Email
            TextInputField(
              controller: _emailController,
              labelText: 'Email',
              icon: Icons.email,
            ),
            const SizedBox(height: 20),
            // Password
            TextInputField(
              controller: _passwordController,
              labelText: 'Password',
              icon: Icons.lock,
              isObscure: true,
            ),
            const SizedBox(height: 20),
            // Register Button
            InkWell(
              onTap: _register,
              child: Container(
                width: MediaQuery.of(context).size.width - 40,
                height: 50,
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Center(
                  child: Text(
                    'Register',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
