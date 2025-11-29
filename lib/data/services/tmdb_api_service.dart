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

      print('Request succceded with status: ${result.statusCode}.');
      print('Response body: ${result.body}');
      print('API URL: $API');
      
      return jsonResponse;
      
    } else {
      print('Request failed with status: ${result.statusCode}.');
      print('Response body: ${result.body}.');
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

  Future<Map<String, dynamic>> fetchSearchMovies(String title, {int page = 1}) async {
    final tempApiKey = apiKey;
    final transformedApiKey = tempApiKey!.split('=').last;
    final uri = Uri.parse('$urlBase/search/movie').replace(queryParameters: {
      'api_key': transformedApiKey,
      'language': 'en-US',
      'query': title,
      'page': page.toString(),
    });
    return runAPI(uri.toString());
  }
  
  Future<Map<String, dynamic>> fetchMovieReviews(int movieId, {int page = 1}) async {
    final String reviewsAPI =
        '$urlBase/movie/$movieId/reviews?$apiKey$urlLanguage&page=$page';

    return runAPI(reviewsAPI);
  }

  Future<Map<String, dynamic>> fetchMovieWatchlist(int accountId, String sessionId, {int page = 1}) async {
    final String watchlistAPI =
        '$urlBase/account/$accountId/watchlist/movies?session_id=$sessionId&language=en-US&page=$page&sort_by=created_at.desc&$apiKey';

    return runAuthAPI(watchlistAPI, sessionId: sessionId);
  }

  Future<Map<String, dynamic>> fetchTvWatchlist(int accountId, String sessionId, {int page = 1}) async {
    final String watchlistAPI =
        '$urlBase/account/$accountId/watchlist/tv?session_id=$sessionId&language=en-US&page=$page&sort_by=created_at.desc&$apiKey';

    return runAuthAPI(watchlistAPI, sessionId: sessionId);
  }

  Future<Map<String, dynamic>> fetchGenres() async {
    final String api = '$urlBase/genre/movie/list?$apiKey&language=en-US';
    return runAPI(api);
  }

  Future<Map<String, dynamic>> fetchLanguages() async {
    final String api = '$urlBase/configuration/languages?$apiKey';
    final response = await http.get(Uri.parse(api));
    if (response.statusCode == 200) {
      final list = json.decode(response.body);
      return {'languages': list};
    } else {
      throw Exception('Failed to fetch languages');
    }
  }

  Future<Map<String, dynamic>> fetchPagedMovies(String endpoint, Map<String, String> queryParams) async {
    final tempApiKey = apiKey;
    final transformedApiKey = tempApiKey!.split('=').last;
    
    final defaultParams = {
      'api_key': transformedApiKey,
      'language': 'en-US',
    };
    
    final uri = Uri.parse('$urlBase/$endpoint').replace(queryParameters: {
      ...defaultParams,
      ...queryParams,
    });

    return runAPI(uri.toString());
  }


  Future<Map<String, dynamic>> discoverMovies(Map<String, String> queryParams) async {
    final tempApiKey = apiKey;
    final transformedApiKey = tempApiKey!.split('=').last;
    final uri = Uri.parse('$urlBase/discover/movie').replace(queryParameters: {
      'api_key': transformedApiKey,
      'language': 'en-US',
      ...queryParams,
    });
    return runAPI(uri.toString());
  }

    /*
    Favorites APIS
  */

  //GET Favorite Movies
  Future<Map<String, dynamic>> getFavoritesMoviesList(int? accountId, String? sessionId) async {
    final String favoritesList =
        '$urlBase/account/$accountId/favorite/movies?$apiKey&session_id=$sessionId&language=en-US&sort_by=created_at.asc';

    return runAPI(favoritesList);
  }

  //GET Favorite TV Shows 
  Future<Map<String, dynamic>> getFavoritesTVList(int? accountId, String? sessionId) async {
    final String favoritesList =
        '$urlBase/account/$accountId/favorite/tv?$apiKey&session_id=$sessionId&language=en-US&sort_by=created_at.asc';

    return runAPI(favoritesList);
  }

  //POST Watchlist (calls outside of the API Handler)
  Future<String> addToFavoritesMoviesList(String? sessionId, int? accountId, int movieId, bool addRemove) async {

    if(sessionId == null|| accountId == null){
      return 'sessionId or accountId are null'; 
    }
    

    final response = await http.post(
      Uri.parse('$urlBase/account/$accountId/favorite?session_id=$sessionId&$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
          "media_type": "movie",
          "media_id": movieId,
          "favorite": addRemove
        }),
      );

      print('Request failed with status: ${response.statusCode}.');
      print('Response body: ${response.body}');

    return response.body;

  }

  /*
    Watchlist APIS
  */
  //GET Watchlist
  Future<Map<String, dynamic>> getMovieWatchlist(int? accountId, String? sessionId) async {
    final String movieWatchlistAPI =
        '$urlBase/account/$accountId/watchlist/movies?$apiKey&session_id=$sessionId&language=en-US&sort_by=created_at.asc';

    return runAPI(movieWatchlistAPI);
  }

  Future<Map<String, dynamic>> getTvWatchlist(int? accountId, String? sessionId) async {
    final String tvWatchlistAPI =
        '$urlBase/account/$accountId/watchlist/tv?$apiKey&session_id=$sessionId&language=en-US&sort_by=created_at.asc';

    return runAPI(tvWatchlistAPI);
  }
  
  //POST Watchlist (calls outside of the API Handler)
  Future<String> addToWatchlist(String? sessionId, int? accountId, int movieId, bool addRemove) async {

    if(sessionId == null|| accountId == null){
      return 'sessionId or accountId are null'; 
    }
    

    final response = await http.post(
      Uri.parse('$urlBase/account/$accountId/watchlist?session_id=$sessionId&$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
          "media_type": "movie",
          "media_id": movieId,
          "watchlist": addRemove
        }),
      );

    return response.body;

  }
  
  /*
    Recommendations APIS
  */
  //Get Recommendations
  Future<Map<String, dynamic>> getRecommendationsMoviesList(int? movieId) async {
    final String recommendations =
        '$urlBase/movie/${movieId}/recommendations?${apiKey}&language=en-US&sort_by=created_at.asc';

    return runAPI(recommendations);
  }

  /*
    Rating APIS
  */
  
  // GET Rated Movies
  Future<Map<String, dynamic>> getRatedMovies(int accountId, String sessionId, {int page = 1}) async {
    final cleanToken = accessToken?.replaceAll('access_token=', '');
    final tempApiKey = apiKey;
    final transformedApiKey = tempApiKey!.split('=').last;
    
    final String ratedMoviesAPI =
        '$urlBase/account/$accountId/rated/movies?api_key=$transformedApiKey&session_id=$sessionId&language=en-US&page=$page&sort_by=created_at.desc';

    final response = await http.get(
      Uri.parse(ratedMoviesAPI),
      headers: {
        'Authorization': 'Bearer $cleanToken',
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    print('Get Rated Movies Status: ${response.statusCode}');
    print('Get Rated Movies Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
  } else {
    throw Exception("Failed to get rated movies: ${response.body}");
  }
}

  // POST Rate Movie
  Future<Map<String, dynamic>> rateMovie({
    required int movieId,
    required double rating,
    required String sessionId,
  }) async {
    final cleanToken = accessToken?.replaceAll('access_token=', '');
    final tempApiKey = apiKey;
    final transformedApiKey = tempApiKey!.split('=').last;

    final url = '$urlBase/movie/$movieId/rating?api_key=$transformedApiKey&session_id=$sessionId';
    final uri = Uri.parse(url);

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $cleanToken',
        'Content-Type': 'application/json;charset=utf-8',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'value': rating, // must be 0.5 to 10.0
      }),
    );

    print("Rate Movie Status: ${response.statusCode}");
    print("Rate Movie Body: ${response.body}");

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to rate movie: ${response.body}");
    }
  }

  // DELETE Movie Rating
  Future<Map<String, dynamic>> deleteMovieRating({
    required int movieId,
    required String sessionId,
  }) async {
    final cleanToken = accessToken?.replaceAll('access_token=', '');
    final tempApiKey = apiKey;
    final transformedApiKey = tempApiKey!.split('=').last;

    final url = '$urlBase/movie/$movieId/rating?api_key=$transformedApiKey&session_id=$sessionId';
    final uri = Uri.parse(url);

    final response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $cleanToken',
        'Content-Type': 'application/json;charset=utf-8',
        'Accept': 'application/json',
      },
    );

    print("Delete Movie Rating Status: ${response.statusCode}");
    print("Delete Movie Rating Body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to delete movie rating: ${response.body}");
    }
  }

  

}

class TmdbAuthService {
  final String? accessToken = dotenv.env['ACCESS_TOKEN'];
  final String? apiKey = dotenv.env['API_KEY'];
  final String urlBase = 'https://api.themoviedb.org/3';

  Future<String> fetchRequestToken() async {
    final cleanToken = accessToken?.replaceAll('access_token=', '');
    final response = await http.get(
      Uri.parse('$urlBase/authentication/token/new?$apiKey'),
      headers: {
        'Authorization': 'Bearer $cleanToken',
        'Content-Type': 'application/json',
      },
    );
    final data = json.decode(response.body);
    print('$data');
    return data['request_token'];
  }

  Future<bool> validateLogin(String username, String password, String requestToken) async {
    final cleanToken = accessToken?.replaceAll('access_token=', '');
    final response = await http.post(
      Uri.parse('$urlBase/authentication/token/validate_with_login?$apiKey'),
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
    print('$data');
    return data['success'] == true;
  }

  Future<String> createSession(String validatedRequestToken) async {
    final cleanToken = accessToken?.replaceAll('access_token=', '');
    final response = await http.post(
      Uri.parse('$urlBase/authentication/session/new?$apiKey'),
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
      Uri.parse('$urlBase/account?session_id=$sessionId&$apiKey'),
      headers: {
        'Authorization': 'Bearer $cleanToken',
        'Content-Type': 'application/json',
      },
    );
    return json.decode(response.body);
  }

}