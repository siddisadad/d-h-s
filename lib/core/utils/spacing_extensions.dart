import 'package:flutter/material.dart';
import '../design_system/theme/app_theme.dart';

extension SpacingExtensions on num {
  /// Vertical spacing
  Widget vGap() => SizedBox(height: toDouble());
  
  /// Horizontal spacing
  Widget hGap() => SizedBox(width: toDouble());
}

extension ContextSpacingExtensions on BuildContext {
  // Quick access to common gaps using tokens from theme extension
  Widget get gap4 => SizedBox(height: tokens.space4, width: tokens.space4);
  Widget get gap8 => SizedBox(height: tokens.space8, width: tokens.space8);
  Widget get gap12 => SizedBox(height: tokens.space12, width: tokens.space12);
  Widget get gap16 => SizedBox(height: tokens.space16, width: tokens.space16);
  Widget get gap24 => SizedBox(height: tokens.space24, width: tokens.space24);
  Widget get gap32 => SizedBox(height: tokens.space32, width: tokens.space32);
}
