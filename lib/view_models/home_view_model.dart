import 'package:flutter/foundation.dart';
import 'package:movie_app/data/models/movie.dart';
import 'package:movie_app/data/repositories/tmdb_repository.dart';

class HomeViewModel extends ChangeNotifier { 
  final TmdbRepository repository; 
  
  HomeViewModel({required this.repository});
  
  bool _isLoading = true; 
  bool get isLoading => _isLoading; 

  bool _isPageLoading = false; 
  bool get isPageLoading => _isPageLoading; 

  int _currentPage = 1;
  int _totalPages = 1;
  
  List<Movie> _movies = []; 
  List<Movie> get movies => _movies; 
  
  String _currentSearchQuery = '';
  Map<String, dynamic> _currentFilters = {};

  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String get currentSearchQuery => _currentSearchQuery;
  Map<String, dynamic> get currentFilters => _currentFilters;

  Future<void> _fetchMovies({bool isUpcoming = false, bool resetPage = false}) async {
    if (resetPage) {
        _currentPage = 1;
        _movies = [];
        _isLoading = true; 
    } else {
        _isPageLoading = true;
    }
    
    notifyListeners();

    try {
      final isDefaultUpcoming = isUpcoming && _currentSearchQuery.isEmpty && _currentFilters.isEmpty;

      final pagedResult = await repository.getPagedFilteredMovies(
        page: _currentPage,
        title: _currentSearchQuery.isEmpty ? null : _currentSearchQuery, 
        filters: _currentFilters.isEmpty ? null : _currentFilters,
        isUpcoming: isDefaultUpcoming,
      );
      
      _movies = pagedResult.movies;
      _totalPages = pagedResult.totalPages;
      
    } catch (e) {
      debugPrint('Error fetching movies: $e');
      if (resetPage) _movies = [];
      _totalPages = 0; 
    } finally {
      _isLoading = false;
      _isPageLoading = false;
      notifyListeners();
    }
  }
    
  Future<void> loadUpcomingMovies() async { 
    _currentSearchQuery = '';
    _currentFilters = {};
    await _fetchMovies(isUpcoming: true, resetPage: true);
  }

  Future<void> searchMovies(String query) async {
    _currentSearchQuery = query;
    await _fetchMovies(resetPage: true);
  }

  Future<void> applyFilters(Map<String, dynamic> filters) async { 
    _currentFilters = filters; 
    await _fetchMovies(resetPage: true);
  } 


  Future<void> nextPage() async {
    if (_currentPage >= _totalPages || _isPageLoading) return;

    _currentPage++;
    await _fetchMovies(resetPage: false);
  }

  Future<void> previousPage() async {
    if (_currentPage <= 1 || _isPageLoading) return;

    _currentPage--;
    await _fetchMovies(resetPage: false);
  }
  

  void clearFilters() async {
    _currentFilters = {};
    await _fetchMovies(resetPage: true);
  }

  void clearSearch() async {
    _currentSearchQuery = '';
    await _fetchMovies(resetPage: true);
  }
}