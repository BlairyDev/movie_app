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

  List<Movie> _watchlistTv = [];
  List<Movie> get watchlistTv => _watchlistTv;

  Future<void> loadWatchlistMovies() async {
    _isLoading = true;
    notifyListeners();

    try {
      final accountId = SessionManager().accountId;
      final sessionId = SessionManager().sessionId;

      if (accountId != null && sessionId != null) {
        final response = await apiService.getMovieWatchlist(accountId, sessionId);
        final results = response['results'] as List<dynamic>;
        _watchlistMovies = results.map((json) => Movie.fromJson(json)).toList();
      } else {
        _watchlistMovies = [];
      }
    } catch (e) {
      _watchlistMovies = [];
      print('Error fetching movie watchlist: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWatchlistTv() async {
    _isLoading = true;
    notifyListeners();

    try {
      final accountId = SessionManager().accountId;
      final sessionId = SessionManager().sessionId;

      if (accountId != null && sessionId != null) {
        final response = await apiService.getTvWatchlist(accountId, sessionId);
        final results = response['results'] as List<dynamic>;

        _watchlistTv = results
          .map((json) => Movie(
                id: json['id'] as int,
                title: json['name'] as String? ?? '',
                voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
                releaseDate: json['first_air_date'] as String? ?? '',
                overview: json['overview'] as String? ?? '',
                posterPath: json['poster_path'] as String? ?? '',
                genreIds: List<int>.from(json['genre_ids'] ?? []),
                originalLanguage: json['original_language'] as String? ?? 'en',
              ))
          .toList();
      } else {
        _watchlistTv = [];
      }
    } catch (e) {
      _watchlistTv = [];
      print('Error fetching TV watchlist: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
