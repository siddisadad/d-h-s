import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/contact.dart';
import 'crm_provider.dart';

part 'crm_search_provider.g.dart';

@riverpod
class CustomerSearch extends _$CustomerSearch {
  @override
  String build() => '';

  void set(String query) => state = query;
}

@riverpod
class CustomerLocationFilter extends _$CustomerLocationFilter {
  @override
  String build() => 'All Locations';

  void set(String location) => state = location;
}

@riverpod
Future<List<Contact>> filteredCustomers(FilteredCustomersRef ref) async {
  final customersAsync = ref.watch(crmNotifierProvider(ContactType.customer));
  final query = ref.watch(customerSearchProvider).toLowerCase();
  final location = ref.watch(customerLocationFilterProvider);

  return customersAsync.when(
    data: (list) {
      return list.where((c) {
        final matchesQuery = c.name.toLowerCase().contains(query) || 
                            c.gstin.toLowerCase().contains(query) ||
                            c.contact.contains(query);
        final matchesLocation = location == 'All Locations' || c.location == location;
        return matchesQuery && matchesLocation;
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

@riverpod
Future<List<String>> customerLocations(CustomerLocationsRef ref) async {
  final customersAsync = ref.watch(crmNotifierProvider(ContactType.customer));
  return customersAsync.when(
    data: (list) => ['All Locations', ...list.map((c) => c.location).toSet()],
    loading: () => ['All Locations'],
    error: (_, __) => ['All Locations'],
  );
}
