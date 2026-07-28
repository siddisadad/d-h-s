import '/components/button/button_widget.dart';
import '/components/inventory_stat_card/inventory_stat_card_widget.dart';
import '/components/product_list_item/product_list_item_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'product_inventory_widget.dart' show ProductInventoryWidget;
import 'package:flutter/material.dart';

class ProductInventoryModel extends FlutterFlowModel<ProductInventoryWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for TextField.
  late TextFieldModel textFieldModel;
  // Model for InventoryStatCard.
  late InventoryStatCardModel inventoryStatCardModel1;
  // Model for InventoryStatCard.
  late InventoryStatCardModel inventoryStatCardModel2;
  // Model for InventoryStatCard.
  late InventoryStatCardModel inventoryStatCardModel3;
  // Model for ProductListItem.
  late ProductListItemModel productListItemModel1;
  // Model for ProductListItem.
  late ProductListItemModel productListItemModel2;
  // Model for ProductListItem.
  late ProductListItemModel productListItemModel3;
  // Model for ProductListItem.
  late ProductListItemModel productListItemModel4;
  // Model for ProductListItem.
  late ProductListItemModel productListItemModel5;
  // Model for ProductListItem.
  late ProductListItemModel productListItemModel6;
  // Model for ProductListItem.
  late ProductListItemModel productListItemModel7;
  // Model for Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    textFieldModel = createModel(context, () => TextFieldModel());
    inventoryStatCardModel1 =
        createModel(context, () => InventoryStatCardModel());
    inventoryStatCardModel2 =
        createModel(context, () => InventoryStatCardModel());
    inventoryStatCardModel3 =
        createModel(context, () => InventoryStatCardModel());
    productListItemModel1 = createModel(context, () => ProductListItemModel());
    productListItemModel2 = createModel(context, () => ProductListItemModel());
    productListItemModel3 = createModel(context, () => ProductListItemModel());
    productListItemModel4 = createModel(context, () => ProductListItemModel());
    productListItemModel5 = createModel(context, () => ProductListItemModel());
    productListItemModel6 = createModel(context, () => ProductListItemModel());
    productListItemModel7 = createModel(context, () => ProductListItemModel());
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    textFieldModel.dispose();
    inventoryStatCardModel1.dispose();
    inventoryStatCardModel2.dispose();
    inventoryStatCardModel3.dispose();
    productListItemModel1.dispose();
    productListItemModel2.dispose();
    productListItemModel3.dispose();
    productListItemModel4.dispose();
    productListItemModel5.dispose();
    productListItemModel6.dispose();
    productListItemModel7.dispose();
    buttonModel.dispose();
  }
}
