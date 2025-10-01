import 'package:flutter/material.dart';
import '../data/repositories/tmdb_repository.dart';
import '../data/models/review_response.dart';
import '../data/models/review.dart';

class ReviewViewModel extends ChangeNotifier {
  final TmdbRepository repository;

  ReviewViewModel({
    required this.repository
  });

  bool _isLoading = true;
  ReviewResponse? _reviewResponse;

  bool get isLoading => _isLoading;
  List<Review> get reviews => _reviewResponse?.results ?? [];
  int get currentPage => _reviewResponse?.page ?? 1;
  int get totalPages => _reviewResponse?.totalPages ?? 1;
  bool get hasNextPage => currentPage < totalPages;

  Future<void> loadReviews(int movieId) async {
    await loadReviewsPage(movieId, page: 1);
  }

  Future<void> loadReviewsPage(int movieId, {int page = 1}) async {
  _isLoading = true;
  notifyListeners();

  try {
    final newResponse = await repository.getMovieReviews(movieId, page: page);

    if (_reviewResponse == null || page == 1) {
      _reviewResponse = newResponse;
    } else {
      _reviewResponse!.results.addAll(newResponse.results);
      _reviewResponse!.page = newResponse.page;
      _reviewResponse!.totalPages = newResponse.totalPages;
      _reviewResponse!.totalResults = newResponse.totalResults;
    }

  } catch (e) {
    throw Exception(e);
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

}