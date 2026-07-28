import '/components/button/button_widget.dart';
import '/components/recent_report_item/recent_report_item_widget.dart';
import '/components/report_category_card/report_category_card_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'analytics_reports_widget.dart' show AnalyticsReportsWidget;
import 'package:flutter/material.dart';

class AnalyticsReportsModel extends FlutterFlowModel<AnalyticsReportsWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Button.
  late ButtonModel buttonModel1;
  // Model for ReportCategoryCard.
  late ReportCategoryCardModel reportCategoryCardModel1;
  // Model for ReportCategoryCard.
  late ReportCategoryCardModel reportCategoryCardModel2;
  // Model for ReportCategoryCard.
  late ReportCategoryCardModel reportCategoryCardModel3;
  // Model for ReportCategoryCard.
  late ReportCategoryCardModel reportCategoryCardModel4;
  // Model for Button.
  late ButtonModel buttonModel2;
  // Model for RecentReportItem.
  late RecentReportItemModel recentReportItemModel1;
  // Model for RecentReportItem.
  late RecentReportItemModel recentReportItemModel2;
  // Model for RecentReportItem.
  late RecentReportItemModel recentReportItemModel3;
  // Model for RecentReportItem.
  late RecentReportItemModel recentReportItemModel4;

  @override
  void initState(BuildContext context) {
    buttonModel1 = createModel(context, () => ButtonModel());
    reportCategoryCardModel1 =
        createModel(context, () => ReportCategoryCardModel());
    reportCategoryCardModel2 =
        createModel(context, () => ReportCategoryCardModel());
    reportCategoryCardModel3 =
        createModel(context, () => ReportCategoryCardModel());
    reportCategoryCardModel4 =
        createModel(context, () => ReportCategoryCardModel());
    buttonModel2 = createModel(context, () => ButtonModel());
    recentReportItemModel1 =
        createModel(context, () => RecentReportItemModel());
    recentReportItemModel2 =
        createModel(context, () => RecentReportItemModel());
    recentReportItemModel3 =
        createModel(context, () => RecentReportItemModel());
    recentReportItemModel4 =
        createModel(context, () => RecentReportItemModel());
  }

  @override
  void dispose() {
    buttonModel1.dispose();
    reportCategoryCardModel1.dispose();
    reportCategoryCardModel2.dispose();
    reportCategoryCardModel3.dispose();
    reportCategoryCardModel4.dispose();
    buttonModel2.dispose();
    recentReportItemModel1.dispose();
    recentReportItemModel2.dispose();
    recentReportItemModel3.dispose();
    recentReportItemModel4.dispose();
  }
}
