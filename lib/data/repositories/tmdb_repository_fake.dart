import 'dart:async';
import 'package:movie_app/data/models/movie.dart';
import 'package:movie_app/data/models/review.dart';
import 'package:movie_app/data/models/review_response.dart';
import 'package:movie_app/data/models/genre.dart';
import 'package:movie_app/data/models/paged_movies.dart';
import 'package:movie_app/data/models/language.dart';
import 'package:movie_app/data/repositories/tmdb_repository.dart';

/// --- Fake static data --- ///

final List<Movie> fakeMovies = [
  Movie(
    id: 1,
    title: "The Adventure Begins",
    voteAverage: 8.2,
    releaseDate: "2023-05-12",
    overview: "An epic journey of a young hero discovering his destiny.",
    posterPath: "assets/images/adventure_begins.jpg",
    genreIds: [28, 12], // Action, Adventure
    originalLanguage: 'en',
  ),
  Movie(
    id: 2,
    title: "Mystery of the Night",
    voteAverage: 7.5,
    releaseDate: "2022-10-31",
    overview: "A thrilling mystery that keeps you on the edge of your seat.",
    posterPath: "assets/images/mystery_night.jpg",
    genreIds: [9648, 53], // Mystery, Thriller
    originalLanguage: 'en',
  ),
  Movie(
    id: 3,
    title: "Romance in Paris",
    voteAverage: 6.8,
    releaseDate: "2021-02-14",
    overview: "A heartwarming love story set in the streets of Paris.",
    posterPath: "assets/images/romance_paris.jpg",
    genreIds: [10749, 18], // Romance, Drama
    originalLanguage: 'fr',
  ),
  Movie(
    id: 4,
    title: "Space Odyssey",
    voteAverage: 9.1,
    releaseDate: "2024-07-04",
    overview: "An interstellar adventure beyond imagination.",
    posterPath: "assets/images/space_odyssey.jpg",
    genreIds: [878, 12], // Science Fiction, Adventure
    originalLanguage: 'en',
  ),
  Movie(
    id: 5,
    title: "Comedy Nights",
    voteAverage: 7.0,
    releaseDate: "2020-11-20",
    overview: "A hilarious series of comedic events and mishaps.",
    posterPath: "assets/images/comedy_nights.jpg",
    genreIds: [35], // Comedy
    originalLanguage: 'en',
  ),
];

final ReviewResponse fakeReviews = ReviewResponse(
  page: 1,
  totalPages: 1,
  totalResults: 4,
  results: [
    Review(
      author: 'john_doe',
      authorName: 'John Doe',
      authorUsername: 'johnd123',
      authorAvatarPath: '/avatar1.jpg',
      rating: 8.5,
      content: 'Amazing movie! Highly recommended for all sci-fi fans.',
      createdAt: '2025-09-27T12:34:56.000Z',
      updatedAt: '2025-09-27T13:00:00.000Z',
      url: 'https://www.themoviedb.org/review/1',
      reviewID: '1',
    ),
    Review(
      author: 'jane_smith',
      authorName: 'Jane Smith',
      authorUsername: 'janes456',
      authorAvatarPath: '/avatar2.jpg',
      rating: 7.0,
      content: 'Good story but pacing felt a bit slow at times.',
      createdAt: '2025-09-26T15:20:00.000Z',
      updatedAt: '2025-09-26T15:45:00.000Z',
      url: 'https://www.themoviedb.org/review/2',
      reviewID: '2',
    ),
    Review(
      author: 'movie_buff99',
      authorName: 'Movie Buff',
      authorUsername: 'buff99',
      authorAvatarPath: '/avatar3.jpg',
      rating: 9.0,
      content: 'One of the best films I\'ve seen this year!',
      createdAt: '2025-09-25T09:10:00.000Z',
      updatedAt: '2025-09-25T09:50:00.000Z',
      url: 'https://www.themoviedb.org/review/3',
      reviewID: '3',
    ),
    Review(
      author: 'critic_pro',
      authorName: 'Critic Pro',
      authorUsername: 'criticPro',
      authorAvatarPath: '/avatar4.jpg',
      rating: 6.5,
      content: 'Interesting concepts but lacks character depth.',
      createdAt: '2025-09-24T20:00:00.000Z',
      updatedAt: '2025-09-24T20:30:00.000Z',
      url: 'https://www.themoviedb.org/review/4',
      reviewID: '4',
    ),
  ],
);

final List<Genre> fakeGenres = [
  Genre(id: 28, name: 'Action'),
  Genre(id: 12, name: 'Adventure'),
  Genre(id: 35, name: 'Comedy'),
  Genre(id: 18, name: 'Drama'),
  Genre(id: 878, name: 'Science Fiction'),
  Genre(id: 10749, name: 'Romance'),
];

final List<Language> fakeLanguages = [
  Language(isoCode: 'en', englishName: 'English'),
  Language(isoCode: 'fr', englishName: 'French'),
  Language(isoCode: 'es', englishName: 'Spanish'),
  Language(isoCode: 'ja', englishName: 'Japanese'),
  Language(isoCode: 'de', englishName: 'German'),
];

/// --- Fake Repository Implementation --- ///

class TmdbRepositoryFake implements TmdbRepository {
  @override
  Future<List<Movie>> getUpcomingMovies() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return fakeMovies;
  }

  @override
  Future<List<Movie>> getSearchMovies(String title) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return fakeMovies
        .where((m) => m.title.toLowerCase().contains(title.toLowerCase()))
        .toList();
  }

  @override
  Future<ReviewResponse> getMovieReviews(int movieId, {int page = 1}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return fakeReviews;
  }

  @override
  Future<List<Movie>> getFilteredMovies({
    String? title,
    String? genre,
    String? language,
    double? minRating,
    int? year,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return fakeMovies.where((m) {
      final genreMatch = genre == null ||
          genre.isEmpty ||
          fakeGenres.any((g) => g.name == genre);
      final langMatch = language == null ||
          language.isEmpty ||
          fakeLanguages.any((l) => l.isoCode == language);
      final ratingMatch = minRating == null || m.voteAverage >= minRating;
      final yearMatch =
          year == null || m.releaseDate.startsWith(year.toString());
      return genreMatch && langMatch && ratingMatch && yearMatch;
    }).toList();
  }

  @override
  Future<PagedMovies> getPagedFilteredMovies({
    required int page,
    String? title,
    Map<String, dynamic>? filters,
    bool isUpcoming = false,
  }) async {
    final filtered = await getFilteredMovies(
      title: title,
      genre: filters?['genre'],
      language: filters?['language'],
      minRating: filters?['minRating'],
      year: filters?['year'],
    );

    // simulate basic pagination (e.g., 10 movies per page)
    const pageSize = 10;
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;
    final pagedMovies = filtered.sublist(
      startIndex < filtered.length ? startIndex : filtered.length,
      endIndex < filtered.length ? endIndex : filtered.length,
    );

    final totalPages = (filtered.length / pageSize).ceil().clamp(1, double.infinity).toInt();

    return PagedMovies(
      movies: pagedMovies,
      totalPages: totalPages,
    );
  }

  @override
  Future<List<Genre>> getGenres() async => fakeGenres;

  @override
  Future<List<Language>> getLanguages() async => fakeLanguages;
}
