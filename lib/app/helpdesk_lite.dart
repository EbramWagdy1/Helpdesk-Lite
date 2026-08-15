import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpdesk/core/routing/app_router.dart';
import 'package:helpdesk/core/utils/app_colors.dart';
import 'package:helpdesk/core/utils/app_strings.dart';
import 'package:helpdesk/features/auth/view_model/auth_cubit.dart';

class HelpDeskLiteApp extends StatelessWidget {
  const HelpDeskLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: AppStrings.appName,
        routerConfig: AppRouter.router,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            surface: AppColors.surface,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.surface,
            elevation: 0,
            iconTheme: IconThemeData(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
