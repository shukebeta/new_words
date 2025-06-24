import 'package:flutter/foundation.dart';
import 'package:new_words/app_config.dart';
import 'package:new_words/entities/story.dart';
import 'package:new_words/exceptions/api_exception.dart';
import 'package:new_words/services/stories_service.dart';

class StoriesProvider with ChangeNotifier {
  final StoriesService _storiesService;

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
  bool get canLoadMoreStorySquare => _storySquare.length < _storySquareTotalCount;
  bool get canLoadMoreFavorites => _favoriteStories.length < _favoritesTotalCount;

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
      final pageData = await _storiesService.getMyStories(_myStoriesCurrentPage, _pageSize);
      if (loadMore) {
        _myStories.addAll(pageData.dataList);
      } else {
        _myStories = pageData.dataList;
      }
      _myStoriesTotalCount = pageData.totalCount;
      if (pageData.dataList.isNotEmpty) {
        _myStoriesCurrentPage++;
      }
    } on ApiException catch (e) {
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
      final pageData = await _storiesService.getStorySquare(_storySquareCurrentPage, _pageSize);
      if (loadMore) {
        _storySquare.addAll(pageData.dataList);
      } else {
        _storySquare = pageData.dataList;
      }
      _storySquareTotalCount = pageData.totalCount;
      if (pageData.dataList.isNotEmpty) {
        _storySquareCurrentPage++;
      }
    } on ApiException catch (e) {
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
      final pageData = await _storiesService.getMyFavoriteStories(_favoritesCurrentPage, _pageSize);
      if (loadMore) {
        _favoriteStories.addAll(pageData.dataList);
      } else {
        _favoriteStories = pageData.dataList;
      }
      _favoritesTotalCount = pageData.totalCount;
      if (pageData.dataList.isNotEmpty) {
        _favoritesCurrentPage++;
      }
    } on ApiException catch (e) {
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
      final newStories = await _storiesService.generateStories(customWords: customWords);
      
      // Add new stories to the beginning of My Stories list
      for (final story in newStories.reversed) {
        _myStories.insert(0, story);
        _myStoriesTotalCount++;
      }
      
      _isGenerating = false;
      notifyListeners();
      return newStories;
    } on ApiException catch (e) {
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
  Future<List<Story>?> regenerateStoriesFromExisting(Story existingStory) async {
    if (_isGenerating) return null;

    _isGenerating = true;
    _generateError = null;
    notifyListeners();

    try {
      final newStories = await _storiesService.generateStories(customWords: existingStory.vocabularyWords);
      
      // Add new stories to the beginning of My Stories list
      for (final story in newStories.reversed) {
        _myStories.insert(0, story);
        _myStoriesTotalCount++;
      }
      
      _isGenerating = false;
      notifyListeners();
      return newStories;
    } on ApiException catch (e) {
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

    print('Marking story ${story.id} as read...');
    
    // Update local state immediately for better UX (optimistic update)
    final readTimestamp = DateTime.now().millisecondsSinceEpoch;
    final updatedStory = story.copyWith(
      firstReadAt: readTimestamp,
    );

    // Update in all relevant lists first
    _updateStoryInLists(story.id, updatedStory);
    notifyListeners();

    // Then call service to mark as read on backend
    try {
      await _storiesService.markAsReadIfNeeded(story);
      print('Successfully marked story ${story.id} as read');
    } catch (e) {
      print('Failed to mark story as read: $e');
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
        favoriteCount: story.isFavorited 
            ? story.favoriteCount - 1 
            : story.favoriteCount + 1,
      );

      // Update in all relevant lists
      _updateStoryInLists(story.id, updatedStory);

      // If unfavoriting, remove from favorites list
      if (story.isFavorited) {
        _favoriteStories.removeWhere((s) => s.id == story.id);
        _favoritesTotalCount--;
      }

      notifyListeners();
    } on ApiException catch (e) {
      // Handle error - could show snackbar or toast
      print('Failed to toggle favorite: $e');
    }
  }

  // Helper method to update a story in all lists
  void _updateStoryInLists(int storyId, Story updatedStory) {
    // Update in My Stories
    final myStoriesIndex = _myStories.indexWhere((s) => s.id == storyId);
    if (myStoriesIndex != -1) {
      _myStories[myStoriesIndex] = updatedStory;
    }

    // Update in Story Square
    final storySquareIndex = _storySquare.indexWhere((s) => s.id == storyId);
    if (storySquareIndex != -1) {
      _storySquare[storySquareIndex] = updatedStory;
    }

    // Update in Favorites
    final favoritesIndex = _favoriteStories.indexWhere((s) => s.id == storyId);
    if (favoritesIndex != -1) {
      _favoriteStories[favoritesIndex] = updatedStory;
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
}