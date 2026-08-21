import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpdesk/core/database/cache/cache_helper.dart';
import 'package:helpdesk/core/database/cache/cache_keys.dart';
import 'package:helpdesk/core/localization/locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(const LocaleState(Locale('en'))) {
    _loadSavedLocale();
  }

  void _loadSavedLocale() {
    final savedCode = CacheHelper.getString(key: CacheKeys.appLocale);
    if (savedCode != null && savedCode.isNotEmpty) {
      emit(LocaleState(Locale(savedCode)));
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (state.locale == locale) return;
    await CacheHelper.saveData(key: CacheKeys.appLocale, value: locale.languageCode);
    emit(LocaleState(locale));
  }

  Future<void> toggleLanguage() async {
    final nextCode = state.isArabic ? 'en' : 'ar';
    await setLocale(Locale(nextCode));
  }
}
