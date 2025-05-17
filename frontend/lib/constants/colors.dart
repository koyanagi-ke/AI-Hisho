import 'package:flutter/material.dart';

class AppColors {
  // テーマカラー
  static const Map<String, Color> themeColors = {
    'default': primary,
    'orange': Color(0xFFF97316),
    'rose': Color(0xFFF43F5E),
    'amber': Color(0xFFF59E0B),
    'emerald': Color(0xFF10B981),
    'blue': Color(0xFF3B82F6),
    'indigo': Color(0xFF6366F1),
  };

  static const Map<String, Color> themeLightColors = {
    'default': Color(0xFFFEF5F0),
    'orange': Color(0xFFFEF5F0),
    'rose': Color(0xFFFEF2F3),
    'amber': Color(0xFFFEF7E6),
    'emerald': Color(0xFFE6F7F2),
    'blue': Color(0xFFEFF6FF),
    'indigo': Color(0xFFEDE9FE),
  };

  // 基本カラー
  static const Color primary = Color(0xFFF97316);
  static const Color primaryLight = Color(0xFFFEF5F0);
  static const Color topBackgroundColor = Color(0xFFFCD5B4);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
}
