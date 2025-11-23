import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/data/models/movie.dart';
import 'package:movie_app/view/movie_detail_screen.dart';
import 'package:movie_app/view/review_screen.dart';

void main() {
  setUpAll(() async {
    // Load dotenv before any widget is created
    await dotenv.load(fileName: '.env'); // your dummy env file
  });

  final testMovie = Movie(
    id: 1,
    title: 'Dune: Part Two',
    overview: 'Epic sci-fi sequel',
    posterPath: '/fakeposter.jpg', voteAverage: 0.0, releaseDate: '', genreIds: [], originalLanguage: '',
  );

  testWidgets('renders movie details', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MovieDetailScreen(testMovie),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Dune: Part Two'), findsNWidgets(2)); // title appears twice
    expect(find.text('Epic sci-fi sequel'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('See Reviews button navigates to ReviewScreen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MovieDetailScreen(testMovie),
      ),
    );

    await tester.pumpAndSettle();

    final reviewsButton = find.text('See Reviews');
    expect(reviewsButton, findsOneWidget);

    await tester.tap(reviewsButton);
    await tester.pumpAndSettle();

    expect(find.byType(ReviewScreen), findsOneWidget);
  });

  testWidgets('Toggle Watchlist and Favorites show SnackBar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MovieDetailScreen(testMovie),
      ),
    );

    await tester.pumpAndSettle();

    // Watchlist
    final watchlistButton = find.text('Toggle Watchlist');
    expect(watchlistButton, findsOneWidget);
    await tester.tap(watchlistButton);
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);

    // Favorites
    final favButton = find.text('Toggle Favorites');
    expect(favButton, findsOneWidget);
    await tester.tap(favButton);
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNWidgets(2)); // 2 SnackBars now
  });
}
