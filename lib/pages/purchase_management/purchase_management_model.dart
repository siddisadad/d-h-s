import '/components/button/button_widget.dart';
import '/components/purchase_stat_card/purchase_stat_card_widget.dart';
import '/components/purchase_transaction_item/purchase_transaction_item_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'purchase_management_widget.dart' show PurchaseManagementWidget;
import 'package:flutter/material.dart';

class PurchaseManagementModel
    extends FlutterFlowModel<PurchaseManagementWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for TextField.
  late TextFieldModel textFieldModel;
  // Model for PurchaseStatCard.
  late PurchaseStatCardModel purchaseStatCardModel1;
  // Model for PurchaseStatCard.
  late PurchaseStatCardModel purchaseStatCardModel2;
  // Model for Button.
  late ButtonModel buttonModel1;
  // Model for Button.
  late ButtonModel buttonModel2;
  // Model for PurchaseTransactionItem.
  late PurchaseTransactionItemModel purchaseTransactionItemModel1;
  // Model for PurchaseTransactionItem.
  late PurchaseTransactionItemModel purchaseTransactionItemModel2;
  // Model for PurchaseTransactionItem.
  late PurchaseTransactionItemModel purchaseTransactionItemModel3;
  // Model for PurchaseTransactionItem.
  late PurchaseTransactionItemModel purchaseTransactionItemModel4;
  // Model for Button.
  late ButtonModel buttonModel3;

  @override
  void initState(BuildContext context) {
    textFieldModel = createModel(context, () => TextFieldModel());
    purchaseStatCardModel1 =
        createModel(context, () => PurchaseStatCardModel());
    purchaseStatCardModel2 =
        createModel(context, () => PurchaseStatCardModel());
    buttonModel1 = createModel(context, () => ButtonModel());
    buttonModel2 = createModel(context, () => ButtonModel());
    purchaseTransactionItemModel1 =
        createModel(context, () => PurchaseTransactionItemModel());
    purchaseTransactionItemModel2 =
        createModel(context, () => PurchaseTransactionItemModel());
    purchaseTransactionItemModel3 =
        createModel(context, () => PurchaseTransactionItemModel());
    purchaseTransactionItemModel4 =
        createModel(context, () => PurchaseTransactionItemModel());
    buttonModel3 = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    textFieldModel.dispose();
    purchaseStatCardModel1.dispose();
    purchaseStatCardModel2.dispose();
    buttonModel1.dispose();
    buttonModel2.dispose();
    purchaseTransactionItemModel1.dispose();
    purchaseTransactionItemModel2.dispose();
    purchaseTransactionItemModel3.dispose();
    purchaseTransactionItemModel4.dispose();
    buttonModel3.dispose();
  }
}
