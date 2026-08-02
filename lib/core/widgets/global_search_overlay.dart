import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../design_system/theme/app_theme.dart';
import '../providers/global_search_provider.dart';
import 'custom_text_field.dart';

class GlobalSearchOverlay extends ConsumerStatefulWidget {
  const GlobalSearchOverlay({super.key});

  @override
  ConsumerState<GlobalSearchOverlay> createState() => _GlobalSearchOverlayState();
}

class _GlobalSearchOverlayState extends ConsumerState<GlobalSearchOverlay> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(globalSearchProvider);
    final tokens = context.tokens;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          Padding(
            padding: EdgeInsets.all(tokens.space24),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Global Search',
                    hint: 'Type product, customer, or invoice...',
                    controller: _controller,
                    prefixIcon: Icons.search_rounded,
                    onChanged: (val) => ref.read(globalSearchProvider.notifier).search(val),
                  ),
                ),
                SizedBox(width: tokens.space16),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: resultsAsync.when(
              data: (results) => results.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: tokens.space24),
                      itemCount: results.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) => _buildResultTile(context, results[index]),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Search Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_controller.text.isEmpty) {
      return const Center(child: Text('Start typing to find anything...'));
    }
    return const Center(child: Text('No matching records found.'));
  }

  Widget _buildResultTile(BuildContext context, SearchResult result) {
    return ListTile(
      leading: _getIcon(result.category),
      title: Text(result.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(result.subtitle),
      trailing: _getCategoryTag(result.category),
      onTap: () {
        Navigator.pop(context);
        context.go(result.path);
      },
    );
  }

  Widget _getIcon(SearchCategory category) {
    IconData icon;
    Color color;
    switch (category) {
      case SearchCategory.product: icon = Icons.inventory_2_outlined; color = AppColors.primary; break;
      case SearchCategory.customer: icon = Icons.person_outline_rounded; color = AppColors.accent; break;
      case SearchCategory.supplier: icon = Icons.business_rounded; color = AppColors.secondary; break;
      case SearchCategory.invoice: icon = Icons.receipt_long_rounded; color = AppColors.info; break;
    }
    return Icon(icon, color: color);
  }

  Widget _getCategoryTag(SearchCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.border.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
      child: Text(category.name.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
