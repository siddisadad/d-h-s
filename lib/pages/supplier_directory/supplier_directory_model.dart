import '/components/supplier_list_item/supplier_list_item_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'supplier_directory_widget.dart' show SupplierDirectoryWidget;
import 'package:flutter/material.dart';

class SupplierDirectoryModel extends FlutterFlowModel<SupplierDirectoryWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for TextField.
  late TextFieldModel textFieldModel;
  // Model for SupplierListItem.
  late SupplierListItemModel supplierListItemModel1;
  // Model for SupplierListItem.
  late SupplierListItemModel supplierListItemModel2;
  // Model for SupplierListItem.
  late SupplierListItemModel supplierListItemModel3;
  // Model for SupplierListItem.
  late SupplierListItemModel supplierListItemModel4;
  // Model for SupplierListItem.
  late SupplierListItemModel supplierListItemModel5;

  @override
  void initState(BuildContext context) {
    textFieldModel = createModel(context, () => TextFieldModel());
    supplierListItemModel1 =
        createModel(context, () => SupplierListItemModel());
    supplierListItemModel2 =
        createModel(context, () => SupplierListItemModel());
    supplierListItemModel3 =
        createModel(context, () => SupplierListItemModel());
    supplierListItemModel4 =
        createModel(context, () => SupplierListItemModel());
    supplierListItemModel5 =
        createModel(context, () => SupplierListItemModel());
  }

  @override
  void dispose() {
    textFieldModel.dispose();
    supplierListItemModel1.dispose();
    supplierListItemModel2.dispose();
    supplierListItemModel3.dispose();
    supplierListItemModel4.dispose();
    supplierListItemModel5.dispose();
  }
}
