import 'package:flutter/material.dart';

class DesignTokens extends ThemeExtension<DesignTokens> {
  final double space2;
  final double space4;
  final double space8;
  final double space12;
  final double space16;
  final double space20;
  final double space24;
  final double space32;
  final double space48;
  final double space64;

  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;
  final double radius2xl;
  final double radiusFull;

  final BoxShadow shadowXs;
  final BoxShadow shadowSm;
  final BoxShadow shadowMd;
  final BoxShadow shadowLg;

  final Color success;
  final Color warning;
  final Color info;
  final Color error;
  final Color textPrimary;
  final Color textSecondary;

  const DesignTokens({
    this.space2 = 2.0,
    this.space4 = 4.0,
    this.space8 = 8.0,
    this.space12 = 12.0,
    this.space16 = 16.0,
    this.space20 = 20.0,
    this.space24 = 24.0,
    this.space32 = 32.0,
    this.space48 = 48.0,
    this.space64 = 64.0,
    this.radiusSm = 8.0,
    this.radiusMd = 12.0,
    this.radiusLg = 16.0,
    this.radiusXl = 24.0,
    this.radius2xl = 32.0,
    this.radiusFull = 9999.0,
    this.shadowXs = const BoxShadow(
      blurRadius: 2,
      color: Color(0x08000000),
      offset: Offset(0, 1),
    ),
    this.shadowSm = const BoxShadow(
      blurRadius: 8,
      color: Color(0x0C000000),
      offset: Offset(0, 2),
    ),
    this.shadowMd = const BoxShadow(
      blurRadius: 16,
      color: Color(0x12000000),
      offset: Offset(0, 4),
    ),
    this.shadowLg = const BoxShadow(
      blurRadius: 32,
      color: Color(0x18000000),
      offset: Offset(0, 8),
    ),
    this.success = const Color(0xFF16A34A),
    this.warning = const Color(0xFFF59E0B),
    this.info = const Color(0xFF3B82F6),
    this.error = const Color(0xFFDC2626),
    this.textPrimary = const Color(0xFF0F172A),
    this.textSecondary = const Color(0xFF475569),
  });



  // Semantic Getters
  double get spaceXs => space4;
  double get spaceSm => space8;
  double get spaceMd => space16;
  double get spaceLg => space24;
  double get spaceXl => space32;

  double get radiusXs => radiusSm;

  @override
  DesignTokens copyWith({
    double? space2,
    double? space4,
    double? space8,
    double? space12,
    double? space16,
    double? space20,
    double? space24,
    double? space32,
    double? space48,
    double? space64,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? radius2xl,
    double? radiusFull,
    BoxShadow? shadowXs,
    BoxShadow? shadowSm,
    BoxShadow? shadowMd,
    BoxShadow? shadowLg,
    Color? success,
    Color? warning,
    Color? info,
    Color? error,
    Color? textPrimary,
    Color? textSecondary,
  }) {
    return DesignTokens(
      space2: space2 ?? this.space2,
      space4: space4 ?? this.space4,
      space8: space8 ?? this.space8,
      space12: space12 ?? this.space12,
      space16: space16 ?? this.space16,
      space20: space20 ?? this.space20,
      space24: space24 ?? this.space24,
      space32: space32 ?? this.space32,
      space48: space48 ?? this.space48,
      space64: space64 ?? this.space64,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusXl: radiusXl ?? this.radiusXl,
      radius2xl: radius2xl ?? this.radius2xl,
      radiusFull: radiusFull ?? this.radiusFull,
      shadowXs: shadowXs ?? this.shadowXs,
      shadowSm: shadowSm ?? this.shadowSm,
      shadowMd: shadowMd ?? this.shadowMd,
      shadowLg: shadowLg ?? this.shadowLg,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      error: error ?? this.error,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }


  @override
  DesignTokens lerp(ThemeExtension<DesignTokens>? other, double t) {
    if (other is! DesignTokens) return this;
    return DesignTokens(
      space2: lerpDouble(space2, other.space2, t)!,
      space4: lerpDouble(space4, other.space4, t)!,
      space8: lerpDouble(space8, other.space8, t)!,
      space12: lerpDouble(space12, other.space12, t)!,
      space16: lerpDouble(space16, other.space16, t)!,
      space20: lerpDouble(space20, other.space20, t)!,
      space24: lerpDouble(space24, other.space24, t)!,
      space32: lerpDouble(space32, other.space32, t)!,
      space48: lerpDouble(space48, other.space48, t)!,
      space64: lerpDouble(space64, other.space64, t)!,
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
      radiusXl: lerpDouble(radiusXl, other.radiusXl, t)!,
      radius2xl: lerpDouble(radius2xl, other.radius2xl, t)!,
      radiusFull: lerpDouble(radiusFull, other.radiusFull, t)!,
      shadowXs: BoxShadow.lerp(shadowXs, other.shadowXs, t)!,
      shadowSm: BoxShadow.lerp(shadowSm, other.shadowSm, t)!,
      shadowMd: BoxShadow.lerp(shadowMd, other.shadowMd, t)!,
      shadowLg: BoxShadow.lerp(shadowLg, other.shadowLg, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      error: Color.lerp(error, other.error, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }



  double? lerpDouble(num? a, num? b, double t) {
    if (a == null && b == null) return null;
    return (a ?? 0).toDouble() + ((b ?? 0).toDouble() - (a ?? 0).toDouble()) * t;
  }
}
