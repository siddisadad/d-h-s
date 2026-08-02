import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'side_nav_provider.g.dart';

@riverpod
class SideNavNotifier extends _$SideNavNotifier {
  @override
  bool build() {
    return true; // Default to expanded
  }

  void toggle() {
    state = !state;
  }

  void setExpanded(bool expanded) {
    state = expanded;
  }
}
