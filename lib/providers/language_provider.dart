// lib/providers/language_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  String _selected = 'English';
  bool _disposed = false;

  String get selected => _selected;

  LanguageProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    // BUG FIX: check if disposed before calling notifyListeners()
    // Race condition — widget may be disposed before async _load() completes
    if (_disposed) return;
    _selected = prefs.getString('language') ?? 'English';
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _selected = lang;
    if (!_disposed) notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}