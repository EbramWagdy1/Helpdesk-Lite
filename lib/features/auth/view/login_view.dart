import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:helpdesk/core/routing/app_routes.dart';
import 'package:helpdesk/core/utils/app_assets.dart';
import 'package:helpdesk/core/utils/app_colors.dart';
import 'package:helpdesk/core/utils/app_strings.dart';
import 'package:helpdesk/core/utils/app_text_style.dart';
import 'package:helpdesk/core/utils/regexes.dart';
import 'package:helpdesk/core/widgets/custom_button.dart';
import 'package:helpdesk/core/widgets/custom_snackbar.dart';
import 'package:helpdesk/core/widgets/custom_text_field.dart';
import 'package:helpdesk/features/auth/view_model/auth_cubit.dart';
import 'package:helpdesk/features/auth/view_model/auth_state.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(AuthCubit cubit) {
    if (_formKey.currentState?.validate() ?? false) {
      cubit.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccessState) {
              CustomSnackBar.showSuccess(context, message: state.message);
              context.go(AppRoutes.tasks);
            } else if (state is AuthErrorState) {
              CustomSnackBar.showError(context, message: state.errorMessage);
            }
          },
          builder: (context, state) {
            final cubit = AuthCubit.get(context);
            final isLoading = state is AuthLoadingState;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // App Logo & Header
                      Center(
                        child: Container(
                          width: 84,
                          height: 84,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppStrings.welcomeBack,
                        style: AppTextStyles.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to your HelpDesk workspace',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Email Field
                      CustomTextField(
                        controller: _emailController,
                        labelText: AppStrings.email,
                        hintText: AppStrings.emailHint,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.requiredField;
                          }
                          if (!AppRegex.isEmailValid(value.trim())) {
                            return AppStrings.invalidEmail;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      CustomTextField(
                        controller: _passwordController,
                        labelText: AppStrings.password,
                        hintText: AppStrings.passwordHint,
                        obscureText: cubit.isPasswordHidden,
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            cubit.isPasswordHidden
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: cubit.togglePasswordVisibility,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.requiredField;
                          }
                          if (value.length < 6) {
                            return AppStrings.invalidPassword;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Remember Me & Help
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: cubit.rememberMe,
                                  onChanged: cubit.toggleRememberMe,
                                  activeColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppStrings.rememberMe,
                                style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              CustomSnackBar.showSuccess(
                                context,
                                message: 'Password reset link sent to your registered email.',
                              );
                            },
                            child: Text(
                              AppStrings.forgotPassword,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Sign In Button
                      CustomButton(
                        text: AppStrings.signIn,
                        isLoading: isLoading,
                        onPressed: () => _handleLogin(cubit),
                      ),
                      const SizedBox(height: 24),

                      // Navigation to Sign Up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.dontHaveAccount,
                            style: AppTextStyles.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.signup),
                            child: Text(
                              AppStrings.signUp,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
