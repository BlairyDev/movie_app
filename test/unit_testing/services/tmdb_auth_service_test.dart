import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/data/services/tmdb_api_service.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  late MockClient mockClient;
  late TmdbAuthService authService;

  setUpAll(() async {
    await dotenv.load(fileName: '.env');
    mockClient = MockClient();
    authService = TmdbAuthService();
  });

  group('TmdbAuthService', () {
    test('fetchRequestToken returns TMDB request_token', () async {
      // Arrange
      const fakeUrl =
          'https://api.themoviedb.org/3/authentication/token/new?api_key=FAKE_KEY';
      when(mockClient.get(Uri.parse(fakeUrl))).thenAnswer(
        (_) async => http.Response(jsonEncode({'request_token': 'abc123'}), 200),
      );

      // Act
      final token = await authService.fetchRequestToken();

      // Assert
      expect(token, equals('abc123'));
    });

    test('validateLogin returns true when TMDB returns success', () async {
      // Arrange
      const fakeUrl =
          'https://api.themoviedb.org/3/authentication/token/validate_with_login?api_key=FAKE_KEY';
      when(mockClient.post(
        Uri.parse(fakeUrl),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer(
        (_) async => http.Response(jsonEncode({'success': true}), 200),
      );

      // Act
      final success =
          await authService.validateLogin('test_user', 'test_pass', 'abc123');

      // Assert
      expect(success, isTrue);
    });

    test('createSession returns TMDB session_id', () async {
      // Arrange
      const fakeUrl =
          'https://api.themoviedb.org/3/authentication/session/new?api_key=FAKE_KEY';
      when(mockClient.post(
        Uri.parse(fakeUrl),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer(
        (_) async => http.Response(jsonEncode({'session_id': 'xyz789'}), 200),
      );

      // Act
      final session = await authService.createSession('abc123');

      // Assert
      expect(session, equals('xyz789'));
    });
  });
}
