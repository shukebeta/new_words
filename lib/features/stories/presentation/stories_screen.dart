import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_words/entities/story.dart';
import 'package:new_words/providers/stories_provider.dart';
import 'package:new_words/features/stories/presentation/widgets/story_list.dart';
import 'package:new_words/features/stories/presentation/widgets/generate_stories_dialog.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({Key? key}) : super(key: key);

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<StoriesProvider>(context, listen: false);
      provider.fetchMyStories();
    });
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
          provider.fetchMyStories();
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
        title: const Text('Stories'),
        bottom: TabBar(
          controller: _tabController,
          onTap: _onTabChanged,
          tabs: const [
            Tab(text: 'My Stories', icon: Icon(Icons.book)),
            Tab(text: 'Discover', icon: Icon(Icons.explore)),
            Tab(text: 'Favorites', icon: Icon(Icons.favorite)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showGenerateDialog,
            tooltip: 'Generate Stories',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Stories Tab
          StoryList(
            key: const PageStorageKey('my_stories'),
            stories: context.select<StoriesProvider, List<Story>>((provider) => provider.myStories),
            isLoading: context.select<StoriesProvider, bool>((provider) => provider.isLoadingMyStories),
            error: context.select<StoriesProvider, String?>((provider) => provider.myStoriesError),
            canLoadMore: context.select<StoriesProvider, bool>((provider) => provider.canLoadMoreMyStories),
            onRefresh: () => Provider.of<StoriesProvider>(context, listen: false).refreshMyStories(),
            onLoadMore: () => Provider.of<StoriesProvider>(context, listen: false).fetchMyStories(loadMore: true),
            onClearError: () => Provider.of<StoriesProvider>(context, listen: false).clearMyStoriesError(),
            emptyMessage: 'No stories yet. Tap + to generate your first story!',
          ),
          // Story Square Tab
          StoryList(
            key: const PageStorageKey('story_square'),
            stories: context.select<StoriesProvider, List<Story>>((provider) => provider.storySquare),
            isLoading: context.select<StoriesProvider, bool>((provider) => provider.isLoadingStorySquare),
            error: context.select<StoriesProvider, String?>((provider) => provider.storySquareError),
            canLoadMore: context.select<StoriesProvider, bool>((provider) => provider.canLoadMoreStorySquare),
            onRefresh: () => Provider.of<StoriesProvider>(context, listen: false).refreshStorySquare(),
            onLoadMore: () => Provider.of<StoriesProvider>(context, listen: false).fetchStorySquare(loadMore: true),
            onClearError: () => Provider.of<StoriesProvider>(context, listen: false).clearStorySquareError(),
            emptyMessage: 'No stories to discover yet.',
          ),
          // Favorites Tab
          StoryList(
            key: const PageStorageKey('favorite_stories'),
            stories: context.select<StoriesProvider, List<Story>>((provider) => provider.favoriteStories),
            isLoading: context.select<StoriesProvider, bool>((provider) => provider.isLoadingFavorites),
            error: context.select<StoriesProvider, String?>((provider) => provider.favoritesError),
            canLoadMore: context.select<StoriesProvider, bool>((provider) => provider.canLoadMoreFavorites),
            onRefresh: () => Provider.of<StoriesProvider>(context, listen: false).refreshFavoriteStories(),
            onLoadMore: () => Provider.of<StoriesProvider>(context, listen: false).fetchFavoriteStories(loadMore: true),
            onClearError: () => Provider.of<StoriesProvider>(context, listen: false).clearFavoritesError(),
            emptyMessage: 'No favorite stories yet. Tap the heart icon to save stories!',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showGenerateDialog,
        tooltip: 'Generate Stories',
        heroTag: 'stories_generate_fab', // Unique hero tag to avoid conflicts
        child: const Icon(Icons.auto_awesome),
      ),
    );
  }
}