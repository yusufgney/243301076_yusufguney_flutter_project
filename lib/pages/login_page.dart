import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_form_shell.dart';
import '../widgets/auth_header.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  late final bool Function(KeyEvent) _keyboardEnterHandler;

  @override
  void initState() {
    super.initState();
    _keyboardEnterHandler = _handleHardwareEnterKey;
    HardwareKeyboard.instance.addHandler(_keyboardEnterHandler);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_keyboardEnterHandler);
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _handleHardwareEnterKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final key = event.logicalKey;
    if (key != LogicalKeyboardKey.enter && key != LogicalKeyboardKey.numpadEnter) {
      return false;
    }
    if (!mounted) return false;
    if (_passwordFocus.hasFocus) {
      _submitLogin();
      return true;
    }
    if (_emailFocus.hasFocus) {
      _passwordFocus.requestFocus();
      return true;
    }
    return false;
  }

  void _submitLogin() {
    if (!mounted) return;
    if (ref.read(authControllerProvider).isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    ref.read(authControllerProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error.toString())),
        );
      }
    });

    return AuthFormShell(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeader(
              title: 'Welcome Back',
              subtitle: 'Sign in to discover casting opportunities.',
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Semantics(
              label: 'Email address input',
              child: TextFormField(
                controller: _emailController,
                focusNode: _emailFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_passwordFocus);
                },
                onEditingComplete: () {
                  FocusScope.of(context).requestFocus(_passwordFocus);
                },
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Email is required';
                  return value.contains('@') ? null : 'Enter a valid email';
                },
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Semantics(
              label: 'Password input',
              child: TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submitLogin(),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Password is required';
                  return value.length < 6 ? 'Minimum 6 characters' : null;
                },
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Semantics(
              button: true,
              label: 'Login button',
              child: ElevatedButton(
                onPressed: authState.isLoading ? null : _submitLogin,
                child: authState.isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            TextButton(
              onPressed: () => context.push('/register'),
              child: const Text('Don\'t have an account? Register'),
            ),
          ],
        ),
      ),
    );
  }
}
