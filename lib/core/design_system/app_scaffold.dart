import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/components/side_nav/side_nav_widget.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/side_nav_provider.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/app_bar_provider.dart';
import 'package:deshmukh_steel_e_r_p/core/services/connectivity_service.dart';
import 'package:deshmukh_steel_e_r_p/core/services/sync_service.dart';

class AppScaffold extends ConsumerWidget {
  final String title;
  final Widget body;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final isLargeScreen = MediaQuery.sizeOf(context).width >= 1024.0;
    final isExpanded = ref.watch(sideNavNotifierProvider);
    final appBarState = ref.watch(appBarNotifierProvider);
    final connectivityAsync = ref.watch(connectivityNotifierProvider);
    final isSyncing = ref.watch(syncServiceProvider);

    final isOffline = connectivityAsync.maybeWhen(
      data: (status) => status == ConnectivityStatus.offline,
      orElse: () => false,
    );

    final tokens = context.tokens;

    if (!isLargeScreen) {
      return Scaffold(
        appBar: AppBar(
          title: Text(appBarState.title),
          actions: appBarState.actions,
        ),
        drawer: const SideNavWidget(),
        body: Column(
          children: [
            if (isOffline || isSyncing) _buildOfflineBanner(theme, isSyncing, tokens),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          const SideNavWidget(isPermanent: true),
          Expanded(
            child: Column(
              children: [
                if (isOffline || isSyncing) _buildOfflineBanner(theme, isSyncing, tokens),
                _buildHeader(context, ref, isExpanded, appBarState),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner(ThemeData theme, bool isSyncing, DesignTokens tokens) {
    return Container(
      height: 32,
      width: double.infinity,
      color: isSyncing ? tokens.info : theme.colorScheme.error,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isSyncing ? Icons.sync_rounded : Icons.wifi_off_rounded, color: Colors.white, size: 14),
          const SizedBox(width: 8),
          Text(
            isSyncing ? 'SYNCING DATA...' : 'OFFLINE MODE ACTIVE',
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, bool isExpanded, AppBarState appBarState) {
    final theme = context.theme;
    final tokens = context.tokens;
    
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
        boxShadow: [tokens.shadowXs],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          IconButton(
            icon: Icon(isExpanded ? Icons.menu_open_rounded : Icons.menu_rounded, color: theme.colorScheme.primary),
            onPressed: () => ref.read(sideNavNotifierProvider.notifier).toggle(),
            tooltip: 'Toggle Side Navigation',
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appBarState.title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                'Deshmukh Hardware ERP',
                style: context.textTheme.bodySmall?.copyWith(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Spacer(),
          if (appBarState.actions != null) ...appBarState.actions!,
          const SizedBox(width: 16),
          _buildHeaderAction(context, Icons.notifications_none_rounded, () {}),
          const SizedBox(width: 12),
          _buildHeaderAction(context, Icons.settings_outlined, () {}),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(Icons.person_outline_rounded, color: theme.colorScheme.primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(BuildContext context, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: context.colorScheme.secondary),
        onPressed: onTap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
