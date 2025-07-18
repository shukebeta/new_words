import 'package:flutter/material.dart';

import '../../../generated/app_localizations.dart';

class AppRailNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const AppRailNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.list_alt_outlined),
          selectedIcon: const Icon(Icons.list_alt_outlined, color: Colors.blue),
          label: Text(localizations.newWordsTab),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.memory_outlined),
          selectedIcon: const Icon(Icons.memory_outlined, color: Colors.blue),
          label: Text(localizations.memoriesTab),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.auto_stories_outlined),
          selectedIcon: const Icon(
            Icons.auto_stories_outlined,
            color: Colors.blue,
          ),
          label: Text(localizations.storiesTab),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings_outlined, color: Colors.blue),
          label: Text(localizations.settingsTab),
        ),
      ],
    );
  }
}
