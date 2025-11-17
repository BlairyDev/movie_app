import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/data/models/review.dart';
import 'package:movie_app/data/models/review_response.dart';
import 'package:movie_app/data/repositories/tmdb_repository.dart';
import 'package:movie_app/view_models/review_view_model.dart';

class MockTmdbRepository extends Mock implements TmdbRepository {}

void main() {
  late MockTmdbRepository mockRepo;
  late ReviewViewModel viewModel;

  // Sample Review
  final review1 = Review(
    author: "author1",
    authorName: "John Doe",
    authorUsername: "jdoe",
    authorAvatarPath: "https://img.com/a.jpg",
    rating: 8.0,
    content: "Great movie!",
    createdAt: "2024-01-01",
    updatedAt: "2024-01-02",
    url: "https://review.com/1",
    reviewID: "rev1",
  );

  final review2 = Review(
    author: "author2",
    authorName: "Jane Smith",
    authorUsername: "jsmith",
    authorAvatarPath: "https://img.com/b.jpg",
    rating: 7.0,
    content: "Nice film!",
    createdAt: "2024-01-03",
    updatedAt: "2024-01-04",
    url: "https://review.com/2",
    reviewID: "rev2",
  );

  // Mocked responses
  final page1Response = ReviewResponse(
    page: 1,
    totalPages: 2,
    totalResults: 2,
    results: [review1],
  );

  final page2Response = ReviewResponse(
    page: 2,
    totalPages: 2,
    totalResults: 2,
    results: [review2],
  );

  setUp(() {
    mockRepo = MockTmdbRepository();
    viewModel = ReviewViewModel(repository: mockRepo);
  });

  group("ReviewViewModel Tests", () {
    
    test("loadReviews loads page 1 correctly", () async {
      when(() => mockRepo.getMovieReviews(10, page: 1))
          .thenAnswer((_) async => page1Response);

      await viewModel.loadReviews(10);

      expect(viewModel.isLoading, false);
      expect(viewModel.reviews.length, 1);
      expect(viewModel.reviews.first.author, "author1");
      expect(viewModel.currentPage, 1);
      expect(viewModel.totalPages, 2);
    });

    test("loadReviewsPage appends next pages", () async {
      // Page 1
      when(() => mockRepo.getMovieReviews(10, page: 1))
          .thenAnswer((_) async => page1Response);
      await viewModel.loadReviews(10);

      // Page 2
      when(() => mockRepo.getMovieReviews(10, page: 2))
          .thenAnswer((_) async => page2Response);
      await viewModel.loadReviewsPage(10, page: 2);

      expect(viewModel.reviews.length, 2);
      expect(viewModel.reviews[0].reviewID, "rev1");
      expect(viewModel.reviews[1].reviewID, "rev2");
      expect(viewModel.currentPage, 2);
    });

    test("hasNextPage returns true until last page", () async {
      when(() => mockRepo.getMovieReviews(10, page: 1))
          .thenAnswer((_) async => page1Response);

      await viewModel.loadReviews(10);

      expect(viewModel.hasNextPage, true);
    });

    test("hasNextPage returns false on last page", () async {
      when(() => mockRepo.getMovieReviews(10, page: 1))
          .thenAnswer((_) async => ReviewResponse(
                page: 1,
                totalPages: 1,
                totalResults: 1,
                results: [review1],
              ));

      await viewModel.loadReviews(10);

      expect(viewModel.hasNextPage, false);
    });

    test("throws exception on repository error", () async {
      when(() => mockRepo.getMovieReviews(10, page: 1))
          .thenThrow(Exception("Network error"));

      expect(() async => viewModel.loadReviews(10), throwsException);
    });
  });
}