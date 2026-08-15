import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
                          const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                            onPressed: () => Navigator.pop(modalCtx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Full Name Field
                      CustomTextField(
                        controller: nameController,
                        labelText: 'Full Name',
                        hintText: 'Enter full name',
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF64748B), size: 20),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 14),

                      // Phone Field
                      CustomTextField(
                        controller: phoneController,
                        labelText: 'Phone Number',
                        hintText: 'e.g. +1 234 567 8900',
                        prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF64748B), size: 20),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),

                      // Department Dropdown
                      const Text(
                        'Department',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: authCubit.departments.contains(selectedDept) ? selectedDept : authCubit.departments.first,
                            isExpanded: true,
                            items: authCubit.departments.map((dept) {
                              return DropdownMenuItem(
                                value: dept,
                                child: Text(dept, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
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
                            backgroundColor: const Color(0xFF2563EB),
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
                          child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
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
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: const Text(
          'Are you sure you want to sign out from your HelpDesk account?',
          style: TextStyle(color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
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
            child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = AuthCubit.get(context);

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
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Profile',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: const Color(0xFF0F172A),
                        child: Text(
                          current.name.isNotEmpty ? current.name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
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
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
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
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
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
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              current.role.displayName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              current.department,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
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
                _buildSectionHeader('WORKSPACE DETAILS'),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildCleanTile(
                        label: 'Role',
                        value: current.role.displayName,
                      ),
                      const Divider(height: 1, indent: 16, color: Color(0xFFF1F5F9)),
                      _buildCleanTile(
                        label: 'Department',
                        value: current.department,
                      ),
                      const Divider(height: 1, indent: 16, color: Color(0xFFF1F5F9)),
                      _buildCleanTile(
                        label: 'Phone',
                        value: current.phone.isNotEmpty ? current.phone : 'Not provided',
                      ),
                      const Divider(height: 1, indent: 16, color: Color(0xFFF1F5F9)),
                      _buildCleanTile(
                        label: 'Member Since',
                        value: '${current.createdAt.day}/${current.createdAt.month}/${current.createdAt.year}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Actions & Danger Group
                _buildSectionHeader('SETTINGS & SECURITY'),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        leading: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF2563EB)),
                        title: const Text(
                          'Edit Profile Details',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF94A3B8)),
                        onTap: () => _showEditProfileModal(context, authCubit),
                      ),
                      const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                      const ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        leading: Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFF64748B)),
                        title: Text(
                          'App Version',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
                        ),
                        trailing: Text(
                          '1.0.0',
                          style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
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
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xFFFEE2E2)),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
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
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
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
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF0F172A),
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
