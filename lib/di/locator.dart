import 'package:get_it/get_it.dart';
import 'package:movie_app/data/repositories/tmdb_repository.dart';
import 'package:movie_app/data/repositories/tmdb_repository_fake.dart' show TmdbRepositoryFake;
import 'package:movie_app/data/repositories/tmdb_repository_real.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerFactory<TmdbRepository>(
    () => TmdbRepositoryReal()
  );
}