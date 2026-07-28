import '/components/button/button_widget.dart';
import '/components/item_row/item_row_widget.dart';
import '/components/step_indicator/step_indicator_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'sales_invoice_entry_widget.dart' show SalesInvoiceEntryWidget;
import 'package:flutter/material.dart';

class SalesInvoiceEntryModel extends FlutterFlowModel<SalesInvoiceEntryWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Button.
  late ButtonModel buttonModel1;
  // Model for StepIndicator.
  late StepIndicatorModel stepIndicatorModel1;
  // Model for StepIndicator.
  late StepIndicatorModel stepIndicatorModel2;
  // Model for StepIndicator.
  late StepIndicatorModel stepIndicatorModel3;
  // Model for TextField.
  late TextFieldModel textFieldModel1;
  // Model for Button.
  late ButtonModel buttonModel2;
  // Model for TextField.
  late TextFieldModel textFieldModel2;
  // Model for ItemRow.
  late ItemRowModel itemRowModel1;
  // Model for ItemRow.
  late ItemRowModel itemRowModel2;
  // Model for Button.
  late ButtonModel buttonModel3;
  // Model for Button.
  late ButtonModel buttonModel4;

  @override
  void initState(BuildContext context) {
    buttonModel1 = createModel(context, () => ButtonModel());
    stepIndicatorModel1 = createModel(context, () => StepIndicatorModel());
    stepIndicatorModel2 = createModel(context, () => StepIndicatorModel());
    stepIndicatorModel3 = createModel(context, () => StepIndicatorModel());
    textFieldModel1 = createModel(context, () => TextFieldModel());
    buttonModel2 = createModel(context, () => ButtonModel());
    textFieldModel2 = createModel(context, () => TextFieldModel());
    itemRowModel1 = createModel(context, () => ItemRowModel());
    itemRowModel2 = createModel(context, () => ItemRowModel());
    buttonModel3 = createModel(context, () => ButtonModel());
    buttonModel4 = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    buttonModel1.dispose();
    stepIndicatorModel1.dispose();
    stepIndicatorModel2.dispose();
    stepIndicatorModel3.dispose();
    textFieldModel1.dispose();
    buttonModel2.dispose();
    textFieldModel2.dispose();
    itemRowModel1.dispose();
    itemRowModel2.dispose();
    buttonModel3.dispose();
    buttonModel4.dispose();
  }
}
