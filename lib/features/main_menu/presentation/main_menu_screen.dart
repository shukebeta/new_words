import 'package:flutter/material.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';
import 'package:new_words/features/main_menu/utils/navigation_constants.dart';
import 'package:new_words/features/main_menu/widgets/app_bottom_navigation.dart';
import 'package:new_words/features/main_menu/widgets/app_rail_navigation.dart';
import 'package:new_words/features/new_words_list/presentation/new_words_list_screen.dart';
import 'package:new_words/features/memories/presentation/memories_screen.dart';
import 'package:new_words/features/stories/presentation/stories_screen.dart';
import 'package:new_words/features/settings/presentation/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_words/common/constants/constants.dart';
import 'package:new_words/features/add_word/widgets/add_word_fab.dart';
import 'package:new_words/features/add_word/presentation/add_word_dialog.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  static const routeName = '/main-menu'; // Added routeName

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _selectedIndex = indexNewWords;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowAddWordDialog(context);
    });
  }

  Future<void> _maybeShowAddWordDialog(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastShown = prefs.getInt(StorageKeys.lastAddWordShownTime) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (lastShown == 0 || (now - lastShown) > 3600000) {
        if (mounted && context.mounted) {
          AddWordDialog.show(context);
        }
        await prefs.setInt(StorageKeys.lastAddWordShownTime, now);
      }
    } catch (e) {
      debugPrint('Error showing add word dialog: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildPageContent(int index) {
    return LazyLoadIndexedStack(
      index: index,
      preloadIndexes: const [indexNewWords], // Only preload first page
      children: [
        const NewWordsListScreen(),
        const MemoriesScreen(),
        const StoriesScreen(),
        const SettingsScreen(),
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
          Expanded(child: _buildPageContent(_selectedIndex)),
        ],
      ),
      floatingActionButton: const AddWordFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: !isDesktop
          ? AppBottomNavigation(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            )
          : SizedBox(
              height: kBottomNavigationBarHeight,
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                elevation: 3,
              ),
            ),
    );
  }
}
