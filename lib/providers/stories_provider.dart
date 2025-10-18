import 'package:flutter/foundation.dart';
import 'package:new_words/app_config.dart';
import 'package:new_words/entities/story.dart';
import 'package:new_words/common/foundation/service_exceptions.dart';
import 'package:new_words/services/stories_service_v2.dart';
import 'package:new_words/providers/provider_base.dart';

class StoriesProvider extends AuthAwareProvider {
  final StoriesServiceV2 _storiesService;

  StoriesProvider(this._storiesService);

  // My Stories state
  List<Story> _myStories = [];
  List<Story> get myStories => _myStories;
  bool _isLoadingMyStories = false;
  bool get isLoadingMyStories => _isLoadingMyStories;
  String? _myStoriesError;
  String? get myStoriesError => _myStoriesError;
  int _myStoriesCurrentPage = 1;
  int _myStoriesTotalCount = 0;
  final int _pageSize = AppConfig.pageSize;

  // Story Square state
  List<Story> _storySquare = [];
  List<Story> get storySquare => _storySquare;
  bool _isLoadingStorySquare = false;
  bool get isLoadingStorySquare => _isLoadingStorySquare;
  String? _storySquareError;
  String? get storySquareError => _storySquareError;
  int _storySquareCurrentPage = 1;
  int _storySquareTotalCount = 0;

  // Favorite Stories state
  List<Story> _favoriteStories = [];
  List<Story> get favoriteStories => _favoriteStories;
  bool _isLoadingFavorites = false;
  bool get isLoadingFavorites => _isLoadingFavorites;
  String? _favoritesError;
  String? get favoritesError => _favoritesError;
  int _favoritesCurrentPage = 1;
  int _favoritesTotalCount = 0;

  // Story Generation state
  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;
  String? _generateError;
  String? get generateError => _generateError;

  // Pagination helpers
  bool get canLoadMoreMyStories => _myStories.length < _myStoriesTotalCount;
  bool get canLoadMoreStorySquare =>
      _storySquare.length < _storySquareTotalCount;
  bool get canLoadMoreFavorites =>
      _favoriteStories.length < _favoritesTotalCount;

  // Fetch My Stories
  Future<void> fetchMyStories({bool loadMore = false}) async {
    if (_isLoadingMyStories) return;
    if (loadMore && !canLoadMoreMyStories) return;

    _isLoadingMyStories = true;
    _myStoriesError = null;
    if (!loadMore) {
      _myStoriesCurrentPage = 1;
      _myStories = [];
    }
    notifyListeners();

    try {
      final pageData = await _storiesService.getMyStories(
        _myStoriesCurrentPage,
        _pageSize,
      );
      if (loadMore) {
        _myStories.addAll(pageData.dataList);
      } else {
        _myStories = pageData.dataList;
      }
      _myStoriesTotalCount = pageData.totalCount;
      if (pageData.dataList.isNotEmpty) {
        _myStoriesCurrentPage++;
      }
    } on ServiceException catch (e) {
      _myStoriesError = e.toString();
    } catch (e) {
      _myStoriesError = e.toString();
    } finally {
      _isLoadingMyStories = false;
      notifyListeners();
    }
  }

  // Fetch Story Square
  Future<void> fetchStorySquare({bool loadMore = false}) async {
    if (_isLoadingStorySquare) return;
    if (loadMore && !canLoadMoreStorySquare) return;

    _isLoadingStorySquare = true;
    _storySquareError = null;
    if (!loadMore) {
      _storySquareCurrentPage = 1;
      _storySquare = [];
    }
    notifyListeners();

    try {
      final pageData = await _storiesService.getStorySquare(
        _storySquareCurrentPage,
        _pageSize,
      );
      if (loadMore) {
        _storySquare.addAll(pageData.dataList);
      } else {
        _storySquare = pageData.dataList;
      }
      _storySquareTotalCount = pageData.totalCount;
      if (pageData.dataList.isNotEmpty) {
        _storySquareCurrentPage++;
      }
    } on ServiceException catch (e) {
      _storySquareError = e.toString();
    } catch (e) {
      _storySquareError = e.toString();
    } finally {
      _isLoadingStorySquare = false;
      notifyListeners();
    }
  }

  // Fetch Favorite Stories
  Future<void> fetchFavoriteStories({bool loadMore = false}) async {
    if (_isLoadingFavorites) return;
    if (loadMore && !canLoadMoreFavorites) return;

    _isLoadingFavorites = true;
    _favoritesError = null;
    if (!loadMore) {
      _favoritesCurrentPage = 1;
      _favoriteStories = [];
    }
    notifyListeners();

    try {
      final pageData = await _storiesService.getMyFavoriteStories(
        _favoritesCurrentPage,
        _pageSize,
      );
      if (loadMore) {
        _favoriteStories.addAll(pageData.dataList);
      } else {
        _favoriteStories = pageData.dataList;
      }
      _favoritesTotalCount = pageData.totalCount;
      if (pageData.dataList.isNotEmpty) {
        _favoritesCurrentPage++;
      }
    } on ServiceException catch (e) {
      _favoritesError = e.toString();
    } catch (e) {
      _favoritesError = e.toString();
    } finally {
      _isLoadingFavorites = false;
      notifyListeners();
    }
  }

  // Generate Stories
  Future<List<Story>?> generateStories({List<String>? customWords}) async {
    if (_isGenerating) return null;

    _isGenerating = true;
    _generateError = null;
    notifyListeners();

    try {
      final newStories = await _storiesService.generateStories(
        customWords: customWords,
      );

      // Add new stories to the beginning of My Stories list
      for (final story in newStories.reversed) {
        _myStories.insert(0, story);
        _myStoriesTotalCount++;
      }

      _isGenerating = false;
      notifyListeners();
      return newStories;
    } on ServiceException catch (e) {
      _generateError = e.toString();
    } catch (e) {
      _generateError = e.toString();
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
    return null;
  }

  // Regenerate stories with the same word list as an existing story
  Future<List<Story>?> regenerateStoriesFromExisting(
    Story existingStory,
  ) async {
    if (_isGenerating) return null;

    _isGenerating = true;
    _generateError = null;
    notifyListeners();

    try {
      final newStories = await _storiesService.generateStories(
        customWords: existingStory.vocabularyWords,
      );

      // Add new stories to the beginning of My Stories list
      for (final story in newStories.reversed) {
        _myStories.insert(0, story);
        _myStoriesTotalCount++;
      }

      _isGenerating = false;
      notifyListeners();
      return newStories;
    } on ServiceException catch (e) {
      _generateError = e.toString();
    } catch (e) {
      _generateError = e.toString();
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
    return null;
  }

  // Mark story as read if needed
  Future<void> markAsReadIfNeeded(Story story) async {
    if (story.firstReadAt != null) return; // Already read

    debugPrint('Marking story ${story.id} as read...');

    // Update local state immediately for better UX (optimistic update)
    final readTimestamp = DateTime.now().millisecondsSinceEpoch;
    final updatedStory = story.copyWith(firstReadAt: readTimestamp);

    // Update in all relevant lists first
    _updateStoryInLists(story.id, updatedStory);
    notifyListeners();

    // Then call service to mark as read on backend
    try {
      await _storiesService.markAsReadIfNeeded(story);
      debugPrint('Successfully marked story ${story.id} as read');
    } catch (e) {
      debugPrint('Failed to mark story as read: $e');
      // On error, revert the optimistic update
      _updateStoryInLists(story.id, story);
      notifyListeners();
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(Story story) async {
    try {
      await _storiesService.toggleFavorite(story.id);

      // Update local state
      final updatedStory = story.copyWith(
        isFavorited: !story.isFavorited,
        favoriteCount:
            story.isFavorited
                ? story.favoriteCount - 1
                : story.favoriteCount + 1,
      );

      // Update in all relevant lists
      _updateStoryInLists(story.id, updatedStory);

      // Update favorites list based on new favorite status
      if (story.isFavorited) {
        // Unfavoriting: remove from favorites list (create new list instance)
        _favoriteStories =
            _favoriteStories.where((s) => s.id != story.id).toList();
        _favoritesTotalCount--;
      } else {
        // Favoriting: add to favorites list (create new list instance)
        _favoriteStories = [updatedStory, ..._favoriteStories];
        _favoritesTotalCount++;
      }

      notifyListeners();
    } on ServiceException catch (e) {
      // Handle error - could show snackbar or toast
      debugPrint('Failed to toggle favorite: $e');
    }
  }

  // Helper method to update a story in all lists
  void _updateStoryInLists(int storyId, Story updatedStory) {
    bool hasChanges = false;

    // Helper function to check if story actually changed
    bool hasStoryChanged(Story existing, Story updated) {
      return existing.firstReadAt != updated.firstReadAt ||
          existing.isFavorited != updated.isFavorited ||
          existing.favoriteCount != updated.favoriteCount;
    }

    // Update in My Stories - always create new list to ensure context.select detects change
    final myStoriesIndex = _myStories.indexWhere((s) => s.id == storyId);
    if (myStoriesIndex != -1) {
      final existingStory = _myStories[myStoriesIndex];
      if (hasStoryChanged(existingStory, updatedStory)) {
        _myStories = List.from(_myStories)..[myStoriesIndex] = updatedStory;
        hasChanges = true;
      }
    }

    // Update in Story Square - always create new list to ensure context.select detects change
    final storySquareIndex = _storySquare.indexWhere((s) => s.id == storyId);
    if (storySquareIndex != -1) {
      final existingStory = _storySquare[storySquareIndex];
      if (hasStoryChanged(existingStory, updatedStory)) {
        _storySquare = List.from(_storySquare)
          ..[storySquareIndex] = updatedStory;
        hasChanges = true;
      }
    }

    // Update in Favorites - always create new list to ensure context.select detects change
    final favoritesIndex = _favoriteStories.indexWhere((s) => s.id == storyId);
    if (favoritesIndex != -1) {
      final existingStory = _favoriteStories[favoritesIndex];
      if (hasStoryChanged(existingStory, updatedStory)) {
        _favoriteStories = List.from(_favoriteStories)
          ..[favoritesIndex] = updatedStory;
        hasChanges = true;
      }
    }

    // Only notify listeners if there were actual changes
    if (hasChanges) {
      debugPrint('Story $storyId updated in lists - notifying listeners');
    }
  }

  // Refresh methods
  Future<void> refreshMyStories() async {
    _myStoriesCurrentPage = 1;
    _myStories = [];
    await fetchMyStories();
  }

  Future<void> refreshStorySquare() async {
    _storySquareCurrentPage = 1;
    _storySquare = [];
    await fetchStorySquare();
  }

  Future<void> refreshFavoriteStories() async {
    _favoritesCurrentPage = 1;
    _favoriteStories = [];
    await fetchFavoriteStories();
  }

  // Clear error methods
  void clearMyStoriesError() {
    _myStoriesError = null;
    notifyListeners();
  }

  void clearStorySquareError() {
    _storySquareError = null;
    notifyListeners();
  }

  void clearFavoritesError() {
    _favoritesError = null;
    notifyListeners();
  }

  void clearGenerateError() {
    _generateError = null;
    notifyListeners();
  }

  /// Clear all cached data when user logs out
  @override
  void clearAllData() {
    // Clear My Stories state
    _myStories = [];
    _isLoadingMyStories = false;
    _myStoriesError = null;
    _myStoriesCurrentPage = 1;
    _myStoriesTotalCount = 0;

    // Clear Story Square state
    _storySquare = [];
    _isLoadingStorySquare = false;
    _storySquareError = null;
    _storySquareCurrentPage = 1;
    _storySquareTotalCount = 0;

    // Clear Favorite Stories state
    _favoriteStories = [];
    _isLoadingFavorites = false;
    _favoritesError = null;
    _favoritesCurrentPage = 1;
    _favoritesTotalCount = 0;

    // Clear Story Generation state
    _isGenerating = false;
    _generateError = null;

    // Force immediate UI update
    notifyListeners();
  }

  /// Load initial data when user logs in
  @override
  Future<void> onLogin() async {
    // Don't load data here - let the StoriesScreen load it when mounted
    // This implements lazy loading for better performance
  }
}
