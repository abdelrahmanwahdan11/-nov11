import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/utils/context_extensions.dart';
import '../../shared/controllers/auth_controller.dart';
import '../../shared/widgets/primary_button.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late final AuthController _controller;
  bool _obscure = true;
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _signUpEmailController = TextEditingController();
  final TextEditingController _signUpPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AuthController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _confirmPasswordController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.getString('signIn')),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.getString('signIn')),
              Tab(text: l10n.getString('signUp')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSignIn(context),
            _buildSignUp(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _controller.signInKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            TextFormField(
              controller: _controller.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.getString('email'),
                hintText: l10n.getString('emailHint'),
              ),
              validator: (value) =>
                  value != null && value.contains('@') ? null : l10n.getString('emailHint'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller.passwordController,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: l10n.getString('password'),
                hintText: l10n.getString('passwordHint'),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                ),
              ),
              validator: (value) =>
                  value != null && value.length >= 6 ? null : l10n.getString('passwordHint'),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.getString('forgotPassword'))),
                  );
                },
                child: Text(l10n.getString('forgotPassword')),
              ),
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<bool>(
              valueListenable: _controller.isLoading,
              builder: (context, loading, _) {
                return PrimaryButton(
                  label: l10n.getString('signIn'),
                  onPressed: loading
                      ? null
                      : () async {
                          if (_controller.signInKey.currentState?.validate() ?? false) {
                            final scope = AppScope.of(context);
                            final user = await _controller.signIn(
                              email: _controller.emailController.text.trim(),
                            );
                            await scope.appController.setUser(user);
                            await Future<void>.delayed(const Duration(milliseconds: 200));
                            if (!mounted) return;
                            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                          }
                        },
                );
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () async {
                  final scope = AppScope.of(context);
                  final user = await _controller.signIn(guest: true);
                  await scope.appController.setUser(user);
                  await Future<void>.delayed(const Duration(milliseconds: 150));
                  if (!mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                },
                child: Text(l10n.getString('continueAsGuest')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUp(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _controller.signUpKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            TextFormField(
              controller: _signUpEmailController,
              decoration: InputDecoration(
                labelText: l10n.getString('email'),
              ),
              validator: (value) =>
                  value != null && value.contains('@') ? null : l10n.getString('emailHint'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _signUpPasswordController,
              obscureText: _obscure,
              onChanged: _controller.evaluatePassword,
              decoration: InputDecoration(
                labelText: l10n.getString('password'),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                ),
              ),
              validator: (value) =>
                  value != null && value.length >= 8 ? null : l10n.getString('passwordHint'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.getString('confirmPassword')),
              validator: (value) => value == _signUpPasswordController.text
                  ? null
                  : l10n.getString('passwordMismatch'),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<String>(
              valueListenable: _controller.passwordStrength,
              builder: (context, strength, _) {
                Color color;
                switch (strength) {
                  case 'strong':
                    color = Colors.green;
                    break;
                  case 'medium':
                    color = Colors.orange;
                    break;
                  default:
                    color = Colors.red;
                }
                return Row(
                  children: [
                    Text(l10n.getString('passwordStrength')),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(l10n.getString(strength)),
                      backgroundColor: color.withOpacity(0.2),
                      labelStyle: TextStyle(color: color),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<bool>(
              valueListenable: _controller.isLoading,
              builder: (context, loading, _) {
                return PrimaryButton(
                  label: l10n.getString('signUp'),
                  onPressed: loading
                      ? null
                      : () async {
                          if (_controller.signUpKey.currentState?.validate() ?? false) {
                            final scope = AppScope.of(context);
                            final user = await _controller.signUp(
                              email: _signUpEmailController.text.trim(),
                            );
                            await scope.appController.setUser(user);
                            await Future<void>.delayed(const Duration(milliseconds: 200));
                            if (!mounted) return;
                            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                          }
                        },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
