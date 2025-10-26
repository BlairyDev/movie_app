import 'package:flutter/material.dart';
import 'package:movie_app/data/models/genre.dart';
import 'package:movie_app/data/models/language.dart';
import 'package:movie_app/data/models/movie.dart';
import 'package:movie_app/data/repositories/tmdb_repository.dart';

class FilterViewModel extends ChangeNotifier {
  final TmdbRepository repository;

  FilterViewModel({required this.repository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Genre> _genres = [];
  List<Genre> get genres => _genres;

  List<Language> _languages = [];
  List<Language> get languages => _languages;

  String? selectedGenre;
  String? selectedLanguage;
  double selectedRating = 0;
  int selectedYear = 0;

  List<Movie> _filteredMovies = [];
  List<Movie> get filteredMovies => _filteredMovies;

  Future<void> loadFilters() async {
    try {
      _genres = await repository.getGenres();
      _languages = await repository.getLanguages();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load filters: $e');
    }
  }

  Future<void> applyFilters({
    String? genre,
    String? language,
    double? rating,
    int? year,
    String? searchQuery,
  }) async {
    selectedGenre = genre ?? selectedGenre;
    selectedLanguage = language ?? selectedLanguage;
    selectedRating = rating ?? selectedRating;
    selectedYear = year ?? selectedYear;

    _isLoading = true;
    notifyListeners();

    try {
      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Search with filters active
        _filteredMovies = await repository.getFilteredMovies(
          title: searchQuery,
          genre: selectedGenre,
          language: selectedLanguage,
          minRating: selectedRating,
          year: selectedYear,
        );
      } else {
        // Regular discover with filters
        _filteredMovies = await repository.getFilteredMovies(
          genre: selectedGenre,
          language: selectedLanguage,
          minRating: selectedRating,
          year: selectedYear,
        );
      }
    } catch (e) {
      debugPrint('Failed to fetch filtered movies: $e');
      _filteredMovies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearFilters() {
    selectedGenre = null;
    selectedLanguage = null;
    selectedRating = 0;
    selectedYear = 0;
    notifyListeners();
  }
}
