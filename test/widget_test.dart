import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helpdesk/core/l10n/app_localizations.dart';
import 'package:helpdesk/features/tickets/model/ticket_model.dart';
import 'package:helpdesk/features/tickets/widgets/ticket_card_widget.dart';

void main() {
  testWidgets('TicketCardWidget renders title and category properly', (WidgetTester tester) async {
    final ticket = TicketModel(
      id: 'hd_1',
      ticketNumber: 'HD-1001',
      title: 'Server Connection Timeout',
      description: 'The internal dev server is unreachable',
      category: TicketCategory.it,
      priority: TicketPriority.high,
      status: TicketStatus.open,
      createdBy: const TicketUserModel(
        uid: 'user_1',
        name: 'Ahmed Developer',
        email: 'ahmed@company.com',
        department: 'IT & Systems',
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: TicketCardWidget(
            ticket: ticket,
            onTap: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('HD-1001'), findsOneWidget);
    expect(find.text('Server Connection Timeout'), findsOneWidget);
    expect(find.text('IT & Systems'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
  });
}
