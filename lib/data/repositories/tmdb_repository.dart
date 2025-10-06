import '../models/movie.dart';
import '../models/review_response.dart';

abstract class TmdbRepository {
  Future<List<Movie>> getUpcomingMovies();
  Future<List<Movie>> getSearchMovies(String title);
  Future<ReviewResponse> getMovieReviews(int movieId, {int page});
}