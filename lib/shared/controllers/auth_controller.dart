import 'dart:async';

import 'package:flutter/material.dart';

import '../models/user.dart';

class AuthController {
  AuthController();

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String> passwordStrength = ValueNotifier('weak');
  final GlobalKey<FormState> signInKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signUpKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void dispose() {
    isLoading.dispose();
    passwordStrength.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void evaluatePassword(String value) {
    var strength = 'weak';
    final regexMedium = RegExp(r'^(?=.*[A-Za-z])(?=.*\\d).{6,}$');
    final regexStrong = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d).{8,}$');
    if (regexStrong.hasMatch(value)) {
      strength = 'strong';
    } else if (regexMedium.hasMatch(value)) {
      strength = 'medium';
    }
    passwordStrength.value = strength;
  }

  Future<User> signIn({bool guest = false}) async {
    isLoading.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 600));
    isLoading.value = false;
    return User(id: guest ? null : 'u1', name: guest ? 'Guest' : 'Alya', guest: guest);
  }

  Future<User> signUp() async {
    return signIn();
  }
}
