import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/inventory/presentation/providers/inventory_provider.dart';
import '../../features/crm/presentation/providers/crm_provider.dart';
import '../../features/crm/domain/entities/contact.dart';
import '../../features/sales/presentation/providers/sales_history_provider.dart';

part 'global_search_provider.g.dart';

enum SearchCategory { product, customer, supplier, invoice }

class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final SearchCategory category;
  final String path;

  SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.path,
  });
}

@riverpod
class GlobalSearch extends _$GlobalSearch {
  @override
  AsyncValue<List<SearchResult>> build() {
    return const AsyncData([]);
  }

  Future<void> search(String query) async {
    if (query.length < 2) {
      state = const AsyncData([]);
      return;
    }

    state = const AsyncLoading();
    
    final results = <SearchResult>[];
    final keyword = query.toLowerCase();

    // Search within current in-memory inventory
    final products = ref.read(inventoryNotifierProvider).value ?? [];
    for (final p in products) {
      if (p.name.toLowerCase().contains(keyword) || p.sku.toLowerCase().contains(keyword)) {
        results.add(SearchResult(
          id: p.sku,
          title: p.name,
          subtitle: 'Stock: ${p.stock} ${p.unit}',
          category: SearchCategory.product,
          path: '/inventory',
        ));
      }
    }

    // Search within current in-memory customers
    final customers = ref.read(crmNotifierProvider(ContactType.customer)).value ?? [];
    for (final c in customers) {
      if (c.name.toLowerCase().contains(keyword)) {
        results.add(SearchResult(
          id: c.id,
          title: c.name,
          subtitle: c.location,
          category: SearchCategory.customer,
          path: '/customers',
        ));
      }
    }

    // Search within current in-memory suppliers
    final suppliers = ref.read(crmNotifierProvider(ContactType.supplier)).value ?? [];
    for (final s in suppliers) {
      if (s.name.toLowerCase().contains(keyword)) {
        results.add(SearchResult(
          id: s.id,
          title: s.name,
          subtitle: s.location,
          category: SearchCategory.supplier,
          path: '/suppliers',
        ));
      }
    }

    // Search within current in-memory invoices
    final invoices = ref.read(salesHistoryProvider).value ?? [];
    for (final inv in invoices) {
      if (inv.id.toLowerCase().contains(keyword) || inv.customerName.toLowerCase().contains(keyword)) {
        results.add(SearchResult(
          id: inv.id,
          title: inv.id,
          subtitle: '${inv.customerName} - ₹${inv.grandTotal.toStringAsFixed(0)}',
          category: SearchCategory.invoice,
          path: '/sales',
        ));
      }
    }

    state = AsyncData(results);
  }
}
