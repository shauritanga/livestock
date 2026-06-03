import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/forgot_password_state_provider.dart';

/// Screen for password reset functionality
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();
  bool _usePhoneReset = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final forgotPasswordState = ref.watch(forgotPasswordStateProvider);

    // Listen to state changes
    ref.listen<ForgotPasswordState>(forgotPasswordStateProvider, (previous, next) {
      if (next is ForgotPasswordSuccess) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 5),
          ),
        );
      } else if (next is ForgotPasswordFailure) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resetPasswordTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Icon(
                Icons.lock_reset,
                size: 80.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 24.h),

              // Instructions
              Text(
                l10n.resetPasswordInstructions,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),

              // Reset method toggle
              _buildResetMethodToggle(l10n),
              SizedBox(height: 24.h),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Email/Phone input
                    TextFormField(
                      controller: _inputController,
                      keyboardType: _usePhoneReset
                          ? TextInputType.phone
                          : TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: _usePhoneReset
                            ? l10n.phoneNumber
                            : l10n.email,
                        prefixIcon: Icon(
                          _usePhoneReset ? Icons.phone : Icons.email,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: _usePhoneReset
                          ? Validators.validatePhoneNumber
                          : Validators.validateEmail,
                      enabled: forgotPasswordState is! ForgotPasswordLoading,
                    ),
                    SizedBox(height: 24.h),

                    // Submit button
                    ElevatedButton(
                      onPressed: forgotPasswordState is ForgotPasswordLoading
                          ? null
                          : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      child: forgotPasswordState is ForgotPasswordLoading
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _usePhoneReset
                                  ? l10n.sendResetCode
                                  : l10n.sendResetLink,
                              style: TextStyle(fontSize: 16.sp),
                            ),
                    ),
                    SizedBox(height: 16.h),

                    // Back to login button (shown after success)
                    if (forgotPasswordState is ForgotPasswordSuccess)
                      OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: Text(
                          l10n.backToLogin,
                          style: TextStyle(fontSize: 16.sp),
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

  Widget _buildResetMethodToggle(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _usePhoneReset = false;
                  _inputController.clear();
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: !_usePhoneReset
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(7.r),
                    bottomLeft: Radius.circular(7.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email,
                      size: 20.sp,
                      color: !_usePhoneReset
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        l10n.useEmail,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: !_usePhoneReset
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: !_usePhoneReset
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _usePhoneReset = true;
                  _inputController.clear();
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: _usePhoneReset
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(7.r),
                    bottomRight: Radius.circular(7.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone,
                      size: 20.sp,
                      color: _usePhoneReset
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        l10n.usePhone,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: _usePhoneReset
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _usePhoneReset
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final notifier = ref.read(forgotPasswordStateProvider.notifier);
      final input = _inputController.text.trim();

      if (_usePhoneReset) {
        notifier.sendResetSMS(input);
      } else {
        notifier.sendResetEmail(input);
      }
    }
  }
}
