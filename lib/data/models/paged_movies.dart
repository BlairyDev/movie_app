import '../models/movie.dart';

class PagedMovies {
  final List<Movie> movies;
  final int totalPages;
  PagedMovies({required this.movies, required this.totalPages});
}
