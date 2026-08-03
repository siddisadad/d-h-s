import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_bar_provider.g.dart';

class AppBarState {
  final String title;
  final List<Widget>? actions;

  AppBarState({required this.title, this.actions});
}

@riverpod
class AppBarNotifier extends _$AppBarNotifier {
  @override
  AppBarState build() {
    return AppBarState(title: 'DCI ERP');
  }

  void update({required String title, List<Widget>? actions}) {
    // Avoid unnecessary updates
    if (state.title == title && state.actions == actions) return;
    
    // Schedule update for next frame to avoid "building during build" errors
    Future.microtask(() {
      state = AppBarState(title: title, actions: actions);
    });
  }
}
