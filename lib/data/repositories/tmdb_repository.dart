import '../models/movie.dart';

abstract class TmdbRepository {
  Future<List<Movie>> getUpcomingMovies();
  Future<List<Movie>> getSearchMovies(String title);
}