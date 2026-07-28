import '/components/button/button_widget.dart';
import '/components/summary_stat/summary_stat_widget.dart';
import '/components/transaction_item2/transaction_item2_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'finance_cash_book_widget.dart' show FinanceCashBookWidget;
import 'package:flutter/material.dart';

class FinanceCashBookModel extends FlutterFlowModel<FinanceCashBookWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SummaryStat.
  late SummaryStatModel summaryStatModel1;
  // Model for SummaryStat.
  late SummaryStatModel summaryStatModel2;
  // Model for Button.
  late ButtonModel buttonModel1;
  // Model for TransactionItem.
  late TransactionItem2Model transactionItemModel1;
  // Model for TransactionItem.
  late TransactionItem2Model transactionItemModel2;
  // Model for TransactionItem.
  late TransactionItem2Model transactionItemModel3;
  // Model for TransactionItem.
  late TransactionItem2Model transactionItemModel4;
  // Model for TransactionItem.
  late TransactionItem2Model transactionItemModel5;
  // Model for Button.
  late ButtonModel buttonModel2;
  // Model for Button.
  late ButtonModel buttonModel3;

  @override
  void initState(BuildContext context) {
    summaryStatModel1 = createModel(context, () => SummaryStatModel());
    summaryStatModel2 = createModel(context, () => SummaryStatModel());
    buttonModel1 = createModel(context, () => ButtonModel());
    transactionItemModel1 = createModel(context, () => TransactionItem2Model());
    transactionItemModel2 = createModel(context, () => TransactionItem2Model());
    transactionItemModel3 = createModel(context, () => TransactionItem2Model());
    transactionItemModel4 = createModel(context, () => TransactionItem2Model());
    transactionItemModel5 = createModel(context, () => TransactionItem2Model());
    buttonModel2 = createModel(context, () => ButtonModel());
    buttonModel3 = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    summaryStatModel1.dispose();
    summaryStatModel2.dispose();
    buttonModel1.dispose();
    transactionItemModel1.dispose();
    transactionItemModel2.dispose();
    transactionItemModel3.dispose();
    transactionItemModel4.dispose();
    transactionItemModel5.dispose();
    buttonModel2.dispose();
    buttonModel3.dispose();
  }
}
