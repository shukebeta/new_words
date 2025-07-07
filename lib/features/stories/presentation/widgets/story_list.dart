import 'package:flutter/material.dart';
import 'package:new_words/entities/story.dart';
import 'package:new_words/features/stories/presentation/widgets/story_card.dart';

class StoryList extends StatefulWidget {
  final List<Story> stories;
  final bool isLoading;
  final String? error;
  final bool canLoadMore;
  final VoidCallback onRefresh;
  final VoidCallback onLoadMore;
  final VoidCallback onClearError;
  final String emptyMessage;

  const StoryList({
    super.key,
    required this.stories,
    required this.isLoading,
    this.error,
    required this.canLoadMore,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onClearError,
    required this.emptyMessage,
  });

  @override
  State<StoryList> createState() => _StoryListState();
}

class _StoryListState extends State<StoryList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (widget.canLoadMore && !widget.isLoading) {
        widget.onLoadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show error state
    if (widget.error != null && widget.stories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading stories',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              widget.error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                widget.onClearError();
                widget.onRefresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show empty state
    if (widget.stories.isEmpty && !widget.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              widget.emptyMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Show loading state for initial load
    if (widget.stories.isEmpty && widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Show stories list
    return RefreshIndicator(
      onRefresh: () async {
        widget.onRefresh();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: widget.stories.length + (widget.canLoadMore || widget.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loading indicator at the end
          if (index >= widget.stories.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final story = widget.stories[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: StoryCard(story: story),
          );
        },
      ),
    );
  }
}