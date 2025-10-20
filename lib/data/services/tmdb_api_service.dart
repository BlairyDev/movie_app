import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TmdbApiService {
  final String? apiKey = dotenv.env['API_KEY'];
  final String? accessToken = dotenv.env['ACCESS_TOKEN'];
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

  Future<Map<String, dynamic>> runAuthAPI(String url, {required String sessionId}) async {
    final uri = Uri.parse(url);
    
    http.Response result = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${accessToken?.replaceAll('access_token=', '')}',
        'Content-Type': 'application/json',
      },
    );
    
    if (result.statusCode == HttpStatus.ok) {
      final jsonResponse = json.decode(result.body);
      print('Auth request successful with status: ${result.statusCode}.');
      print('API URL: $url');
      return jsonResponse;
    } else {
      print('Auth request failed with status: ${result.statusCode}.');
      print('Response body: ${result.body}');
      print('API URL: $url');
      throw Exception("Failed to fetch authenticated data");
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

  Future<Map<String, dynamic>> fetchMovieWatchlist(int accountId, String sessionId, {int page = 1}) async {
    final String watchlistAPI =
        '$urlBase/account/$accountId/watchlist/movies?session_id=$sessionId&language=en-US&page=$page&sort_by=created_at.desc';

    return runAuthAPI(watchlistAPI, sessionId: sessionId);
  }

  Future<Map<String, dynamic>> fetchTvWatchlist(int accountId, String sessionId, {int page = 1}) async {
    final String watchlistAPI =
        '$urlBase/account/$accountId/watchlist/tv?session_id=$sessionId&language=en-US&page=$page&sort_by=created_at.desc';

    return runAuthAPI(watchlistAPI, sessionId: sessionId);
  }
}

class TmdbAuthService {
  final String? accessToken = dotenv.env['ACCESS_TOKEN'];
  final String urlBase = 'https://api.themoviedb.org/3';

  Future<String> fetchRequestToken() async {
    final cleanToken = accessToken?.replaceAll('access_token=', '');
    final response = await http.get(
      Uri.parse('$urlBase/authentication/token/new'),
      headers: {
        'Authorization': 'Bearer $cleanToken',
        'Content-Type': 'application/json',
      },
    );
    final data = json.decode(response.body);
    return data['request_token'];
  }

  Future<bool> validateLogin(String username, String password, String requestToken) async {
    final cleanToken = accessToken?.replaceAll('access_token=', '');
    final response = await http.post(
      Uri.parse('$urlBase/authentication/token/validate_with_login'),
      headers: {
        'Authorization': 'Bearer $cleanToken',
        'Content-Type': 'application/json',
      },
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
    final cleanToken = accessToken?.replaceAll('access_token=', '');
    final response = await http.post(
      Uri.parse('$urlBase/authentication/session/new'),
      headers: {
        'Authorization': 'Bearer $cleanToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'request_token': validatedRequestToken}),
    );
    final data = json.decode(response.body);
    return data['session_id'];
  }

  Future<Map<String, dynamic>> fetchAccountDetails(String sessionId) async {
    final cleanToken = accessToken?.replaceAll('access_token=', '');
    final response = await http.get(
      Uri.parse('$urlBase/account?session_id=$sessionId'),
      headers: {
        'Authorization': 'Bearer $cleanToken',
        'Content-Type': 'application/json',
      },
    );
    return json.decode(response.body);
  }
}
