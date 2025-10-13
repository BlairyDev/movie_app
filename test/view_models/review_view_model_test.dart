import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:movie_app/data/models/review.dart';
import 'package:movie_app/data/models/review_response.dart';
import 'package:movie_app/data/repositories/tmdb_repository.dart';
import 'package:movie_app/view_models/review_view_model.dart';


// Manual mock
class MockTmdbRepository extends Mock implements TmdbRepository {}

void main() {
  late ReviewViewModel viewModel;
  late MockTmdbRepository mockRepository;

  setUpAll(() async {
    await dotenv.load(fileName: '.env');
    mockRepository = MockTmdbRepository();
    viewModel = ReviewViewModel(repository: mockRepository);
  });

  group('ReviewViewModel Tests', () {

    test('initial state', () {
      expect(viewModel.isLoading, true);
      expect(viewModel.reviews, []);
      expect(viewModel.currentPage, 1);
      expect(viewModel.totalPages, 1);
      expect(viewModel.hasNextPage, false);
    });

    test('loadReviews sets reviews and updates state', () async {
      // Stub the repository to return a ReviewResponse
      final fakeResponse = ReviewResponse(
        page: 1,
        totalPages: 2,
        totalResults: 2,
        results: [
          Review(
            author: 'Author1',
            authorName: 'Name1',
            authorUsername: 'user1',
            authorAvatarPath: null,
            rating: 8.0,
            content: 'Great movie!',
            createdAt: '2025-10-12',
            updatedAt: '2025-10-12',
            url: 'http://review1.url',
            reviewID: 'r1',
          ),
          Review(
            author: 'Author2',
            authorName: 'Name2',
            authorUsername: 'user2',
            authorAvatarPath: null,
            rating: 7.5,
            content: 'Nice movie!',
            createdAt: '2025-10-12',
            updatedAt: '2025-10-12',
            url: 'http://review2.url',
            reviewID: 'r2',
          ),
        ],
      );

      // Stub the method
      when(mockRepository.getMovieReviews(123, page: 1))
          .thenAnswer((_) async => fakeResponse);

      // Act
      await viewModel.loadReviews(123);

      // Assert
      expect(viewModel.isLoading, false);
      expect(viewModel.reviews.length, 2);
      expect(viewModel.currentPage, 1);
      expect(viewModel.totalPages, 2);
      expect(viewModel.hasNextPage, true);

      verify(mockRepository.getMovieReviews(123, page: 1)).called(1);
    });

    test('loadReviewsPage appends reviews for next page', () async {
      final page1 = ReviewResponse(
        page: 1,
        totalPages: 2,
        totalResults: 2,
        results: [
          Review(
            author: 'Author1',
            authorName: 'Name1',
            authorUsername: 'user1',
            authorAvatarPath: null,
            rating: 8.0,
            content: 'Great movie!',
            createdAt: '2025-10-12',
            updatedAt: '2025-10-12',
            url: 'http://review1.url',
            reviewID: 'r1',
          ),
        ],
      );

      final page2 = ReviewResponse(
        page: 2,
        totalPages: 2,
        totalResults: 2,
        results: [
          Review(
            author: 'Author2',
            authorName: 'Name2',
            authorUsername: 'user2',
            authorAvatarPath: null,
            rating: 7.5,
            content: 'Nice movie!',
            createdAt: '2025-10-12',
            updatedAt: '2025-10-12',
            url: 'http://review2.url',
            reviewID: 'r2',
          ),
        ],
      );

      // Stub both pages
      when(mockRepository.getMovieReviews(123, page: 1)).thenAnswer((_) async => page1);
      when(mockRepository.getMovieReviews(123, page: 2)).thenAnswer((_) async => page2);

      // Load both pages
      await viewModel.loadReviewsPage(123, page: 1);
      await viewModel.loadReviewsPage(123, page: 2);

      // Assert combined results
      expect(viewModel.reviews.length, 2);
      expect(viewModel.currentPage, 2);
      expect(viewModel.totalPages, 2);
      expect(viewModel.hasNextPage, false);
    });

    test('loadReviews throws exception on error', () async {
      // Stub to throw
      when(mockRepository.getMovieReviews(123, page: 1))
          .thenThrow(Exception('API Error'));

      expect(() async => await viewModel.loadReviews(123), throwsA(isA<Exception>()));
      expect(viewModel.isLoading, false);
      expect(viewModel.reviews, []);
    });

  });
}
