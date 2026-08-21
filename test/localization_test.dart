import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helpdesk/core/l10n/app_localizations.dart';
import 'package:helpdesk/core/localization/locale_state.dart';
import 'package:helpdesk/core/theme/theme_state.dart';

void main() {
  group('Localization & RTL/LTR Tests', () {
    test('LocaleState correctly identifies Arabic and RTL', () {
      const enState = LocaleState(Locale('en'));
      expect(enState.isArabic, false);
      expect(enState.isRTL, false);

      const arState = LocaleState(Locale('ar'));
      expect(arState.isArabic, true);
      expect(arState.isRTL, true);
    });

    testWidgets('AppLocalizations loads English strings correctly', (WidgetTester tester) async {
      late AppLocalizations localizations;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              localizations = AppLocalizations.of(context)!;
              return Center(
                child: Text(localizations.appName),
              );
            },
          ),
        ),
      );

      expect(find.text('HelpDesk Lite'), findsOneWidget);
      expect(localizations.welcomeBack, 'Welcome Back!');
      expect(localizations.myTickets, 'My Tickets');
      expect(localizations.claimAndStartTicket, 'Claim & Start Ticket');
    });

    testWidgets('AppLocalizations loads Arabic strings with RTL directionality', (WidgetTester tester) async {
      late AppLocalizations localizations;
      late TextDirection textDirection;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: Builder(
            builder: (context) {
              localizations = AppLocalizations.of(context)!;
              textDirection = Directionality.of(context);
              return Center(
                child: Text(localizations.appName),
              );
            },
          ),
        ),
      );

      expect(find.text('مكتب المساعدة لايت'), findsOneWidget);
      expect(textDirection, TextDirection.rtl);
      expect(localizations.welcomeBack, 'مرحبًا بعودتك!');
      expect(localizations.myTickets, 'تذاكري');
      expect(localizations.claimAndStartTicket, 'استلام وبدء التذكرة');
      expect(localizations.description, 'الوصف');
      expect(localizations.workflowProgress, 'مراحل سير العمل');
      expect(localizations.deleteTicket, 'حذف التذكرة');
      expect(localizations.reassign, 'إعادة تعيين');
      expect(localizations.requestedBy, 'صاحب الطلب');
      expect(localizations.unassigned, 'غير مسندة');
      expect(localizations.profile, 'الملف الشخصي');
      expect(localizations.totalAgents, 'إجمالي الأخصائيين');
      expect(localizations.verified, 'معتمد');
      expect(localizations.pending, 'قيد الانتظار');
      expect(localizations.signOut, 'تسجيل الخروج');
      expect(localizations.darkTheme, 'المظهر الداكن');
      expect(localizations.deptIT, 'تكنولوجيا المعلومات والأنظمة');
      expect(localizations.deptHR, 'الموارد البشرية');
    });
  });

  group('Theme & Dark Mode Tests', () {
    test('ThemeState default and dark mode toggling', () {
      const lightTheme = ThemeState(themeMode: ThemeMode.light);
      expect(lightTheme.isDark, false);

      const darkTheme = ThemeState(themeMode: ThemeMode.dark);
      expect(darkTheme.isDark, true);
    });
  });
}
