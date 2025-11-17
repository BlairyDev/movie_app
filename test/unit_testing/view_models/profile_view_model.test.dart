import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/data/models/profile.dart';
import 'package:movie_app/data/services/tmdb_api_service.dart';
import 'package:movie_app/view_models/profile_view_model.dart';

class MockTmdbApiService extends Mock implements TmdbApiService {}

void main() {
  late MockTmdbApiService mockApiService;

  setUp(() {
    mockApiService = MockTmdbApiService();
    // Clear SessionManager before each test
    SessionManager().clear();
  });

  test('loadWatchlistMovies loads movies successfully', () async {
    // Arrange: mock session values
    final session = SessionManager();
    session.sessionId = 'mockSession123';
    session.accountId = 999;

    // Arrange: mock API response
    final mockResponse = {
      "results": [
        {
          "id": 1,
          "title": "Test Movie",
          "vote_average": 7.8,
          "release_date": "2024-01-01",
          "overview": "Movie overview",
          "poster_path": "/poster.jpg",
          "genre_ids": [28, 12],
          "original_language": "en"
        }
      ]
    };

    when(() => mockApiService.fetchMovieWatchlist(session.accountId!, session.sessionId!))
        .thenAnswer((_) async => mockResponse);

    final viewModel = ProfileViewModel(apiService: mockApiService);

    // Act
    await viewModel.loadWatchlistMovies();

    // Assert
    verify(() => mockApiService.fetchMovieWatchlist(session.accountId!, session.sessionId!))
        .called(1);

    expect(viewModel.isLoading, false);
    expect(viewModel.error, isNull);
    expect(viewModel.watchlistMovies.length, 1);

    final movie = viewModel.watchlistMovies.first;
    expect(movie.id, 1);
    expect(movie.title, "Test Movie");
    expect(movie.voteAverage, 7.8);
    expect(movie.posterPath, "/poster.jpg");
  });

  test('loadWatchlistMovies sets error if no session', () async {
    // Arrange: no session set

    final viewModel = ProfileViewModel(apiService: mockApiService);

    // Act
    await viewModel.loadWatchlistMovies();

    // Assert
    expect(viewModel.isLoading, false);
    expect(viewModel.watchlistMovies, isEmpty);
    expect(viewModel.error, 'No active session found');

    // Verify API not called
    verifyNever(() => mockApiService.fetchMovieWatchlist(any(), any()));
  });
}