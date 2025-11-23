import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/view/home_screen.dart';
import 'package:movie_app/view_models/home_view_model.dart';
import 'package:movie_app/data/models/movie.dart';

class MockHomeViewModel extends Mock implements HomeViewModel {}

void main() {
  late MockHomeViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockHomeViewModel();

    // Default getter values
    when(() => mockViewModel.isLoading).thenReturn(false);
    when(() => mockViewModel.isPageLoading).thenReturn(false);
    when(() => mockViewModel.movies).thenReturn([]);
    when(() => mockViewModel.currentPage).thenReturn(1);
    when(() => mockViewModel.totalPages).thenReturn(1);
    when(() => mockViewModel.currentSearchQuery).thenReturn('');
    when(() => mockViewModel.currentFilters).thenReturn({});

    // Async methods
    when(() => mockViewModel.loadUpcomingMovies()).thenAnswer((_) async {});
    when(() => mockViewModel.searchMovies(any())).thenAnswer((_) async {});
    when(() => mockViewModel.applyFilters(any())).thenAnswer((_) async {});
    when(() => mockViewModel.nextPage()).thenAnswer((_) async {});
    when(() => mockViewModel.previousPage()).thenAnswer((_) async {});
    when(() => mockViewModel.clearFilters()).thenAnswer((_) async {});
    when(() => mockViewModel.clearSearch()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<HomeViewModel>.value(
      value: mockViewModel,
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  testWidgets('shows loading indicator when isLoading is true', (tester) async {
    when(() => mockViewModel.isLoading).thenReturn(true);

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows "No movies found" when list is empty', (tester) async {
    when(() => mockViewModel.movies).thenReturn([]);

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('No movies found.'), findsOneWidget);
  });

  testWidgets('shows a movie card in list mode', (tester) async {
    final movies = [
      Movie(
        id: 1,
        title: 'Test Movie',
        voteAverage: 7.5,
        releaseDate: '2024-01-01',
        overview: 'Overview',
        posterPath: '/path.jpg',
        genreIds: [12],
        originalLanguage: 'en',
      ),
    ];

    when(() => mockViewModel.movies).thenReturn(movies);
    when(() => mockViewModel.currentSearchQuery).thenReturn("Batman");
    when(() => mockViewModel.currentFilters).thenReturn({"genre": 12});

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Test Movie'), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);
  });

  testWidgets('searching calls searchMovies()', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final searchIcon = find.byIcon(Icons.search);
    await tester.tap(searchIcon);
    await tester.pump();

    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    await tester.enterText(textField, 'Avatar');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    verify(() => mockViewModel.searchMovies('Avatar')).called(1);
  });

  testWidgets('tapping next page calls nextPage()', (tester) async {
    when(() => mockViewModel.movies).thenReturn([
      Movie(
        id: 1,
        title: 'Movie',
        voteAverage: 8.0,
        releaseDate: '2023-01-01',
        overview: 'test',
        posterPath: '',
        genreIds: [],
        originalLanguage: 'en',
      )
    ]);

    when(() => mockViewModel.totalPages).thenReturn(5);

    await tester.pumpWidget(createWidgetUnderTest());

    final nextBtn = find.text('Next Page');
    expect(nextBtn, findsOneWidget);

    await tester.tap(nextBtn);
    await tester.pump();

    verify(() => mockViewModel.nextPage()).called(1);
  });
}
