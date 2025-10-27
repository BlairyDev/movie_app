import 'package:movie_app/data/models/movie.dart';
import 'package:movie_app/data/models/review_response.dart';
import 'package:movie_app/data/models/genre.dart';
import 'package:movie_app/data/models/language.dart';
import 'package:movie_app/data/models/paged_movies.dart';
import 'package:movie_app/data/services/tmdb_api_service.dart';
import 'tmdb_repository.dart';

class TmdbRepository {

  final TmdbApiService _service = TmdbApiService();
  
  @override
  Future<List<Movie>> getUpcomingMovies() async {
    try {
      final pagedResult = await getPagedFilteredMovies(page: 1);
      return pagedResult.movies;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<Movie>> getSearchMovies(String title) async {
    try {
      final pagedResult = await getPagedFilteredMovies(page: 1, title: title);
      return pagedResult.movies;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<ReviewResponse> getMovieReviews(int movieId, {int page = 1}) async {
    try {
      final result = await _service.fetchMovieReviews(movieId, page: page);
      return ReviewResponse.fromJson(result);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<Genre>> getGenres() async {
    final data = await _service.fetchGenres();
    final genresList = (data['genres'] as List<dynamic>).map((g) => Genre.fromJson(g)).toList();
    return genresList;
  }

  @override
  Future<List<Language>> getLanguages() async {
    final result = await _service.fetchLanguages(); 
    final List<dynamic> languageList = result['languages'];
    final languages = languageList
        .map((json) => Language.fromJson(json as Map<String, dynamic>))
        .toList();

    languages.sort((a, b) => a.englishName.compareTo(b.englishName));

    return languages;
  }

  @override
  Future<List<Movie>> getFilteredMovies({
    String? title,
    String? genre,
    String? language,
    double? minRating,
    int? year,
  }) async {
    final pagedResult = await getPagedFilteredMovies(
      page: 1,
      title: title,
      filters: {
        if (genre != null) 'genre': genre,
        if (language != null) 'language': language,
        if (minRating != null) 'rating': minRating,
        if (year != null) 'year': year,
      }
    );
    return pagedResult.movies;
  }

  @override
  Future<PagedMovies> getPagedFilteredMovies({
    required int page,
    String? title,
    Map<String, dynamic>? filters,
    bool isUpcoming = false,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
    };

    if (title != null && title.isNotEmpty) {
      final data = await _service.fetchSearchMovies(title, page: page);
      List<Movie> movies = (data['results'] as List<dynamic>).map((json) => Movie.fromJson(json)).toList();
      int totalPages = data['total_pages'] ?? 1;

      if (filters != null && filters.isNotEmpty) {
        
        final genreName = filters['genre'] as String?;
        final languageCode = filters['language'] as String?;
        final minRating = filters['rating'] as num?;
        final yearFilter = filters['year'] as dynamic; 

        final allGenres = await getGenres();

        movies = movies.where((movie) {
          bool passesFilter = true;

          if (genreName != null && genreName.isNotEmpty) {
            final targetGenre = allGenres.firstWhere(
              (g) => g.name.toLowerCase() == genreName.toLowerCase(),
              orElse: () => Genre(id: 0, name: ''),
            );
            if (targetGenre.id != 0 && !movie.genreIds.contains(targetGenre.id)) {
              passesFilter = false;
            }
          }

          if (passesFilter && languageCode != null && languageCode.isNotEmpty) {
            if (movie.originalLanguage != languageCode) {
              passesFilter = false;
            }
          }

          if (passesFilter && minRating != null && minRating > 0) {
            if (movie.voteAverage < minRating) {
              passesFilter = false;
            }
          }

          if (passesFilter && yearFilter != null && yearFilter.toString().isNotEmpty) {
              final releaseYear = int.tryParse(movie.releaseDate.split('-').first);
              final yearValue = yearFilter.toString();

              if (releaseYear == null) {
                  passesFilter = false;
              } else if (yearValue.contains('-')) {
                  final parts = yearValue.split('-');
                  final startYear = int.tryParse(parts.first);
                  final endYear = int.tryParse(parts.last);
                  if (startYear != null && endYear != null) {
                      if (releaseYear < startYear || releaseYear > endYear) {
                          passesFilter = false;
                      }
                  } else {
                      passesFilter = false;
                  }
              } else {
                  final singleYear = int.tryParse(yearValue);
                  if (singleYear != null && releaseYear != singleYear) {
                      passesFilter = false;
                  }
              }
          }

          return passesFilter;
        }).toList();
      }
      
      return PagedMovies(movies: movies, totalPages: totalPages);
      
    } else {
      String endpoint = isUpcoming ? 'movie/upcoming' : 'discover/movie';
      
      if (!isUpcoming) {
         queryParams['sort_by'] = 'popularity.desc';
      }

      if (filters != null) {
        if (filters['genre'] != null && filters['genre'].isNotEmpty) {
          final genreId = await _getGenreId(filters['genre']);
          if (genreId.isNotEmpty) queryParams['with_genres'] = genreId;
        }
        if (filters['language'] != null && filters['language'].isNotEmpty) {
          queryParams['with_original_language'] = filters['language'];
        }
        if (filters['rating'] != null && (filters['rating'] is num) && filters['rating'] > 0) {
          queryParams['vote_average.gte'] = (filters['rating'] as num).toStringAsFixed(1);
        }
        
        final yearFilter = filters['year'];
        if (yearFilter != null && yearFilter.toString().isNotEmpty) {
           final yearValue = yearFilter.toString();
           if (yearValue.contains('-')) {
             final yearParts = yearValue.split('-');
             if (yearParts.length == 2) {
                queryParams['primary_release_date.gte'] = '${yearParts[0]}-01-01';
                queryParams['primary_release_date.lte'] = '${yearParts[1]}-12-31';
             }
           } else {
              queryParams['primary_release_year'] = yearValue;
           }
        }
      }
      
      final data = await _service.fetchPagedMovies(endpoint, queryParams);
      
      final movies = (data['results'] as List<dynamic>).map((json) => Movie.fromJson(json)).toList();
      final totalPages = data['total_pages'] ?? 1;
      
      return PagedMovies(movies: movies, totalPages: totalPages);
    }
  }

  Future<String> _getGenreId(String name) async {
    final genres = await getGenres();
    final g = genres.firstWhere(
      (x) => x.name.toLowerCase() == name.toLowerCase(),
      orElse: () => Genre(id: 0, name: ''),
    );
    return g.id != 0 ? g.id.toString() : '';
  }
}
