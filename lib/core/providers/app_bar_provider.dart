import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_bar_provider.g.dart';

class AppBarState {
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  AppBarState({required this.title, this.actions, this.floatingActionButton});
}

@riverpod
class AppBarNotifier extends _$AppBarNotifier {
  @override
  AppBarState build() {
    return AppBarState(title: 'DCI ERP');
  }

  void update({required String title, List<Widget>? actions, Widget? floatingActionButton}) {
    // Schedule update for next frame to avoid "building during build" errors
    Future.microtask(() {
      state = AppBarState(title: title, actions: actions, floatingActionButton: floatingActionButton);
    });
  }
}
