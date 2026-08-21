import 'package:flutter/material.dart';

class LocaleState {
  final Locale locale;

  const LocaleState(this.locale);

  bool get isArabic => locale.languageCode == 'ar';
  bool get isRTL => isArabic;
}
