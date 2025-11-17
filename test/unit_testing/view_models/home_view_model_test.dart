// Mock repository
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/data/models/movie.dart';
import 'package:movie_app/data/models/paged_movies.dart';
import 'package:movie_app/data/repositories/tmdb_repository.dart';
import 'package:movie_app/view_models/home_view_model.dart';

class MockTmdbRepository extends Mock implements TmdbRepository {}

void main() {
  late MockTmdbRepository mockRepo;
  late HomeViewModel viewModel;

  // Fake movie
  final fakeMovie = Movie(
    id: 1,
    title: 'Sample Movie',
    voteAverage: 7.5,
    releaseDate: '2024-01-01',
    overview: 'Test overview',
    posterPath: '/poster.jpg',
    genreIds: [28],
    originalLanguage: 'en',
  );

  // Fake paginated result
  final fakePagedMovies = PagedMovies(
    movies: [fakeMovie],
    totalPages: 3,
  );

  setUp(() {
    mockRepo = MockTmdbRepository();
    viewModel = HomeViewModel(repository: mockRepo);

    registerFallbackValue(<String, dynamic>{});
  });

  group('HomeViewModel', () {
    
    test('loadUpcomingMovies loads upcoming movies', () async {
      when(() => mockRepo.getPagedFilteredMovies(
        page: 1,
        title: null,
        filters: null,
        isUpcoming: true,
      )).thenAnswer((_) async => fakePagedMovies);

      await viewModel.loadUpcomingMovies();

      expect(viewModel.movies.length, 1);
      expect(viewModel.movies.first.title, 'Sample Movie');
      expect(viewModel.totalPages, 3);
      expect(viewModel.currentPage, 1);
      expect(viewModel.isLoading, false);
    });

    test('searchMovies loads movies matching query', () async {
      when(() => mockRepo.getPagedFilteredMovies(
        page: 1,
        title: 'batman',
        filters: null,
        isUpcoming: false,
      )).thenAnswer((_) async => fakePagedMovies);

      await viewModel.searchMovies('batman');

      expect(viewModel.currentSearchQuery, 'batman');
      expect(viewModel.movies.length, 1);
    });

    test('applyFilters applies filters correctly', () async {
      final filters = {'genre': 28};

      when(() => mockRepo.getPagedFilteredMovies(
        page: 1,
        title: null,
        filters: filters,
        isUpcoming: false,
      )).thenAnswer((_) async => fakePagedMovies);

      await viewModel.applyFilters(filters);

      expect(viewModel.currentFilters, filters);
      expect(viewModel.movies.length, 1);
    });

    test('nextPage loads page 2', () async {
      // Page 1
      when(() => mockRepo.getPagedFilteredMovies(
        page: 1,
        title: null,
        filters: null,
        isUpcoming: false,
      )).thenAnswer((_) async => fakePagedMovies);

      await viewModel.searchMovies('');

      // Page 2
      when(() => mockRepo.getPagedFilteredMovies(
        page: 2,
        title: null,
        filters: null,
        isUpcoming: false,
      )).thenAnswer((_) async => fakePagedMovies);

      await viewModel.nextPage();

      expect(viewModel.currentPage, 2);
    });

    test('previousPage loads page 1 again', () async {
      // Page 1
      when(() => mockRepo.getPagedFilteredMovies(
        page: 1,
        title: null,
        filters: null,
        isUpcoming: false,
      )).thenAnswer((_) async => fakePagedMovies);

      await viewModel.searchMovies('');

      // Move to page 2
      when(() => mockRepo.getPagedFilteredMovies(
        page: 2,
        title: null,
        filters: null,
        isUpcoming: false,
      )).thenAnswer((_) async => fakePagedMovies);

      await viewModel.nextPage();

      // Back to page 1
      when(() => mockRepo.getPagedFilteredMovies(
        page: 1,
        title: null,
        filters: null,
        isUpcoming: false,
      )).thenAnswer((_) async => fakePagedMovies);

      await viewModel.previousPage();

      expect(viewModel.currentPage, 1);
    });

    test('error during fetch resets movies & sets totalPages = 0', () async {
      when(() => mockRepo.getPagedFilteredMovies(
        page: 1,
        title: null,
        filters: null,
        isUpcoming: false,
      )).thenThrow(Exception('Network error'));

      await viewModel.searchMovies('');

      expect(viewModel.movies, []);
      expect(viewModel.totalPages, 0);
      expect(viewModel.isLoading, false);
    });
  });
}