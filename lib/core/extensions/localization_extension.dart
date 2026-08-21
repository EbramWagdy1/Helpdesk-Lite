import 'package:flutter/material.dart';
import 'package:helpdesk/core/l10n/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  String getLocalizedDepartment(String? department) {
    if (department == null || department.isEmpty) return l10n.deptGeneral;
    final dept = department.toLowerCase().trim();
    if (dept.contains('it') || dept.contains('system') || dept.contains('tech') || dept.contains('أنظمة') || dept.contains('معلومات')) {
      return l10n.deptIT;
    } else if (dept.contains('hr') || dept.contains('human resource') || dept.contains('بشرية')) {
      return l10n.deptHR;
    } else if (dept.contains('operation') || dept.contains('ops') || dept.contains('عمليات') || dept.contains('تشغيل')) {
      return l10n.deptOperations;
    } else if (dept.contains('finance') || dept.contains('payroll') || dept.contains('account') || dept.contains('مالية') || dept.contains('رواتب')) {
      return l10n.deptFinance;
    } else if (dept.contains('sale') || dept.contains('marketing') || dept.contains('مبيعات') || dept.contains('تسويق')) {
      return l10n.deptSales;
    } else if (dept.contains('customer') || dept.contains('عملاء')) {
      return l10n.deptCustomerSupport;
    } else if (dept.contains('facilit') || dept.contains('office') || dept.contains('مرافق')) {
      return l10n.deptFacilities;
    } else if (dept.contains('general') || dept.contains('عام')) {
      return l10n.deptGeneral;
    }
    return department;
  }
}
