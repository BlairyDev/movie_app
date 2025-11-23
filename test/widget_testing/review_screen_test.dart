import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/data/models/movie.dart';
import 'package:movie_app/data/models/review.dart';
import 'package:movie_app/data/repositories/tmdb_repository.dart';
import 'package:movie_app/view/review_screen.dart';
import 'package:movie_app/view_models/review_view_model.dart';

// A fake ViewModel for testing
class FakeReviewViewModel extends ChangeNotifier implements ReviewViewModel {
  @override
  bool _isLoading = false;

  @override
  bool get isLoading => _isLoading;

  @override
  List<Review> _reviews = [];

  @override
  List<Review> get reviews => _reviews;

  @override
  int get currentPage => 1;

  @override
  int get totalPages => 1;

  @override
  bool get hasNextPage => false;

  void setReviews(List<Review> reviews, {bool loading = false}) {
    _reviews = reviews;
    _isLoading = loading;
    notifyListeners();
  }

  @override
  Future<void> loadReviews(int movieId) async {}

  @override
  Future<void> loadReviewsPage(int movieId, {int page = 1}) async {}

  @override
  // TODO: implement repository
  TmdbRepository get repository => throw UnimplementedError();
}

void main() {
  group('ReviewScreen Widget Tests', () {
    late Movie testMovie;
    late FakeReviewViewModel fakeViewModel;

    setUp(() {
      testMovie = Movie(
        id: 1,
        title: 'Test Movie',
        voteAverage: 8.5,
        releaseDate: '2025-01-01',
        overview: 'Overview of test movie',
        posterPath: '/test.jpg',
        genreIds: [1, 2],
        originalLanguage: 'en',
      );

      fakeViewModel = FakeReviewViewModel();
    });

    testWidgets('shows loading indicator when isLoading is true and no reviews', (tester) async {
      fakeViewModel.setReviews([], loading: true);

      await tester.pumpWidget(
        MaterialApp(
          home: ReviewScreen(
            movie: testMovie,
            viewModel: fakeViewModel,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows "No reviews available." when reviews are empty and not loading', (tester) async {
      fakeViewModel.setReviews([], loading: false);

      await tester.pumpWidget(
        MaterialApp(
          home: ReviewScreen(
            movie: testMovie,
            viewModel: fakeViewModel,
          ),
        ),
      );

      expect(find.text('No reviews available.'), findsOneWidget);
    });

    testWidgets('shows list of reviews', (tester) async {
      final reviews = [
        Review(
          author: 'author1',
          authorName: 'Author One',
          authorUsername: 'user1',
          authorAvatarPath: null,
          rating: 8.0,
          content: 'Great movie!',
          createdAt: '2025-01-01',
          updatedAt: '2025-01-01',
          url: 'http://test.com/review1',
          reviewID: '1',
        ),
        Review(
          author: 'author2',
          authorName: '',
          authorUsername: 'user2',
          authorAvatarPath: null,
          rating: 7.0,
          content: 'Not bad.',
          createdAt: '2025-01-02',
          updatedAt: '2025-01-02',
          url: 'http://test.com/review2',
          reviewID: '2',
        ),
      ];

      fakeViewModel.setReviews(reviews, loading: false);

      await tester.pumpWidget(
        MaterialApp(
          home: ReviewScreen(
            movie: testMovie,
            viewModel: fakeViewModel,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Author One'), findsOneWidget);
      expect(find.text('Great movie!'), findsOneWidget);
      expect(find.text('user2'), findsOneWidget); // because authorName is empty
      expect(find.text('Not bad.'), findsOneWidget);
    });
  });
}
