import '/components/action_item/action_item_widget.dart';
import '/components/bottom_nav/bottom_nav_widget.dart';
import '/components/button/button_widget.dart';
import '/components/kpi_card/kpi_card_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'main_dashboard_widget.dart' show MainDashboardWidget;
import 'package:flutter/material.dart';

class MainDashboardModel extends FlutterFlowModel<MainDashboardWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for KpiCard.
  late KpiCardModel kpiCardModel1;
  // Model for KpiCard.
  late KpiCardModel kpiCardModel2;
  // Model for KpiCard.
  late KpiCardModel kpiCardModel3;
  // Model for KpiCard.
  late KpiCardModel kpiCardModel4;
  // Model for ActionItem.
  late ActionItemModel actionItemModel1;
  // Model for ActionItem.
  late ActionItemModel actionItemModel2;
  // Model for ActionItem.
  late ActionItemModel actionItemModel3;
  // Model for ActionItem.
  late ActionItemModel actionItemModel4;
  // Model for Button.
  late ButtonModel buttonModel;
  // Model for BottomNav.
  late BottomNavModel bottomNavModel;

  @override
  void initState(BuildContext context) {
    kpiCardModel1 = createModel(context, () => KpiCardModel());
    kpiCardModel2 = createModel(context, () => KpiCardModel());
    kpiCardModel3 = createModel(context, () => KpiCardModel());
    kpiCardModel4 = createModel(context, () => KpiCardModel());
    actionItemModel1 = createModel(context, () => ActionItemModel());
    actionItemModel2 = createModel(context, () => ActionItemModel());
    actionItemModel3 = createModel(context, () => ActionItemModel());
    actionItemModel4 = createModel(context, () => ActionItemModel());
    buttonModel = createModel(context, () => ButtonModel());
    bottomNavModel = createModel(context, () => BottomNavModel());
  }

  @override
  void dispose() {
    kpiCardModel1.dispose();
    kpiCardModel2.dispose();
    kpiCardModel3.dispose();
    kpiCardModel4.dispose();
    actionItemModel1.dispose();
    actionItemModel2.dispose();
    actionItemModel3.dispose();
    actionItemModel4.dispose();
    buttonModel.dispose();
    bottomNavModel.dispose();
  }
}
