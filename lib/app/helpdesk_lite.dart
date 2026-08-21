import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:helpdesk/core/l10n/app_localizations.dart';
import 'package:helpdesk/core/localization/locale_cubit.dart';
import 'package:helpdesk/core/localization/locale_state.dart';
import 'package:helpdesk/core/routing/app_router.dart';
import 'package:helpdesk/core/services/service_locator.dart';
import 'package:helpdesk/core/theme/app_theme.dart';
import 'package:helpdesk/core/theme/theme_cubit.dart';
import 'package:helpdesk/core/theme/theme_state.dart';
import 'package:helpdesk/core/utils/app_strings.dart';
import 'package:helpdesk/features/auth/view_model/auth_cubit.dart';

class HelpDeskLiteApp extends StatelessWidget {
  const HelpDeskLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(),
        ),
        BlocProvider<ThemeCubit>.value(
          value: sl<ThemeCubit>(),
        ),
        BlocProvider<LocaleCubit>.value(
          value: sl<LocaleCubit>(),
        ),
      ],
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, localeState) {
          return BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: AppStrings.appName,
                routerConfig: AppRouter.router,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.themeMode,
                locale: localeState.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
              );
            },
          );
        },
      ),
    );
  }
}
