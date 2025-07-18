import 'package:flutter/material.dart';

import '../../../generated/app_localizations.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(
        context,
      ).colorScheme.onSurface.withValues(alpha: 0.6),
      backgroundColor: Theme.of(context).colorScheme.surface,
      type: BottomNavigationBarType.fixed, // Ensures labels are always visible
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.list_alt_outlined),
          label: localizations.newWordsTab,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.memory_outlined),
          label: localizations.memoriesTab,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.auto_stories_outlined),
          label: localizations.storiesTab,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          label: localizations.settingsTab,
        ),
      ],
    );
  }
}
