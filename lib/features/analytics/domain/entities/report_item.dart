class ReportItem {
  final String title;
  final String date;
  final String type;
  final String? summary;

  ReportItem({
    required this.title,
    required this.date,
    required this.type,
    this.summary,
  });
}
