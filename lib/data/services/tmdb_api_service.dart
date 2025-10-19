import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TmdbApiService {
  final String? apiKey = dotenv.env['API_KEY'];
  final String urlBase = 'https://api.themoviedb.org/3';
  final String apiUpcoming = '/movie/upcoming?';
  final String apiSearch = '/search/movie?';
  final String urlLanguage = '&language=en-US';

  
  Future<Map<String, dynamic>> runAPI(API) async {
    http.Response result = await http.get(Uri.parse(API));
    if (result.statusCode == HttpStatus.ok) {
      final jsonResponse = json.decode(result.body);

      print('Request failed with status: ${result.statusCode}.');
      print('Response body: ${result.body}');
      print('API URL: $API');
      
      
      return jsonResponse;
      
    } else {
      print('Request failed with status: ${result.statusCode}.');
      print('Response body: ${result.body}');
      print('API URL: $API');
      
      throw Exception("Failed to fetch");
    }
  }

  Future<Map<String, dynamic>> fetchUpcomingMovies() async {
    final String upcomingAPI = urlBase + apiUpcoming + apiKey! + urlLanguage;
    return runAPI(upcomingAPI);
  }

  Future<Map<String, dynamic>> fetchSearchMovies(String title) async {
    final String search =
        urlBase + apiSearch + 'query=' + title + '&' + apiKey!;
  
    return runAPI(search);
  }
  
  Future<Map<String, dynamic>> fetchMovieReviews(int movieId, {int page = 1}) async {
    final String reviewsAPI =
        '$urlBase/movie/$movieId/reviews?$apiKey$urlLanguage&page=$page';

    return runAPI(reviewsAPI);
  }
  Future<Map<String, dynamic>> getMovieWatchlist(int accountId, String sessionId) async {
    final String movieWatchlistAPI =
        '$urlBase/account/$accountId/watchlist/movies?api_key=$apiKey&session_id=$sessionId&language=en-US&sort_by=created_at.asc';

    return runAPI(movieWatchlistAPI);
  }

  Future<Map<String, dynamic>> getTvWatchlist(int accountId, String sessionId) async {
    final String tvWatchlistAPI =
        '$urlBase/account/$accountId/watchlist/tv?api_key=$apiKey&session_id=$sessionId&language=en-US&sort_by=created_at.asc';

    return runAPI(tvWatchlistAPI);
  }
}

class TmdbAuthService {
  final String? accessToken = dotenv.env['API_KEY'];
  final String urlBase = 'https://api.themoviedb.org/3';

  Future<String> fetchRequestToken() async {
    final response = await http.get(
      Uri.parse('$urlBase/authentication/token/new?$accessToken'),
    );
    final data = json.decode(response.body);
    return data ['request_token'];
  }
  Future<bool> validateLogin(String username, String password, String requestToken) async {
    final response = await http.post(
      Uri.parse('$urlBase/authentication/token/validate_with_login?$accessToken'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
        'request_token': requestToken,
      }),
    );
    final data = json.decode(response.body);
    return data['success'] == true;
  }

  Future<String> createSession(String validatedRequestToken) async {
    final response = await http.post(
      Uri.parse('$urlBase/authentication/session/new?$accessToken'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'request_token': validatedRequestToken}),
    );
    final data = json.decode(response.body);
    return data['session_id'];
  }
  Future<Map<String, dynamic>> fetchAccountDetails(String sessionId) async {
    final response = await http.get(
      Uri.parse('$urlBase/account?$accessToken&session_id=$sessionId'),
    );
    return json.decode(response.body);
  }
}
