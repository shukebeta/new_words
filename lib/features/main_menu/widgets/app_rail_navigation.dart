import 'package:flutter/material.dart';

class AppRailNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const AppRailNavigation({
    Key? key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.list_alt_outlined),
          selectedIcon: Icon(Icons.list_alt_outlined, color: Colors.blue),
          label: Text('New Words'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.memory_outlined),
          selectedIcon: Icon(Icons.memory_outlined, color: Colors.blue),
          label: Text('Memories'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.auto_stories_outlined),
          selectedIcon: Icon(Icons.auto_stories_outlined, color: Colors.blue),
          label: Text('Stories'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_outlined, color: Colors.blue),
          label: Text('Settings'),
        ),
      ],
    );
  }
}