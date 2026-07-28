import '/components/button/button_widget.dart';
import '/components/ledger_stat/ledger_stat_widget.dart';
import '/components/transaction_item/transaction_item_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'customer_ledger_widget.dart' show CustomerLedgerWidget;
import 'package:flutter/material.dart';

class CustomerLedgerModel extends FlutterFlowModel<CustomerLedgerWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for LedgerStat.
  late LedgerStatModel ledgerStatModel1;
  // Model for LedgerStat.
  late LedgerStatModel ledgerStatModel2;
  // Model for TransactionItem.
  late TransactionItemModel transactionItemModel1;
  // Model for TransactionItem.
  late TransactionItemModel transactionItemModel2;
  // Model for TransactionItem.
  late TransactionItemModel transactionItemModel3;
  // Model for TransactionItem.
  late TransactionItemModel transactionItemModel4;
  // Model for TransactionItem.
  late TransactionItemModel transactionItemModel5;
  // Model for Button.
  late ButtonModel buttonModel1;
  // Model for Button.
  late ButtonModel buttonModel2;

  @override
  void initState(BuildContext context) {
    ledgerStatModel1 = createModel(context, () => LedgerStatModel());
    ledgerStatModel2 = createModel(context, () => LedgerStatModel());
    transactionItemModel1 = createModel(context, () => TransactionItemModel());
    transactionItemModel2 = createModel(context, () => TransactionItemModel());
    transactionItemModel3 = createModel(context, () => TransactionItemModel());
    transactionItemModel4 = createModel(context, () => TransactionItemModel());
    transactionItemModel5 = createModel(context, () => TransactionItemModel());
    buttonModel1 = createModel(context, () => ButtonModel());
    buttonModel2 = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    ledgerStatModel1.dispose();
    ledgerStatModel2.dispose();
    transactionItemModel1.dispose();
    transactionItemModel2.dispose();
    transactionItemModel3.dispose();
    transactionItemModel4.dispose();
    transactionItemModel5.dispose();
    buttonModel1.dispose();
    buttonModel2.dispose();
  }
}
