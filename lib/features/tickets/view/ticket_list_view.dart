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

class TicketListView extends StatelessWidget {
  const TicketListView({super.key});

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
        final currentUser = authCubit.currentUser ??
            UserModel(
              uid: 'guest',
              name: 'Workspace User',
              email: 'user@helpdesk.com',
              role: UserRole.employee,
              createdAt: DateTime.now(),
            );

        // Intelligently render the tailored view according to user role
        switch (currentUser.role) {
          case UserRole.employee:
            return EmployeePortalView(currentUser: currentUser);

          case UserRole.agent:
            return AgentDashboardView(currentUser: currentUser);

          case UserRole.manager:
            return ManagerExecutiveView(currentUser: currentUser);
        }
      },
    );
  }
}
