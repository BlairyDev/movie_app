import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:movie_app/data/models/movie.dart';
import 'package:movie_app/data/repositories/tmdb_repository.dart';
import 'package:movie_app/view_models/home_view_model.dart';


// Mock repository
class MockTmdbRepository extends Mock implements TmdbRepository {}

void main() {
  late HomeViewModel viewModel;
  late MockTmdbRepository mockRepository;

  setUpAll(() async {
    await dotenv.load(fileName: '.env');
    mockRepository = MockTmdbRepository();
    viewModel = HomeViewModel(repository: mockRepository);
  });

  group('HomeViewModel Tests', () {
    
    test('initial state', () {
      expect(viewModel.isLoading, true);
      expect(viewModel.movies, []);
    });

    test('loadUpcomingMovies updates movies and isLoading', () async {
      // Arrange: create fake Movie objects
      final fakeMovies = [
        Movie(
          id: 1,
          title: 'Movie 1',
          voteAverage: 8.0,
          releaseDate: '2025-10-01',
          overview: 'Overview 1',
          posterPath: '/poster1.jpg',
        ),
        Movie(
          id: 2,
          title: 'Movie 2',
          voteAverage: 7.5,
          releaseDate: '2025-11-01',
          overview: 'Overview 2',
          posterPath: '/poster2.jpg',
        ),
      ];

      when(mockRepository.getUpcomingMovies()).thenAnswer((_) async => fakeMovies);

      // Act
      await viewModel.loadUpcomingMovies();

      // Assert
      expect(viewModel.isLoading, false);
      expect(viewModel.movies, fakeMovies);
      verify(mockRepository.getUpcomingMovies()).called(1);
    });

    test('loadSearchMovies updates movies and isLoading', () async {
      final searchMovies = [
        Movie(
          id: 3,
          title: 'Search Movie',
          voteAverage: 9.0,
          releaseDate: '2025-09-15',
          overview: 'Overview 3',
          posterPath: '/poster3.jpg',
        ),
      ];

      when(mockRepository.getSearchMovies('search')).thenAnswer((_) async => searchMovies);

      await viewModel.loadSearchMovies('search');

      expect(viewModel.isLoading, false);
      expect(viewModel.movies, searchMovies);
      verify(mockRepository.getSearchMovies('search')).called(1);
    });

    test('loadUpcomingMovies throws exception on error', () async {
      when(mockRepository.getUpcomingMovies()).thenThrow(Exception('API Error'));

      expect(
        () async => await viewModel.loadUpcomingMovies(),
        throwsA(isA<Exception>()),
      );

      expect(viewModel.isLoading, false);
      expect(viewModel.movies, []);
    });

    test('loadSearchMovies throws exception on error', () async {
      when(mockRepository.getSearchMovies('fail')).thenThrow(Exception('API Error'));

      expect(
        () async => await viewModel.loadSearchMovies('fail'),
        throwsA(isA<Exception>()),
      );

      expect(viewModel.isLoading, false);
      expect(viewModel.movies, []);
    });

  });
}
