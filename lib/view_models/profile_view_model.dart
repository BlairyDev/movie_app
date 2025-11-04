import 'package:flutter/material.dart';
import '../data/models/movie.dart';
import '../data/models/profile.dart';
import '../data/services/tmdb_api_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final TmdbApiService apiService;

  ProfileViewModel({required this.apiService});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Movie> _watchlistMovies = [];
  List<Movie> get watchlistMovies => _watchlistMovies;

  List<dynamic> _watchlistTv = [];
  List<dynamic> get tvWatchlist => _watchlistTv;

  String? _error;
  String? get error => _error;

  Future<void> loadWatchlistMovies() async {
    final sessionManager = SessionManager();
    
    if (sessionManager.sessionId == null || sessionManager.accountId == null) {
      _error = 'No active session found';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiService.fetchMovieWatchlist(
        sessionManager.accountId!,
        sessionManager.sessionId!,
      );

      print('Movie Watchlist Response: $response');

      if (response['results'] != null) {
        _watchlistMovies = (response['results'] as List)
            .map((json) => Movie.fromJson(json))
            .toList();
        
        print('Loaded ${_watchlistMovies.length} movies in watchlist');
      } else {
        _watchlistMovies = [];
      }
    } catch (e) {
      _error = 'Failed to load movie watchlist: $e';
      print('Error loading movie watchlist: $e');
      _watchlistMovies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWatchlistTv() async {
    final sessionManager = SessionManager();
    
    if (sessionManager.sessionId == null || sessionManager.accountId == null) {
      _error = 'No active session found';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiService.fetchTvWatchlist(
        sessionManager.accountId!,
        sessionManager.sessionId!,
      );

      print('TV Watchlist Response: $response');

      if (response['results'] != null) {
        _watchlistTv = response['results'] as List;
        print('Loaded ${_watchlistTv.length} TV shows in watchlist');
      } else {
        _watchlistTv = [];
      }
    } catch (e) {
      _error = 'Failed to load TV watchlist: $e';
      print('Error loading TV watchlist: $e');
      _watchlistTv = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearWatchlists() {
    _watchlistMovies = [];
    _watchlistTv = [];
    _error = null;
    notifyListeners();
  }

  //Favorites
  List<Movie> _favoritesMovies = [];
  List<Movie> get favoritesMovies => _favoritesMovies;

  List<Movie> _favoritesTV = [];
  List<Movie> get favoritesTV => _favoritesTV;

  Future<void> loadFavoritesMovies() async {
    _isLoading = true;
    notifyListeners();

    try {
      final accountId = SessionManager().accountId;
      final sessionId = SessionManager().sessionId;

      if (accountId != null && sessionId != null) {
        final response = await apiService.getFavoritesMoviesList(accountId, sessionId);
        final results = response['results'] as List<dynamic>;
        _favoritesMovies = results.map((json) => Movie.fromJson(json)).toList();
      } else {
        _favoritesMovies = [];
      }
    } catch (e) {
      _favoritesMovies = [];
      print('Error fetching movie watchlist: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> loadFavoritesTV() async {
    _isLoading = true;
    notifyListeners();

    try {
      final accountId = SessionManager().accountId;
      final sessionId = SessionManager().sessionId;

      if (accountId != null && sessionId != null) {
        final response = await apiService.getFavoritesTVList(accountId, sessionId);

        _favoritesTV = (response['results'] as List)
            .map((json) => Movie.fromJson(json))
            .toList();
      } else {
        _favoritesTV = [];
      }
    } catch (e) {
      _favoritesTV = [];
      print('Error fetching TV watchlist: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
