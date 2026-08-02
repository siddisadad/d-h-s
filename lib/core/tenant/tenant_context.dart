class TenantContext {
  final String tenantId;
  final String companyName;

  TenantContext({
    required this.tenantId,
    required this.companyName,
  });

  static TenantContext? _current;

  static void setTenant(TenantContext context) {
    _current = context;
  }

  static TenantContext get current {
    if (_current == null) {
      // Default tenant for development or single-tenant mode
      return TenantContext(
        tenantId: 'default-tenant',
        companyName: 'DHS ERP',
      );
    }
    return _current!;
  }
}
