import 'package:movie_app/data/models/movie.dart';
import 'package:movie_app/data/repositories/tmdb_repository.dart';


List<Movie> fakeMovies = [
    Movie(
      id: 1,
      title: "The Adventure Begins",
      voteAverage: 8.2,
      releaseDate: "2023-05-12",
      overview: "An epic journey of a young hero discovering his destiny.",
      posterPath: "assets/images/adventure_begins.jpg",
    ),
    Movie(
      id: 2,
      title: "Mystery of the Night",
      voteAverage: 7.5,
      releaseDate: "2022-10-31",
      overview: "A thrilling mystery that keeps you on the edge of your seat.",
      posterPath: "assets/images/mystery_night.jpg",
    ),
    Movie(
      id: 3,
      title: "Romance in Paris",
      voteAverage: 6.8,
      releaseDate: "2021-02-14",
      overview: "A heartwarming love story set in the streets of Paris.",
      posterPath: "assets/images/romance_paris.jpg",
    ),
    Movie(
      id: 4,
      title: "Space Odyssey",
      voteAverage: 9.1,
      releaseDate: "2024-07-04",
      overview: "An interstellar adventure beyond imagination.",
      posterPath: "assets/images/space_odyssey.jpg",
    ),
    Movie(
      id: 5,
      title: "Comedy Nights",
      voteAverage: 7.0,
      releaseDate: "2020-11-20",
      overview: "A hilarious series of comedic events and mishaps.",
      posterPath: "assets/images/comedy_nights.jpg",
    ),
];

class TmdbRepositoryFake implements TmdbRepository {
  @override
  Future<List<Movie>> getUpcomingMovies() async {

    await Future.delayed(Duration(seconds: 4));
    return fakeMovies;
  }

  @override
  Future<List<Movie>> getSearchMovies(String title) async {
    await Future.delayed(Duration(seconds: 4));
    return fakeMovies;
  }

}