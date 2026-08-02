import 'package:flutter/material.dart';
import '../../domain/entities/report_item.dart';
import '../../domain/repositories/analytics_repository.dart';

enum TimeRange { today, week, month }

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsRepository repository;

  AnalyticsProvider({required this.repository});

  List<ReportItem> _reports = [];
  List<ReportItem> get reports => _reports;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TimeRange _selectedRange = TimeRange.week;
  TimeRange get selectedRange => _selectedRange;

  // Chart Data State (Simulated)
  List<double> salesData = [45, 52, 48, 70, 61, 85, 92];
  List<double> purchaseData = [30, 40, 35, 50, 45, 60, 55];

  void setTimeRange(TimeRange range) {
    _selectedRange = range;
    // Simulate data fetch for range
    if (range == TimeRange.today) {
      salesData = [80, 75, 90, 85];
      purchaseData = [60, 50, 70, 65];
    } else if (range == TimeRange.month) {
      salesData = [200, 250, 180, 300, 400];
      purchaseData = [150, 180, 140, 220, 300];
    } else {
      salesData = [45, 52, 48, 70, 61, 85, 92];
      purchaseData = [30, 40, 35, 50, 45, 60, 55];
    }
    notifyListeners();
  }

  Future<void> fetchReports() async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await repository.getRecentReports();
      result.fold((f) => null, (list) => _reports = list);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> exportToCsv() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    _isLoading = false;
    notifyListeners();
    return true;
  }
}
