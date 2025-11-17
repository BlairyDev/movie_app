// ---- Mock Repository ----
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/data/models/genre.dart';
import 'package:movie_app/data/models/language.dart';
import 'package:movie_app/data/models/movie.dart';
import 'package:movie_app/data/repositories/tmdb_repository.dart';
import 'package:movie_app/view_models/filter_view_model.dart';

class MockTmdbRepository extends Mock implements TmdbRepository {}

void main() {
  late MockTmdbRepository mockRepository;
  late FilterViewModel viewModel;

  setUp(() {
    mockRepository = MockTmdbRepository();
    viewModel = FilterViewModel(repository: mockRepository);
  });

  // ---- Test loadFilters ----
  test('loadFilters loads genres and languages', () async {
    // Arrange
    final mockGenres = [Genre(id: 1, name: 'Action')];
    final mockLanguages = [Language(isoCode: 'en', englishName: 'English')];

    when(() => mockRepository.getGenres()).thenAnswer((_) async => mockGenres);
    when(() => mockRepository.getLanguages()).thenAnswer((_) async => mockLanguages);

    // Act
    await viewModel.loadFilters();

    // Assert
    verify(() => mockRepository.getGenres()).called(1);
    verify(() => mockRepository.getLanguages()).called(1);

    expect(viewModel.genres, mockGenres);
    expect(viewModel.languages, mockLanguages);
  });

  // ---- Test applyFilters ----
  test('applyFilters fetches filtered movies', () async {
    // Arrange
    final filteredMovies = [
      Movie(
        id: 1,
        title: 'Test Movie',
        voteAverage: 8.0,
        releaseDate: '2024-01-01',
        overview: 'Overview',
        posterPath: '/poster.jpg',
        genreIds: [1],
        originalLanguage: 'en',
      )
    ];

    when(() => mockRepository.getFilteredMovies(
          genre: any(named: 'genre'),
          language: any(named: 'language'),
          minRating: any(named: 'minRating'),
          year: any(named: 'year'),
          title: any(named: 'title'),
        )).thenAnswer((_) async => filteredMovies);

    // Act
    await viewModel.applyFilters(
      genre: 'Action',
      language: 'en',
      rating: 7.0,
      year: 2024,
      searchQuery: 'Test',
    );

    // Assert
    verify(() => mockRepository.getFilteredMovies(
          genre: 'Action',
          language: 'en',
          minRating: 7.0,
          year: 2024,
          title: 'Test',
        )).called(1);

    expect(viewModel.filteredMovies, filteredMovies);
    expect(viewModel.selectedGenre, 'Action');
    expect(viewModel.selectedLanguage, 'en');
    expect(viewModel.selectedRating, 7.0);
    expect(viewModel.selectedYear, 2024);
  });

  // ---- Test clearFilters ----
  test('clearFilters resets selections', () {
    // Arrange
    viewModel.selectedGenre = 'Action';
    viewModel.selectedLanguage = 'en';
    viewModel.selectedRating = 7.0;
    viewModel.selectedYear = 2024;

    // Act
    viewModel.clearFilters();

    // Assert
    expect(viewModel.selectedGenre, isNull);
    expect(viewModel.selectedLanguage, isNull);
    expect(viewModel.selectedRating, 0);
    expect(viewModel.selectedYear, 0);
  });
}