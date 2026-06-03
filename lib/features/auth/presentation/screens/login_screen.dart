import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../routes/app_router.dart';
import '../providers/login_state_provider.dart';

/// Login screen for user authentication
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _usePhoneLogin = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loginState = ref.watch(loginStateProvider);

    // Listen to login state changes
    ref.listen<LoginState>(loginStateProvider, (previous, next) {
      if (next is LoginSuccess) {
        // Navigate to dashboard on successful login
        context.go(AppRoutes.dashboard);
      } else if (next is LoginFailure) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App logo
                Icon(
                  Icons.agriculture,
                  size: 80.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: 16.h),
                
                // App name
                Text(
                  l10n.appName,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                
                // Subtitle
                Text(
                  l10n.appSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48.h),
                
                // Login form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email/Phone input
                      TextFormField(
                        controller: _emailController,
                        keyboardType: _usePhoneLogin
                            ? TextInputType.phone
                            : TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: _usePhoneLogin
                              ? l10n.phoneNumber
                              : l10n.email,
                          prefixIcon: Icon(
                            _usePhoneLogin ? Icons.phone : Icons.email,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        validator: _usePhoneLogin
                            ? Validators.validatePhoneNumber
                            : Validators.validateEmail,
                        enabled: loginState is! LoginLoading,
                      ),
                      SizedBox(height: 16.h),
                      
                      // Password input
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: l10n.password,
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            Validators.validateRequired(value, 'Password'),
                        enabled: loginState is! LoginLoading,
                      ),
                      SizedBox(height: 8.h),
                      
                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: loginState is LoginLoading
                              ? null
                              : () {
                                  context.push(AppRoutes.forgotPassword);
                                },
                          child: Text(l10n.forgotPassword),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      
                      // Login button
                      ElevatedButton(
                        onPressed: loginState is LoginLoading
                            ? null
                            : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: loginState is LoginLoading
                            ? SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                l10n.login,
                                style: TextStyle(fontSize: 16.sp),
                              ),
                      ),
                      SizedBox(height: 16.h),
                      
                      // Toggle login method
                      TextButton(
                        onPressed: loginState is LoginLoading
                            ? null
                            : () {
                                setState(() {
                                  _usePhoneLogin = !_usePhoneLogin;
                                  _emailController.clear();
                                });
                              },
                        child: Text(
                          _usePhoneLogin
                              ? l10n.loginWithEmail
                              : l10n.loginWithPhone,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final notifier = ref.read(loginStateProvider.notifier);
      
      if (_usePhoneLogin) {
        notifier.signInWithPhone(
          phoneNumber: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        notifier.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
    }
  }
}
