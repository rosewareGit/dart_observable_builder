import 'package:flutter/material.dart';

class AppTheme {
  static const String _fontFamilyLabels = 'Montserrat';
  static const String _fontFamilyText = 'JosefinSans';

  static const Color primaryColor = Color(0xFF073B4C);
  static const Color secondaryColor = Color(0xFF61B3FF);
  static const Color _textColor = Color(0xFF3E3E3E);
  static const Color _textColorDisabled = Color(0xFFC2C2C2);
  static const Color iconColor = Color(0xFF3E3E3E);

  final TabBarTheme _tabBarTheme = TabBarTheme(
    indicatorSize: TabBarIndicatorSize.tab,
    indicatorColor: primaryColor,
    labelColor: _textColor,
    labelStyle: const TextStyle(
      fontFamily: _fontFamilyLabels,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: _textColor,
    ),
    unselectedLabelStyle: const TextStyle(
      fontFamily: _fontFamilyLabels,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: _textColorDisabled,
    ),
    indicator: UnderlineTabIndicator(
      borderSide: const BorderSide(
        color: primaryColor,
        width: 4,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    dividerHeight: 4,
    dividerColor: primaryColor.withOpacity(0.4),
  );

  final IconButtonThemeData _iconButtonTheme = IconButtonThemeData(
    style: ButtonStyle(
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.all(4),
      ),
      iconSize: WidgetStateProperty.all<double>(24),
      iconColor: WidgetStateProperty.all<Color>(Colors.white),
      minimumSize: WidgetStateProperty.all<Size>(const Size(24, 24)),
      backgroundColor: WidgetStateProperty.resolveWith((final Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return primaryColor.withOpacity(0.5);
        }
        if (states.contains(WidgetState.pressed)) {
          return primaryColor.withOpacity(0.8);
        }

        return secondaryColor;
      }),
      shape: WidgetStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    ),
  );

  final AppBarTheme _appBarTheme = const AppBarTheme(
    backgroundColor: Colors.white,
    titleTextStyle: TextStyle(
      fontFamily: _fontFamilyLabels,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: _textColor,
    ),
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
  );

  final DialogTheme _dialogTheme = const DialogTheme(
    backgroundColor: Colors.white,
    titleTextStyle: TextStyle(
      fontFamily: _fontFamilyLabels,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: _textColor,
    ),
    contentTextStyle: TextStyle(
      fontFamily: _fontFamilyText,
      fontSize: 16,
      color: _textColor,
    ),
  );

  ThemeData of(final BuildContext context) {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: _fontFamilyText,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.black,
      ),
      tabBarTheme: _tabBarTheme,
      iconButtonTheme: _iconButtonTheme,
      appBarTheme: _appBarTheme,
      dividerTheme: const DividerThemeData(
        space: 24,
        thickness: 1,
        color: _textColorDisabled,
      ),
      dialogBackgroundColor: Colors.white,
      dialogTheme: _dialogTheme,
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
          textStyle: WidgetStateProperty.resolveWith((final Set<WidgetState> states) {
            const TextStyle baseStyle = TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: _fontFamilyText,
              letterSpacing: -0.24,
            );
            if (states.contains(WidgetState.selected)) {
              return baseStyle.copyWith(fontWeight: FontWeight.bold);
            }
            return baseStyle;
          }),
          visualDensity: VisualDensity.compact,
          backgroundColor: WidgetStateProperty.resolveWith((final Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return primaryColor.withOpacity(0.5);
            }
            if (states.contains(WidgetState.pressed)) {
              return primaryColor.withOpacity(0.8);
            }

            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            }

            return const Color(0xFFC0CAE2);
          }),
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
        ),
      ),
    );
  }
}

class TextStyles {
  TextStyles(this.context);

  final BuildContext context;

  final TextStyle info = const TextStyle(
    color: AppTheme._textColor,
    fontSize: 16,
    fontFamily: AppTheme._fontFamilyText,
    letterSpacing: -0.24,
  );

  final TextStyle infoHighlighted = const TextStyle(
    color: AppTheme._textColor,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: AppTheme._fontFamilyText,
    letterSpacing: -0.24,
  );

  final TextStyle title = const TextStyle(
    color: AppTheme._textColor,
    fontSize: 22,
    fontFamily: AppTheme._fontFamilyLabels,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.24,
  );

  final TextStyle subtitle = const TextStyle(
    color: AppTheme._textColor,
    fontSize: 18,
    fontFamily: AppTheme._fontFamilyLabels,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.24,
  );

  final TextStyle hint = const TextStyle(
    color: AppTheme._textColor,
    fontSize: 14,
    fontFamily: AppTheme._fontFamilyText,
    letterSpacing: -0.24,
  );

  final TextStyle listItem = const TextStyle(
    color: AppTheme._textColor,
    fontSize: 12,
    fontFamily: AppTheme._fontFamilyText,
    letterSpacing: -0.24,
  );
}

extension ContextStyles on BuildContext {
  TextStyles get textStyles => TextStyles(this);
}
