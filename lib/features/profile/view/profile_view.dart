import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpdesk/core/extensions/localization_extension.dart';
import 'package:helpdesk/core/localization/locale_cubit.dart';
import 'package:helpdesk/core/localization/locale_state.dart';
import 'package:helpdesk/core/theme/theme_cubit.dart';
import 'package:helpdesk/core/theme/theme_state.dart';
import 'package:helpdesk/core/widgets/custom_snackbar.dart';
import 'package:helpdesk/core/widgets/custom_text_field.dart';
import 'package:helpdesk/core/widgets/verified_badge_widget.dart';
import 'package:helpdesk/features/auth/model/user_model.dart';
import 'package:helpdesk/features/auth/view_model/auth_cubit.dart';
import 'package:helpdesk/features/auth/view_model/auth_state.dart';

class ProfileView extends StatefulWidget {
  final UserModel user;

  const ProfileView({
    super.key,
    required this.user,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late UserModel _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  void _showEditProfileModal(BuildContext context, AuthCubit authCubit) {
    final nameController = TextEditingController(text: _user.name);
    final phoneController = TextEditingController(text: _user.phone);
    String selectedDept = _user.department;
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.l10n.editProfile,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                            onPressed: () => Navigator.pop(modalCtx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Full Name Field
                      CustomTextField(
                        controller: nameController,
                        labelText: context.l10n.fullName,
                        hintText: context.l10n.enterFullName,
                        prefixIcon: Icon(Icons.person_outline_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), size: 20),
                        validator: (v) => (v == null || v.trim().isEmpty) ? context.l10n.pleaseEnterName : null,
                      ),
                      const SizedBox(height: 14),

                      // Phone Field
                      CustomTextField(
                        controller: phoneController,
                        labelText: context.l10n.phoneNumber,
                        hintText: context.l10n.phoneHint,
                        prefixIcon: Icon(Icons.phone_outlined, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), size: 20),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),

                      // Department Dropdown
                      Text(
                        context.l10n.department,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: authCubit.departments.contains(selectedDept) ? selectedDept : authCubit.departments.first,
                            dropdownColor: theme.cardColor,
                            isExpanded: true,
                            items: authCubit.departments.map((dept) {
                              return DropdownMenuItem(
                                value: dept,
                                child: Text(
                                  context.getLocalizedDepartment(dept),
                                  style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() {
                                  selectedDept = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            if (formKey.currentState?.validate() ?? false) {
                              Navigator.pop(modalCtx);
                              await authCubit.updateProfile(
                                name: nameController.text.trim(),
                                phone: phoneController.text.trim(),
                                department: selectedDept,
                              );
                            }
                          },
                          child: Text(
                            context.l10n.saveChanges,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, AuthCubit authCubit) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          context.l10n.signOut,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          context.l10n.signOutPrompt,
          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(context.l10n.cancel, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await authCubit.logout();
            },
            child: Text(context.l10n.signOut, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = AuthCubit.get(context);
    final theme = Theme.of(context);

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthProfileUpdatedState) {
          setState(() {
            _user = state.user;
          });
          CustomSnackBar.showSuccess(context, message: state.message);
        } else if (state is AuthErrorState) {
          CustomSnackBar.showError(context, message: state.errorMessage);
        }
      },
      builder: (context, state) {
        final current = authCubit.currentUser ?? _user;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.appBarTheme.backgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              context.l10n.profile,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                // Top Identity Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          current.name.isNotEmpty ? current.name[0].toUpperCase() : 'U',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // User Name + Verified Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              current.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (current.isVerified) ...[
                            const SizedBox(width: 6),
                            const VerifiedBadgeWidget(size: 18),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),

                      // Email
                      Text(
                        current.email,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Role & Department Tags
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              current.role.getLocalizedLabel(context),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              context.getLocalizedDepartment(current.department),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Workspace Information Group
                _buildSectionHeader(context.l10n.workspaceDetails),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      _buildCleanTile(
                        context: context,
                        label: context.l10n.role,
                        value: current.role.getLocalizedLabel(context),
                      ),
                      Divider(height: 1, indent: 16, color: theme.dividerColor),
                      _buildCleanTile(
                        context: context,
                        label: context.l10n.department,
                        value: context.getLocalizedDepartment(current.department),
                      ),
                      Divider(height: 1, indent: 16, color: theme.dividerColor),
                      _buildCleanTile(
                        context: context,
                        label: context.l10n.phone,
                        value: current.phone.isNotEmpty ? current.phone : context.l10n.notProvided,
                      ),
                      Divider(height: 1, indent: 16, color: theme.dividerColor),
                      _buildCleanTile(
                        context: context,
                        label: context.l10n.memberSince,
                        value: '${current.createdAt.day}/${current.createdAt.month}/${current.createdAt.year}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Actions & Danger Group
                _buildSectionHeader(context.l10n.settingsAndSecurity),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      BlocBuilder<LocaleCubit, LocaleState>(
                        builder: (context, localeState) {
                          final isArabic = localeState.isArabic;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                            leading: Icon(
                              Icons.language_rounded,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            title: Text(
                              context.l10n.languageTitle,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              isArabic ? 'العربية (RTL)' : 'English (LTR)',
                              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.25)),
                              ),
                              child: Text(
                                isArabic ? 'English' : 'عربي',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            onTap: () {
                              context.read<LocaleCubit>().toggleLanguage();
                            },
                          );
                        },
                      ),
                      Divider(height: 1, indent: 56, color: theme.dividerColor),
                      BlocBuilder<ThemeCubit, ThemeState>(
                        builder: (context, themeState) {
                          final isDark = themeState.themeMode == ThemeMode.dark;
                          return SwitchListTile.adaptive(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                            secondary: Icon(
                              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                              size: 20,
                              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF2563EB),
                            ),
                            title: Text(
                              context.l10n.darkTheme,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              isDark ? context.l10n.darkModeEnabled : context.l10n.lightModeEnabled,
                              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                            ),
                            value: isDark,
                            onChanged: (val) {
                              context.read<ThemeCubit>().toggleTheme(val);
                            },
                          );
                        },
                      ),
                      Divider(height: 1, indent: 56, color: theme.dividerColor),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        leading: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF2563EB)),
                        title: Text(
                          context.l10n.editProfileDetails,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        trailing: Icon(Icons.chevron_right_rounded, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                        onTap: () => _showEditProfileModal(context, authCubit),
                      ),
                      Divider(height: 1, indent: 56, color: theme.dividerColor),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        leading: Icon(Icons.info_outline_rounded, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                        title: Text(
                          context.l10n.appVersion,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        trailing: Text(
                          '1.0.0',
                          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Out Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      backgroundColor: theme.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: Text(
                      context.l10n.signOut,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    onPressed: () => _showLogoutDialog(context, authCubit),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 4),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildCleanTile({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
