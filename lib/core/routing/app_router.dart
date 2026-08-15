import 'package:go_router/go_router.dart';
import 'package:helpdesk/core/routing/app_routes.dart';
import 'package:helpdesk/features/auth/view/login_view.dart';
import 'package:helpdesk/features/auth/view/signup_view.dart';
import 'package:helpdesk/features/splash/view/splash_view.dart';
import 'package:helpdesk/features/tickets/view/ticket_list_view.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignUpView(),
      ),
      GoRoute(
        path: AppRoutes.tickets,
        builder: (context, state) => const TicketListView(),
      ),
    ],
  );
}
