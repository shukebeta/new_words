import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_words/entities/story.dart';
import 'package:new_words/providers/stories_provider.dart';
import 'package:new_words/features/stories/presentation/widgets/story_list.dart';
import 'package:new_words/features/stories/presentation/widgets/generate_stories_dialog.dart';
import 'package:new_words/generated/app_localizations.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasAutoSwitched = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialDataAndCheckAutoSwitch();
    });
  }

  Future<void> _loadInitialDataAndCheckAutoSwitch() async {
    final provider = Provider.of<StoriesProvider>(context, listen: false);
    await provider.fetchMyStories();
    _checkAndAutoSwitchToDiscover();
  }

  void _checkAndAutoSwitchToDiscover() {
    if (_hasAutoSwitched) return; // Only auto-switch once

    final provider = Provider.of<StoriesProvider>(context, listen: false);

    // If My Stories is empty and we're on the My Stories tab, switch to Discover
    if (provider.myStories.isEmpty &&
        !provider.isLoadingMyStories &&
        _tabController.index == 0) {
      _hasAutoSwitched = true;

      // Preload Story Square data if not already loaded
      if (provider.storySquare.isEmpty && !provider.isLoadingStorySquare) {
        provider.fetchStorySquare();
      }

      // Switch to Discover tab
      _tabController.animateTo(1);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    final provider = Provider.of<StoriesProvider>(context, listen: false);

    switch (index) {
      case 0: // My Stories
        if (provider.myStories.isEmpty && !provider.isLoadingMyStories) {
          provider.fetchMyStories().then((_) {
            // Check for auto-switch after manual refresh
            if (!_hasAutoSwitched) {
              _checkAndAutoSwitchToDiscover();
            }
          });
        }
        break;
      case 1: // Story Square
        if (provider.storySquare.isEmpty && !provider.isLoadingStorySquare) {
          provider.fetchStorySquare();
        }
        break;
      case 2: // Favorites
        if (provider.favoriteStories.isEmpty && !provider.isLoadingFavorites) {
          provider.fetchFavoriteStories();
        }
        break;
    }
  }

  void _showGenerateDialog() async {
    final result = await showDialog<List<Story>>(
      context: context,
      builder: (context) => const GenerateStoriesDialog(),
    );

    // If stories were generated and we're not on "My Stories" tab, switch to it
    if (result != null && result.isNotEmpty && _tabController.index != 0) {
      _tabController.animateTo(0); // Switch to "My Stories" tab
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.storiesTitle),
        bottom: TabBar(
          controller: _tabController,
          onTap: _onTabChanged,
          tabs: [
            Tab(
              text: AppLocalizations.of(context)!.myStoriesTab,
              icon: const Icon(Icons.book),
            ),
            Tab(
              text: AppLocalizations.of(context)!.discoverTab,
              icon: const Icon(Icons.explore),
            ),
            Tab(
              text: AppLocalizations.of(context)!.favoritesTab,
              icon: const Icon(Icons.favorite),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showGenerateDialog,
            tooltip: AppLocalizations.of(context)!.generateStoriesTooltip,
          ),
        ],
      ),
      body: Consumer<StoriesProvider>(
        builder:
            (context, provider, child) => TabBarView(
              controller: _tabController,
              children: [
                // My Stories Tab
                StoryList(
                  key: const PageStorageKey('my_stories'),
                  stories: provider.myStories,
                  isLoading: provider.isLoadingMyStories,
                  error: provider.myStoriesError,
                  canLoadMore: provider.canLoadMoreMyStories,
                  onRefresh:
                      () =>
                          Provider.of<StoriesProvider>(
                            context,
                            listen: false,
                          ).refreshMyStories(),
                  onLoadMore:
                      () => Provider.of<StoriesProvider>(
                        context,
                        listen: false,
                      ).fetchMyStories(loadMore: true),
                  onClearError:
                      () =>
                          Provider.of<StoriesProvider>(
                            context,
                            listen: false,
                          ).clearMyStoriesError(),
                  emptyMessage: AppLocalizations.of(context)!.noStoriesYet,
                ),
                // Story Square Tab
                StoryList(
                  key: const PageStorageKey('story_square'),
                  stories: provider.storySquare,
                  isLoading: provider.isLoadingStorySquare,
                  error: provider.storySquareError,
                  canLoadMore: provider.canLoadMoreStorySquare,
                  onRefresh:
                      () =>
                          Provider.of<StoriesProvider>(
                            context,
                            listen: false,
                          ).refreshStorySquare(),
                  onLoadMore:
                      () => Provider.of<StoriesProvider>(
                        context,
                        listen: false,
                      ).fetchStorySquare(loadMore: true),
                  onClearError:
                      () =>
                          Provider.of<StoriesProvider>(
                            context,
                            listen: false,
                          ).clearStorySquareError(),
                  emptyMessage: AppLocalizations.of(context)!.noDiscoverStories,
                ),
                // Favorites Tab
                StoryList(
                  key: const PageStorageKey('favorite_stories'),
                  stories: provider.favoriteStories,
                  isLoading: provider.isLoadingFavorites,
                  error: provider.favoritesError,
                  canLoadMore: provider.canLoadMoreFavorites,
                  onRefresh:
                      () =>
                          Provider.of<StoriesProvider>(
                            context,
                            listen: false,
                          ).refreshFavoriteStories(),
                  onLoadMore:
                      () => Provider.of<StoriesProvider>(
                        context,
                        listen: false,
                      ).fetchFavoriteStories(loadMore: true),
                  onClearError:
                      () =>
                          Provider.of<StoriesProvider>(
                            context,
                            listen: false,
                          ).clearFavoritesError(),
                  emptyMessage: AppLocalizations.of(context)!.noFavoriteStories,
                ),
              ],
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showGenerateDialog,
        tooltip: AppLocalizations.of(context)!.generateStoriesTooltip,
        heroTag: 'stories_generate_fab', // Unique hero tag to avoid conflicts
        child: const Icon(Icons.auto_awesome),
      ),
    );
  }
}
