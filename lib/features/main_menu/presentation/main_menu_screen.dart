import 'package:flutter/material.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';
import 'package:new_words/features/main_menu/utils/navigation_constants.dart';
import 'package:new_words/features/main_menu/widgets/app_bottom_navigation.dart';
import 'package:new_words/features/main_menu/widgets/app_rail_navigation.dart';
import 'package:new_words/features/new_words_list/presentation/new_words_list_screen.dart';
import 'package:new_words/features/memories/presentation/memories_screen.dart';
import 'package:new_words/features/stories/presentation/stories_screen.dart';
import 'package:new_words/features/settings/presentation/settings_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  static const routeName = '/main-menu'; // Added routeName

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _selectedIndex = indexNewWords;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildPageContent(int index) {
    return LazyLoadIndexedStack(
      index: index,
      children: [
        NewWordsListScreen(),
        MemoriesScreen(),
        StoriesScreen(),
        SettingsScreen(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            AppRailNavigation(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
            ),
          Expanded(
            child: _buildPageContent(_selectedIndex),
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop
          ? AppBottomNavigation(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            )
          : null,
    );
  }
}