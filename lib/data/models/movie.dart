class Movie {
  late int id;
  late String title;
  late double voteAverage;
  late String releaseDate;
  late String overview;
  late String posterPath;
  late List<int> genreIds; // TMDb genre IDs
  late String originalLanguage; // ISO language code

  Movie({
    required this.id,
    required this.title,
    required this.voteAverage,
    required this.releaseDate,
    required this.overview,
    required this.posterPath,
    required this.genreIds,
    required this.originalLanguage,
  });

  Movie.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'] as int;
    title = parsedJson['title'] as String? ?? '';
    voteAverage = (parsedJson['vote_average'] as num?)?.toDouble() ?? 0.0;
    releaseDate = parsedJson['release_date'] as String? ?? '';
    overview = parsedJson['overview'] as String? ?? '';
    posterPath = parsedJson['poster_path'] as String? ?? '';
    genreIds = (parsedJson['genre_ids'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList() ??
        [];
    originalLanguage = parsedJson['original_language'] as String? ?? '';
  }
}
