import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_card.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_text_field.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/empty_state_widget.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_button.dart';
import 'package:deshmukh_steel_e_r_p/features/crm/presentation/providers/crm_search_provider.dart';
import 'package:deshmukh_steel_e_r_p/features/crm/presentation/providers/crm_provider.dart';
import 'package:deshmukh_steel_e_r_p/features/crm/domain/entities/contact.dart';
import 'package:deshmukh_steel_e_r_p/core/security/permissions.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/permission_wrapper.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/app_bar_provider.dart';
import 'package:intl/intl.dart';

class CustomerDirectoryScreen extends ConsumerStatefulWidget {
  const CustomerDirectoryScreen({super.key});

  @override
  ConsumerState<CustomerDirectoryScreen> createState() => _CustomerDirectoryScreenState();
}

class _CustomerDirectoryScreenState extends ConsumerState<CustomerDirectoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(filteredCustomersProvider);
    final tokens = context.tokens;

    // Update Global AppBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarNotifierProvider.notifier).update(
        title: 'CUSTOMER DIRECTORY',
        actions: [
          PermissionWrapper(
            requiredPermissions: const [AppPermission.manageContacts],
            child: CustomButton(
              text: 'Add Customer',
              variant: CustomButtonVariant.primary,
              icon: Icons.person_add_alt_1_rounded,
              onPressed: () => _showAddCustomerDialog(context),
            ),
          ),
        ],
      );
    });
// ...

    return Column(
      children: [
        _buildSearchHeader(context),
        Expanded(
          child: customersAsync.when(
            data: (list) => list.isEmpty 
              ? _buildEmptyState()
              : ListView.separated(
                  padding: EdgeInsets.all(tokens.space24),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => _buildCustomerCard(context, list[index]),
                ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      color: context.colorScheme.surface,
      padding: EdgeInsets.all(tokens.space24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Search Customers',
                  hint: 'Search by Name, GSTIN, or Phone...',
                  controller: _searchController,
                  prefixIcon: Icons.search_rounded,
                  onChanged: (val) => ref.read(customerSearchProvider.notifier).set(val),
                ),
              ),
              const SizedBox(width: 16),
              _filterButton(context),
            ],
          ),
          const SizedBox(height: 16),
          _buildQuickStats(context),
        ],
      ),
    );
  }

  Widget _filterButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 28),
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colorScheme.outlineVariant),
      ),
      child: PopupMenuButton<String>(
        icon: Icon(Icons.tune_rounded, color: context.primaryColor),
        onSelected: (val) => ref.read(customerLocationFilterProvider.notifier).set(val),
        itemBuilder: (context) {
          final locations = ref.watch(customerLocationsProvider).value ?? ['All Locations'];
          return locations.map((loc) => PopupMenuItem(value: loc, child: Text(loc))).toList();
        },
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        _quickStatChip(context, 'Receivable', '₹24.8L', context.errorColor),
        const SizedBox(width: 12),
        _quickStatChip(context, 'Active', '152', context.successColor),
      ],
    );
  }

  Widget _quickStatChip(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(label, style: context.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text(value, style: context.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, Contact customer) {
    return CustomCard(
      onTap: () => context.push('/customers/${customer.id}'),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: context.primaryColor.withValues(alpha: 0.1),
                child: Text(
                  customer.initials,
                  style: TextStyle(color: context.primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    Text('${customer.location} • GSTIN: ${customer.gstin}', style: context.textTheme.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(customer.balance),
                    style: TextStyle(fontWeight: FontWeight.w700, color: context.errorColor),
                  ),
                  Text('Balance', style: context.textTheme.labelSmall?.copyWith(fontSize: 9)),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _actionButton(Icons.chat_outlined, context.successColor, () => _launchWhatsApp(customer.contact)),
                  const SizedBox(width: 8),
                  _actionButton(Icons.call_outlined, context.primaryColor, () => _launchCall(customer.contact)),
                ],
              ),
              TextButton.icon(
                onPressed: () => context.push('/customers/${customer.id}'),
                icon: const Icon(Icons.receipt_long_rounded, size: 16),
                label: const Text('View Ledger'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.people_outline_rounded,
      title: 'No Customers Found',
      message: 'Try adjusting your search or filters.',
      actionLabel: 'Clear Filters',
      onAction: () {
        _searchController.clear();
        ref.read(customerSearchProvider.notifier).set('');
        ref.read(customerLocationFilterProvider.notifier).set('All Locations');
      },
    );
  }

  void _launchWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final url = 'whatsapp://send?phone=$cleanPhone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _launchCall(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _showAddCustomerDialog(BuildContext context) {
    context.push('/customers/new');
  }
}
