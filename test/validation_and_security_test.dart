import 'package:flutter_test/flutter_test.dart';
import 'package:helpdesk/core/utils/regexes.dart';
import 'package:helpdesk/features/auth/model/user_model.dart';
import 'package:helpdesk/features/tickets/model/ticket_model.dart';

void main() {
  group('Security & Validation Tests - Email and Inputs', () {
    test('Valid email patterns should pass', () {
      expect(AppRegex.isEmailValid('user@example.com'), isTrue);
      expect(AppRegex.isEmailValid('john.doe+work@company.org'), isTrue);
      expect(AppRegex.isEmailValid('support_agent123@sub.domain.co.uk'), isTrue);
    });

    test('Malicious and invalid email inputs should fail', () {
      expect(AppRegex.isEmailValid('plainaddress'), isFalse);
      expect(AppRegex.isEmailValid('@missingusername.com'), isFalse);
      expect(AppRegex.isEmailValid('user@.com'), isFalse);
      expect(AppRegex.isEmailValid('<script>alert("xss")</script>@test.com'), isFalse);
      expect(AppRegex.isEmailValid('admin\' OR 1=1;--@test.com'), isFalse);
      expect(AppRegex.isEmailValid('user@domain..com'), isFalse);
      expect(AppRegex.isEmailValid(''), isFalse);
    });

    test('Phone number validation rules', () {
      expect(AppRegex.isPhoneNumberValid('01012345678'), isTrue);
      expect(AppRegex.isPhoneNumberValid('+201012345678'), isTrue);
      expect(AppRegex.isPhoneNumberValid('12345'), isFalse); // too short
      expect(AppRegex.isPhoneNumberValid('abc12345678'), isFalse); // letters
      expect(AppRegex.isPhoneNumberValid(''), isFalse);
    });

    test('Password complexity regex verification', () {
      expect(AppRegex.hasMinLength('password123'), isTrue);
      expect(AppRegex.hasMinLength('12345'), isFalse); // < 6 chars
    });
  });

  group('Role-Based Access Control (RBAC) & Logic Security Tests', () {
    test('Department matching logic for Support Agents', () {
      // IT Category
      expect(TicketCategory.it.matchesDepartment('IT & Systems'), isTrue);
      expect(TicketCategory.it.matchesDepartment('Technical Support'), isTrue);
      expect(TicketCategory.it.matchesDepartment('Human Resources'), isFalse);

      // HR Category
      expect(TicketCategory.hr.matchesDepartment('Human Resources'), isTrue);
      expect(TicketCategory.hr.matchesDepartment('HR Department'), isTrue);
      expect(TicketCategory.hr.matchesDepartment('Finance'), isFalse);

      // Finance Category
      expect(TicketCategory.finance.matchesDepartment('Finance & Payroll'), isTrue);
      expect(TicketCategory.finance.matchesDepartment('Accounts'), isTrue);
      expect(TicketCategory.finance.matchesDepartment('Facilities'), isFalse);

      // Other Category matches any
      expect(TicketCategory.other.matchesDepartment('Any Department'), isTrue);
    });

    test('User roles serialization & fallback protection against unknown roles', () {
      expect(UserRole.fromString('agent'), UserRole.agent);
      expect(UserRole.fromString('manager'), UserRole.manager);
      expect(UserRole.fromString('employee'), UserRole.employee);
      
      // Tampered / Malicious input defaults securely to employee
      expect(UserRole.fromString('super_admin_injected'), UserRole.employee);
      expect(UserRole.fromString(null), UserRole.employee);
      expect(UserRole.fromString(''), UserRole.employee);
    });

    test('TicketUserModel immutability and data preservation', () {
      const userModel = TicketUserModel(
        uid: 'u_secure_1',
        name: 'Jane Security',
        email: 'jane@sec.com',
        department: 'Cybersecurity',
      );

      final map = userModel.toMap();
      expect(map['uid'], 'u_secure_1');
      expect(map['email'], 'jane@sec.com');

      final deserialized = TicketUserModel.fromMap(map);
      expect(deserialized.uid, 'u_secure_1');
      expect(deserialized.name, 'Jane Security');
      expect(deserialized.department, 'Cybersecurity');
    });
  });
}
