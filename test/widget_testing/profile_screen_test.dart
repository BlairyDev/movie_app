import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/view/profile_screen.dart';
import 'package:movie_app/view_models/profile_view_model.dart';
import 'package:movie_app/data/models/movie.dart';

// Create a mock ViewModel
class MockProfileViewModel extends Mock implements ProfileViewModel {}

void main() {
  late MockProfileViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockProfileViewModel();

    // Default properties
    when(() => mockViewModel.isLoading).thenReturn(false);
    when(() => mockViewModel.watchlistMovies).thenReturn([]);
    when(() => mockViewModel.tvWatchlist).thenReturn([]);
    when(() => mockViewModel.favoritesMovies).thenReturn([]);
    when(() => mockViewModel.favoritesTV).thenReturn([]);
    when(() => mockViewModel.recommendedMovies).thenReturn([]);
    when(() => mockViewModel.error).thenReturn(null);

    // Async methods
    when(() => mockViewModel.loadWatchlistMovies()).thenAnswer((_) async {});
    when(() => mockViewModel.loadFavoritesMovies()).thenAnswer((_) async {});
    when(() => mockViewModel.loadRecommendations()).thenAnswer((_) async {});
    when(() => mockViewModel.loadWatchlistTv()).thenAnswer((_) async {});
    when(() => mockViewModel.clearWatchlists()).thenReturn(null);
  });

  testWidgets('shows loading indicator when isLoading is true', (tester) async {
    when(() => mockViewModel.isLoading).thenReturn(true);

    await tester.pumpWidget(
      ChangeNotifierProvider<ProfileViewModel>.value(
        value: mockViewModel,
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('shows empty watchlist message', (tester) async {
    when(() => mockViewModel.isLoading).thenReturn(false);
    when(() => mockViewModel.watchlistMovies).thenReturn([]);

    await tester.pumpWidget(
      ChangeNotifierProvider<ProfileViewModel>.value(
        value: mockViewModel,
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    expect(find.text('No movies in your watchlist'), findsOneWidget);
  });

  testWidgets('tap subnav button calls loadWatchlistTv', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<ProfileViewModel>.value(
        value: mockViewModel,
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    final tvButton = find.text('TV Shows').first;
    await tester.tap(tvButton);
    await tester.pump();

    verify(() => mockViewModel.loadWatchlistTv()).called(1);
  });

  testWidgets('tap logout calls clearWatchlists', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<ProfileViewModel>.value(
        value: mockViewModel,
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    final logoutButton = find.byIcon(Icons.account_circle);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    verify(() => mockViewModel.clearWatchlists()).called(1);
  });

  testWidgets('shows movie card when watchlist has movies', (tester) async {
    final movies = [
      Movie(
        id: 1,
        title: 'Test Movie',
        voteAverage: 8.5,
        releaseDate: '2025-01-01',
        overview: 'Overview',
        posterPath: '/path.jpg',
        genreIds: [1, 2],
        originalLanguage: 'en',
      ),
    ];

    when(() => mockViewModel.watchlistMovies).thenReturn(movies);

    await tester.pumpWidget(
      ChangeNotifierProvider<ProfileViewModel>.value(
        value: mockViewModel,
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    expect(find.text('Test Movie'), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);
  });
}
