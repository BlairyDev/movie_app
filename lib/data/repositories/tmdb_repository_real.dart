import 'package:movie_app/data/models/movie.dart';
import 'package:movie_app/data/services/tmdb_api_service.dart';

import 'tmdb_repository.dart';

class TmdbRepositoryReal implements TmdbRepository {

  final TmdbApiService _service = TmdbApiService();
  
  @override
  Future<List<Movie>> getUpcomingMovies() async {
    try {

      final result = await _service.fetchUpcomingMovies();
      final moviesMap = result['results'];
      
      List<Movie> movies = moviesMap.map<Movie>((i) => Movie.fromJson(i)).toList();
      return movies;


    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<Movie>> getSearchMovies(String title) async {
    try {
      final result = await _service.fetchSearchMovies(title);
      final moviesMap = result['results'];

      List<Movie> movies = moviesMap.map<Movie>((i) => Movie.fromJson(i)).toList();
      return movies;

    } catch (e) {
      throw Exception(e);
    }
  }




}
