import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

enum ConnectivityStatus { online, offline }

@riverpod
class ConnectivityNotifier extends _$ConnectivityNotifier {
  @override
  Stream<ConnectivityStatus> build() {
    return Connectivity().onConnectivityChanged.map((results) {
      // connectivity_plus 6.x returns a List<ConnectivityResult>
      if (results.isEmpty || results.contains(ConnectivityResult.none)) {
        return ConnectivityStatus.offline;
      }
      return ConnectivityStatus.online;
    });
  }
}
