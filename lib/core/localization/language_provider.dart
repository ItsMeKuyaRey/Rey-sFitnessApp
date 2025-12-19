// lib/core/localization/language_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LanguageProvider() {
    _loadFromPrefs(); // Load saved language on app start
  }

  // LOAD SAVED LANGUAGE FROM DISK
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  // CHANGE LANGUAGE + SAVE TO DISK
  Future<void> setLocale(Locale locale) async {
    if (!AppLocalizations.supportedLocales.contains(locale)) {
      return; // Safety check
    }

    if (_locale == locale) return; // No change needed

    _locale = locale;

    // SAVE TO SHARED PREFERENCES
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);

    // THIS TRIGGERS REBUILD OF ENTIRE APP WITH NEW LANGUAGE
    notifyListeners();
  }

  // BONUS: Easy method to change by code
  Future<void> changeLanguage(String languageCode) async {
    final newLocale = Locale(languageCode);
    await setLocale(newLocale);
  }
}