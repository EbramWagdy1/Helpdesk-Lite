import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:helpdesk/core/routing/app_routes.dart';
import 'package:helpdesk/features/agent_dashboard/view/agent_dashboard_view.dart';
import 'package:helpdesk/features/auth/model/user_model.dart';
import 'package:helpdesk/features/auth/view_model/auth_cubit.dart';
import 'package:helpdesk/features/auth/view_model/auth_state.dart';
import 'package:helpdesk/features/employee_portal/view/employee_portal_view.dart';
import 'package:helpdesk/features/manager_dashboard/view/manager_executive_view.dart';

import 'package:helpdesk/core/utils/app_colors.dart';

class TicketListView extends StatefulWidget {
  const TicketListView({super.key});

  @override
  State<TicketListView> createState() => _TicketListViewState();
}

class _TicketListViewState extends State<TicketListView> {
  @override
  void initState() {
    super.initState();
    final authCubit = AuthCubit.get(context);
    if (authCubit.currentUser == null) {
      authCubit.checkCurrentUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOutState) {
          context.go(AppRoutes.login);
        }
      },
      builder: (context, authState) {
        final authCubit = AuthCubit.get(context);
        final currentUser = authCubit.currentUser;

        if (currentUser == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          );
        }

        // Intelligently render the tailored view according to user role
        switch (currentUser.role) {
          case UserRole.employee:
            return EmployeePortalView(
              key: ValueKey('view_employee_${currentUser.uid}_${currentUser.role.name}'),
              currentUser: currentUser,
            );

          case UserRole.agent:
            return AgentDashboardView(
              key: ValueKey('view_agent_${currentUser.uid}_${currentUser.role.name}'),
              currentUser: currentUser,
            );

          case UserRole.manager:
            return ManagerExecutiveView(
              key: ValueKey('view_manager_${currentUser.uid}_${currentUser.role.name}'),
              currentUser: currentUser,
            );
        }
      },
    );
  }
}
