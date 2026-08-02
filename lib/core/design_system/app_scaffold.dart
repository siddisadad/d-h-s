import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import '../../components/side_nav/side_nav_widget.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final bool showDrawer;

  const AppScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.drawer,
    this.showDrawer = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isLargeScreen = MediaQuery.sizeOf(context).width >= 991.0;
    
    // On large screens, the side nav is usually permanent (via ShellRoute)
    // so we hide the drawer and the hamburger menu icon.
    final effectiveShowDrawer = showDrawer && !isLargeScreen;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        automaticallyImplyLeading: effectiveShowDrawer,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            if (subtitle != null)
              Text(subtitle!, style: context.textTheme.labelSmall),
          ],
        ),
        actions: actions,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      drawer: effectiveShowDrawer ? (drawer ?? const SideNavWidget()) : null,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
