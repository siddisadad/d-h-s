enum AppPermission {
  // Inventory
  viewInventory,
  manageInventory, // Add/Edit/Delete
  adjustStock,
  viewPrices,
  editPrices,

  // Sales
  viewSales,
  createInvoice,
  deleteInvoice,
  applyDiscount,

  // CRM
  viewContacts,
  manageContacts,
  viewLedgers,

  // Purchases
  viewPurchases,
  managePurchases,

  // Finance
  viewFinance,
  manageTransactions,

  // Employees
  viewEmployees,
  manageEmployees,
  viewSalaries,

  // System
  viewAnalytics,
  manageSettings,
  exportData,
}

class RolePermissions {
  static const Map<String, Set<AppPermission>> roleMapping = {
    'Admin': {
      AppPermission.viewInventory,
      AppPermission.manageInventory,
      AppPermission.adjustStock,
      AppPermission.viewPrices,
      AppPermission.editPrices,
      AppPermission.viewSales,
      AppPermission.createInvoice,
      AppPermission.deleteInvoice,
      AppPermission.applyDiscount,
      AppPermission.viewContacts,
      AppPermission.manageContacts,
      AppPermission.viewLedgers,
      AppPermission.viewPurchases,
      AppPermission.managePurchases,
      AppPermission.viewFinance,
      AppPermission.manageTransactions,
      AppPermission.viewEmployees,
      AppPermission.manageEmployees,
      AppPermission.viewSalaries,
      AppPermission.viewAnalytics,
      AppPermission.manageSettings,
      AppPermission.exportData,
    },
    'Manager': {
      AppPermission.viewInventory,
      AppPermission.manageInventory,
      AppPermission.adjustStock,
      AppPermission.viewPrices,
      AppPermission.viewSales,
      AppPermission.createInvoice,
      AppPermission.applyDiscount,
      AppPermission.viewContacts,
      AppPermission.manageContacts,
      AppPermission.viewLedgers,
      AppPermission.viewPurchases,
      AppPermission.viewFinance,
      AppPermission.viewEmployees,
      AppPermission.viewAnalytics,
    },
    'Employee': {
      AppPermission.viewInventory,
      AppPermission.viewPrices,
      AppPermission.viewSales,
      AppPermission.createInvoice,
      AppPermission.viewContacts,
      AppPermission.viewPurchases,
    },
  };

  static bool hasPermission(String role, AppPermission permission) {
    return roleMapping[role]?.contains(permission) ?? false;
  }
}
