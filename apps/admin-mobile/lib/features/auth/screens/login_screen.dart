import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/utils/validators.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authStateProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.status == AuthStatus.loading;

    ref.listen(authStateProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated && mounted) {
        context.go('/dashboard');
      }
    });

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AdminColors.primary, AdminColors.secondary]),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.admin_panel_settings, size: 32, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text('Admin Login', style: AppTypography.displaySmall.copyWith(color: AdminColors.textPrimary), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Sign in to manage PopCut', style: AppTypography.bodyMedium.copyWith(color: AdminColors.textSecondary), textAlign: TextAlign.center),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: AdminColors.textPrimary),
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined, size: 18)),
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                    style: const TextStyle(color: AdminColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 24),
                  if (authState.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AdminColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AdminColors.error.withValues(alpha: 0.3))),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, size: 16, color: AdminColors.error),
                            const SizedBox(width: 8),
                            Expanded(child: Text(authState.error!, style: const TextStyle(fontSize: 12, color: AdminColors.error))),
                          ],
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    child: isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Sign In'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
