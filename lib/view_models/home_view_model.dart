import 'package:flutter/material.dart';
import '../data/models/movie.dart';
import '../data/repositories/tmdb_repository.dart';

class HomeViewModel extends ChangeNotifier {

  final TmdbRepository repository;

  HomeViewModel({
    required this.repository
  });

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<Movie> _movies = [];
  List<Movie> get movies => _movies;

  
  Future<void> loadUpcomingMovies() async {
    _isLoading = true;
    try {

      _movies = await repository.getUpcomingMovies();
      notifyListeners();

    } catch (e) {
      _movies = [];
      throw Exception(e);
    }
    finally {
      _isLoading = false;
    }
  }

  Future<void> loadSearchMovies(String title) async {
    _isLoading = true;
    try {

      _movies = await repository.getSearchMovies(title);
      notifyListeners();

    } catch (e) {
      _movies = [];
      throw Exception(e);
  
    } finally {
      _isLoading = false;
    }
  }

}