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
}
