import 'package:flutter/material.dart';
import 'package:movie_app/data/repositories/tmdb_repository_real.dart';
import '../data/models/movie.dart';
import '../view_models/review_view_model.dart';

class ReviewScreen extends StatefulWidget {
  final Movie movie;

  const ReviewScreen({Key? key, required this.movie}) : super(key: key);

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late final ReviewViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ReviewViewModel(repository: TmdbRepositoryReal());
    _viewModel.loadReviews(widget.movie.id);
  }

  void _loadNextPage() {
    if (_viewModel.hasNextPage && !_viewModel.isLoading) {
      _viewModel.loadReviewsPage(widget.movie.id, page: _viewModel.currentPage + 1)
          .catchError((e) => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to load more reviews')),
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.movie.title} Reviews'),
      ),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading && _viewModel.reviews.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_viewModel.reviews.isEmpty) {
            return const Center(child: Text('No reviews available.'));
          }

          final reviews = _viewModel.reviews;

          return SingleChildScrollView(
            child: Column(
              children: [
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: reviews.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    final author = review.authorName.isNotEmpty
                        ? review.authorName
                        : review.authorUsername.isNotEmpty
                            ? review.authorUsername
                            : review.author;
                    return ListTile(
                      title: Text(author),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(review.content),
                          const SizedBox(height: 4),
                          Text(
                            review.createdAt,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                if (_viewModel.hasNextPage)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: _loadNextPage,
                      child: _viewModel.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Load More Reviews'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
