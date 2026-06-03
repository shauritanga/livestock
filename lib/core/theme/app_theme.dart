import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// Application theme configuration using FlexColorScheme
class AppTheme {
  // Brand colors
  static const Color primaryGreen = Color(0xFF2E7D32); // Dark green
  static const Color accentYellow = Color(0xFFFDD835); // Bright yellow
  
  /// Light theme configuration
  static ThemeData get lightTheme {
    return FlexThemeData.light(
      scheme: FlexScheme.green,
      primary: primaryGreen,
      secondary: accentYellow,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: const FlexSubThemesData(
        elevatedButtonRadius: 12,
        blendOnLevel: 10,
        blendOnColors: false,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
      ),
      scaffoldBackground: Color.fromARGB(250, 255, 255, 255),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
    );
  }
  
  /// Dark theme configuration
  static ThemeData get darkTheme {
    return FlexThemeData.dark(
      scheme: FlexScheme.green,
      primary: primaryGreen,
      secondary: accentYellow,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
    );
  }
  
  // Private constructor to prevent instantiation
  AppTheme._();
}
