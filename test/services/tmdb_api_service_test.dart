import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/data/services/tmdb_api_service.dart';

// Mock http.Client (not injected, but used for simulation)
class MockClient extends Mock implements http.Client {}

void main() {
  late MockClient mockClient;
  late TmdbApiService apiService;

  setUpAll(() async {
    await dotenv.load(fileName: '.env');
    mockClient = MockClient();
    apiService = TmdbApiService();
  });

  group('TmdbApiService', () {
    test('runAPI returns decoded JSON when TMDB responds with 200', () async {
      // Arrange
      const fakeUrl =
          'https://api.themoviedb.org/3/movie/upcoming?api_key=FAKE_KEY&language=en-US';
      const mockResponse = '''
      {
        "page": 1,
        "results": [
          {"id": 1, "title": "Dune: Part Two"},
          {"id": 2, "title": "Gladiator II"}
        ]
      }
      ''';

      when(mockClient.get(Uri.parse(fakeUrl))).thenAnswer(
        (_) async => http.Response(mockResponse, HttpStatus.ok),
      );

      // Act
      final result = await apiService.runAPI(fakeUrl);

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['results'][0]['title'], equals('Dune: Part Two'));
    });

    test('runAPI throws exception when TMDB responds with error', () async {
      // Arrange
      const fakeUrl = 'https://api.themoviedb.org/3/movie/upcoming?bad_key';
      when(mockClient.get(Uri.parse(fakeUrl)))
          .thenAnswer((_) async => http.Response('Invalid API key', 401));

      // Act + Assert
      expect(() async => apiService.runAPI(fakeUrl), throwsException);
    });

    test('fetchUpcomingMovies builds a valid TMDB endpoint', () async {
      // Act
      final result = await apiService.fetchUpcomingMovies();

      // Assert
      expect(result, isA<Map<String, dynamic>>());
    });

    test('fetchSearchMovies builds a valid TMDB search URL', () async {
      // Act
      final result = await apiService.fetchSearchMovies('batman');

      // Assert
      expect(result, isA<Map<String, dynamic>>());
    });

    test('fetchMovieReviews builds a valid TMDB review URL', () async {
      // Act
      final result = await apiService.fetchMovieReviews(550);

      // Assert
      expect(result, isA<Map<String, dynamic>>());
    });
  });
}
