import '../models/movie.dart';
import '../models/review_response.dart';
import '../models/genre.dart';
import '../models/language.dart';
import '../models/paged_movies.dart';

abstract class TmdbRepository {
  Future<List<Movie>> getUpcomingMovies();
  Future<List<Movie>> getSearchMovies(String title);
  Future<ReviewResponse> getMovieReviews(int movieId, {int page});
  Future<List<Genre>> getGenres();
  Future<List<Language>> getLanguages();
  Future<List<Movie>> getFilteredMovies({String? genre, String? language, double? minRating, int? year, String? title,});
  Future<PagedMovies> getPagedFilteredMovies({required int page, String? title, Map<String, dynamic>? filters, bool isUpcoming,});
}