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

  Future<User> signIn({String? email, bool guest = false}) async {
    isLoading.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 600));
    isLoading.value = false;
    if (guest) {
      return User(id: null, name: 'Guest', guest: true);
    }
    final username = (email ?? '').split('@').first;
    final formattedName = username.isNotEmpty ? '${username[0].toUpperCase()}${username.substring(1)}' : 'Member';
    return User(id: 'u1', name: formattedName, guest: false);
  }

  Future<User> signUp({required String email}) async {
    return signIn(email: email);
  }
}
