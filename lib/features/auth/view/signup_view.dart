import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:helpdesk/core/extensions/localization_extension.dart';
import 'package:helpdesk/core/routing/app_routes.dart';
import 'package:helpdesk/core/utils/app_assets.dart';
import 'package:helpdesk/core/utils/regexes.dart';
import 'package:helpdesk/core/widgets/custom_button.dart';
import 'package:helpdesk/core/widgets/custom_snackbar.dart';
import 'package:helpdesk/core/widgets/custom_text_field.dart';
import 'package:helpdesk/features/auth/model/user_model.dart';
import 'package:helpdesk/features/auth/view_model/auth_cubit.dart';
import 'package:helpdesk/features/auth/view_model/auth_state.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp(AuthCubit cubit) {
    if (_formKey.currentState?.validate() ?? false) {
      cubit.selectRole(UserRole.employee);
      cubit.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.l10n.createAccount,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.registerSubtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Department Dropdown
                      Text(
                        context.l10n.department,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: cubit.selectedDepartment,
                            dropdownColor: theme.cardColor,
                            isExpanded: true,
                            icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.primary),
                            items: cubit.departments.map((dept) {
                              return DropdownMenuItem<String>(
                                value: dept,
                                child: Text(
                                  context.getLocalizedDepartment(dept),
                                  style: TextStyle(color: theme.colorScheme.onSurface),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) cubit.selectDepartment(val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Full Name Field
                      CustomTextField(
                        controller: _nameController,
                        labelText: context.l10n.fullName,
                        hintText: context.l10n.fullNameHint,
                        prefixIcon: Icon(Icons.person_outline_rounded, color: theme.colorScheme.primary),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.l10n.requiredField;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      CustomTextField(
                        controller: _emailController,
                        labelText: context.l10n.email,
                        hintText: context.l10n.emailHint,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.primary),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.l10n.requiredField;
                          }
                          if (!AppRegex.isEmailValid(value.trim())) {
                            return context.l10n.invalidEmail;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone Field
                      CustomTextField(
                        controller: _phoneController,
                        labelText: context.l10n.phone,
                        hintText: context.l10n.phoneHint,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icon(Icons.phone_outlined, color: theme.colorScheme.primary),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.l10n.requiredField;
                          }
                          if (!AppRegex.isPhoneNumberValid(value.trim())) {
                            return context.l10n.invalidPhone;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      CustomTextField(
                        controller: _passwordController,
                        labelText: context.l10n.password,
                        hintText: context.l10n.passwordHint,
                        obscureText: cubit.isPasswordHidden,
                        prefixIcon: Icon(Icons.lock_outline_rounded, color: theme.colorScheme.primary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            cubit.isPasswordHidden
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          onPressed: cubit.togglePasswordVisibility,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.l10n.requiredField;
                          }
                          if (value.length < 6) {
                            return context.l10n.invalidPassword;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Field
                      CustomTextField(
                        controller: _confirmPasswordController,
                        labelText: context.l10n.confirmPassword,
                        hintText: context.l10n.confirmPasswordHint,
                        obscureText: cubit.isConfirmPasswordHidden,
                        prefixIcon: Icon(Icons.lock_reset_rounded, color: theme.colorScheme.primary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            cubit.isConfirmPasswordHidden
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          onPressed: cubit.toggleConfirmPasswordVisibility,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.l10n.requiredField;
                          }
                          if (value != _passwordController.text) {
                            return context.l10n.passwordMismatch;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      CustomButton(
                        text: context.l10n.signUp,
                        isLoading: isLoading,
                        onPressed: () => _handleSignUp(cubit),
                      ),
                      const SizedBox(height: 16),

                      // Navigate to Sign In
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.l10n.alreadyHaveAccount,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Text(
                              context.l10n.signIn,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
