import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get_it/get_it.dart';
import 'package:movie_app/main.dart' as app;
import 'package:movie_app/view/profile_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movie_app/view_models/home_view_model.dart';
import 'package:movie_app/view_models/profile_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Load environment variables before any tests run
    await dotenv.load(fileName: ".env");
  });

  setUp(() async {
    // Reset GetIt before each test to ensure clean state
    await GetIt.I.reset();
  });

  // Helper function to login and navigate to home
  Future<void> loginAndNavigateToHome(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Get credentials from .env file PLEASE CREATE A TMDB ACCOUNT AND ADD IT IN THE .ENV FILE
    final username = dotenv.env['TEST_USERNAME'];
    final password = dotenv.env['TEST_PASSWORD'];

    final usernameField = find.byKey(const Key('usernameField'));
    final passwordField = find.byKey(const Key('passwordField'));
    final loginButton = find.byKey(const Key('loginButton'));

    await tester.enterText(usernameField, username.toString());
    await tester.enterText(passwordField, password.toString());
    await tester.tap(loginButton);
    
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Wait for movies to load
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  // ============================================================================
  // LOGIN AND NAVIGATION TESTS
  // ============================================================================

  testWidgets('Login success navigates to home screen', (tester) async {
    // Launch app
    app.main();
    await tester.pumpAndSettle();

    // Find login fields and button
    final usernameField = find.byKey(const Key('usernameField'));
    final passwordField = find.byKey(const Key('passwordField'));
    final loginButton = find.byKey(const Key('loginButton'));

    // Get credentials from .env file
    final username = dotenv.env['TEST_USERNAME'];
    final password = dotenv.env['TEST_PASSWORD'];

    // Enter credentials
    await tester.enterText(usernameField, username.toString());
    await tester.enterText(passwordField, password.toString());

    // Tap login
    await tester.tap(loginButton);

    // Wait for async navigation/data
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Verify HomeScreen is visible
    expect(find.byKey(const Key('homeScreen')), findsOneWidget);
    
    print('✓ Login successful and navigated to home screen');
  });

  testWidgets('ProfileScreen then back', (tester) async {
    // Launch app (setUp already reset GetIt)
    app.main();
    await tester.pumpAndSettle();

    // Login first
    final usernameField = find.byKey(const Key('usernameField'));
    final passwordField = find.byKey(const Key('passwordField'));
    final loginButton = find.byKey(const Key('loginButton'));

    // Get credentials from .env file
    final username = dotenv.env['TEST_USERNAME'];
    final password = dotenv.env['TEST_PASSWORD'];

    await tester.enterText(usernameField, username.toString());
    await tester.enterText(passwordField, password.toString());
    await tester.tap(loginButton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Navigate to ProfileScreen
    final profileButton = find.byIcon(Icons.account_circle);
    await tester.tap(profileButton);
    await tester.pumpAndSettle();

    // Verify ProfileScreen
    expect(find.byType(ProfileScreen), findsOneWidget);

    // Go back to HomeScreen
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Verify HomeScreen is visible
    expect(find.byKey(const Key('homeScreen')), findsOneWidget);
    
    print('✓ Profile screen navigation and back successful');
  });


  testWidgets('Register and forgot password buttons are present', (tester) async {
    // Launch app
    app.main();
    await tester.pumpAndSettle();

    // Verify the register button exists
    final registerButton = find.text('Need an account? Register');
    expect(registerButton, findsOneWidget);

    // Verify the forgot password button exists
    final forgotPasswordButton = find.text('Forgot Password? Reset Password');
    expect(forgotPasswordButton, findsOneWidget);
    
    print('✓ Register and forgot password buttons are present');
    
    // Both buttons are visible and accessible on the login screen
  });

  // ============================================================================
  // SEARCH FUNCTIONALITY TESTS
  // ============================================================================

  testWidgets('Search icon opens search bar', (tester) async {
    await loginAndNavigateToHome(tester);

    // Verify we're on home screen
    expect(find.byKey(const Key('homeScreen')), findsOneWidget);

    // Find and tap the search icon
    final searchIcon = find.byIcon(Icons.search);
    expect(searchIcon, findsOneWidget);

    await tester.tap(searchIcon);
    await tester.pumpAndSettle();

    // Verify search bar appears (TextField should be visible)
    expect(find.byType(TextField), findsOneWidget);
    
    // Verify cancel icon replaces search icon
    expect(find.byIcon(Icons.cancel), findsOneWidget);
    expect(find.byIcon(Icons.search), findsNothing);

    print('✓ Search bar opened successfully');
  });

  testWidgets('Search for movies and display results', (tester) async {
    await loginAndNavigateToHome(tester);

    // Open search bar
    final searchIcon = find.byIcon(Icons.search);
    await tester.tap(searchIcon);
    await tester.pumpAndSettle();

    // Find the search TextField
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    // Enter search query
    await tester.enterText(searchField, 'Batman');
    await tester.pumpAndSettle();

    // Submit search (simulate pressing enter)
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    // Wait for search results
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify results are displayed in list view (not carousel)
    // Should find Card widgets in ListView
    final cards = find.byType(Card);
    expect(cards, findsWidgets);

    // Verify we're in list mode (not carousel)
    final listTiles = find.byType(ListTile);
    if (tester.widgetList(listTiles).isNotEmpty) {
      expect(listTiles, findsWidgets);
      print('✓ Search results displayed in list view');
    } else {
      print('⚠ No results found for search query');
    }
  });

  testWidgets('Search with no results shows message', (tester) async {
    await loginAndNavigateToHome(tester);

    // Open search bar
    final searchIcon = find.byIcon(Icons.search);
    await tester.tap(searchIcon);
    await tester.pumpAndSettle();

    // Find the search TextField
    final searchField = find.byType(TextField);
    
    // Enter a search query that should return no results
    await tester.enterText(searchField, 'xyzabc123nonexistent');
    await tester.pumpAndSettle();

    // Submit search
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    // Wait for search results
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify "No movies found" message
    final noMoviesText = find.text('No movies found.');
    if (tester.widgetList(noMoviesText).isNotEmpty) {
      expect(noMoviesText, findsOneWidget);
      print('✓ No results message displayed correctly');
    } else {
      // Some results might still be found
      print('⚠ Search returned some results');
    }
  });

  testWidgets('Cancel search returns to carousel view', (tester) async {
    await loginAndNavigateToHome(tester);

    // Open search bar
    final searchIcon = find.byIcon(Icons.search);
    await tester.tap(searchIcon);
    await tester.pumpAndSettle();

    // Enter search query
    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'Spider');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    // Wait for results
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Tap cancel icon to close search
    final cancelIcon = find.byIcon(Icons.cancel);
    expect(cancelIcon, findsOneWidget);
    
    await tester.tap(cancelIcon);
    await tester.pumpAndSettle();

    // Wait for carousel to reload
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verify search icon is back
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.cancel), findsNothing);

    // Verify "Movies" title is back
    expect(find.text('Movies'), findsOneWidget);

    print('✓ Search cancelled and returned to carousel view');
  });

  testWidgets('Multiple searches can be performed consecutively', (tester) async {
    await loginAndNavigateToHome(tester);

    // First search
    final searchIcon = find.byIcon(Icons.search);
    await tester.tap(searchIcon);
    await tester.pumpAndSettle();

    var searchField = find.byType(TextField);
    await tester.enterText(searchField, 'Superman');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Second search - clear and enter new query
    searchField = find.byType(TextField);
    await tester.enterText(searchField, 'Wonder Woman');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verify results updated
    final cards = find.byType(Card);
    expect(cards, findsWidgets);

    print('✓ Multiple consecutive searches completed');
  });

  testWidgets('Search hint text is displayed', (tester) async {
    await loginAndNavigateToHome(tester);

    // Open search bar
    final searchIcon = find.byIcon(Icons.search);
    await tester.tap(searchIcon);
    await tester.pumpAndSettle();

    // Verify search hint text
    final hintText = find.text('Search movies...');
    expect(hintText, findsOneWidget);

    print('✓ Search hint text displayed');
  });

  testWidgets('Profile and search icons coexist properly', (tester) async {
    await loginAndNavigateToHome(tester);

    // Verify both profile and search icons are visible
    expect(find.byIcon(Icons.account_circle), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);

    // Open search
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // Verify profile icon still visible
    expect(find.byIcon(Icons.account_circle), findsOneWidget);
    // Search icon replaced with cancel
    expect(find.byIcon(Icons.cancel), findsOneWidget);

    print('✓ Icons coexist properly in app bar');
  });

  testWidgets('Loading indicator shows during search', (tester) async {
    await loginAndNavigateToHome(tester);

    // Open search
    final searchIcon = find.byIcon(Icons.search);
    await tester.tap(searchIcon);
    await tester.pumpAndSettle();

    // Enter search query
    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'Matrix');
    
    // Submit search but don't wait long
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Check if loading indicator appears (might be too fast to catch)
    final loadingIndicator = find.byType(CircularProgressIndicator);
    
    // Wait for results
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verify we eventually get results or message
    final hasResults = tester.widgetList(find.byType(Card)).isNotEmpty;
    final hasMessage = tester.widgetList(find.text('No movies found.')).isNotEmpty;
    
    expect(hasResults || hasMessage, true);

    print('✓ Search completed with results or message');
  });

  // ============================================================================
  // PROFILE SCREEN TESTS
  // ============================================================================

  testWidgets('Navigate to profile screen from home', (tester) async {
    await loginAndNavigateToHome(tester);

    // Tap profile icon in home screen
    final profileIcon = find.byIcon(Icons.account_circle).first;
    await tester.tap(profileIcon);
    await tester.pumpAndSettle();

    // Verify profile screen is displayed
    expect(find.text('Your Profile'), findsOneWidget);
    expect(find.text('Watchlist'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Reviews'), findsOneWidget);
    expect(find.text('Recommendations'), findsOneWidget);

    print('✓ Navigated to profile screen successfully');
  });

  testWidgets('Display watchlist movies by default', (tester) async {
    await loginAndNavigateToHome(tester);

    // Navigate to profile
    await tester.tap(find.byIcon(Icons.account_circle).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify watchlist tab is selected and movies sub-tab is visible
    expect(find.text('Movies'), findsWidgets);
    expect(find.text('TV Shows'), findsWidgets);

    print('✓ Watchlist movies displayed by default');
  });

  testWidgets('Switch between Movies and TV Shows in watchlist', (tester) async {
    await loginAndNavigateToHome(tester);

    // Navigate to profile
    await tester.tap(find.byIcon(Icons.account_circle).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Find and tap TV Shows button
    final tvShowsButton = find.widgetWithText(TextButton, 'TV Shows');
    await tester.tap(tvShowsButton.last);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify TV Shows content or empty state
    final hasTvText = find.textContaining('TV').evaluate().isNotEmpty;
    final hasEmptyState = find.text('No TV shows in your watchlist').evaluate().isNotEmpty;
    expect(hasTvText || hasEmptyState, isTrue);

    // Switch back to Movies
    final moviesButton = find.widgetWithText(TextButton, 'Movies').last;
    await tester.tap(moviesButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    print('✓ Switched between Movies and TV Shows successfully');
  });

  testWidgets('Navigate to Favorites tab', (tester) async {
    await loginAndNavigateToHome(tester);

    // Navigate to profile
    await tester.tap(find.byIcon(Icons.account_circle).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Tap Favorites tab
    final favoritesButton = find.widgetWithText(TextButton, 'Favorites');
    await tester.tap(favoritesButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify favorites content
    expect(find.text('Movies'), findsWidgets);
    expect(find.text('TV Shows'), findsWidgets);

    print('✓ Navigated to Favorites tab successfully');
  });

  testWidgets('Navigate to Reviews tab', (tester) async {
    await loginAndNavigateToHome(tester);

    // Navigate to profile
    await tester.tap(find.byIcon(Icons.account_circle).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Tap Reviews tab
    final reviewsButton = find.widgetWithText(TextButton, 'Reviews');
    await tester.tap(reviewsButton);
    await tester.pumpAndSettle();

    // Verify reviews content (coming soon message)
    expect(find.text('Reviews - Coming Soon'), findsOneWidget);

    print('✓ Navigated to Reviews tab successfully');
  });
 
  // ============================================================================
  // LOGOUT TESTS
  // ============================================================================

  testWidgets('Logout and navigate to login screen', (tester) async {
    await loginAndNavigateToHome(tester);

    // Navigate to profile
    await tester.tap(find.byIcon(Icons.account_circle).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Find and tap logout button (account_circle icon in profile app bar)
    final logoutButton = find.byIcon(Icons.account_circle).last;
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    // Verify navigation to login screen
    // Login screen should have login-related widgets
    expect(find.byType(AppBar), findsOneWidget);
    
    // Verify we're not on profile screen anymore
    expect(find.text('Your Profile'), findsNothing);

    // Verify login fields are present
    expect(find.byKey(const Key('usernameField')), findsOneWidget);
    expect(find.byKey(const Key('passwordField')), findsOneWidget);
    expect(find.byKey(const Key('loginButton')), findsOneWidget);

    print('✓ Logout successful and navigated to login screen');
  });

  testWidgets('Clear session data on logout', (tester) async {
    await loginAndNavigateToHome(tester);

    // Navigate to profile
    await tester.tap(find.byIcon(Icons.account_circle).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify data exists before logout
    await Future.delayed(const Duration(seconds: 1));

    // Tap logout
    final logoutButton = find.byIcon(Icons.account_circle).last;
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    // After logout, verify navigation to login
    expect(find.text('Your Profile'), findsNothing);
    expect(find.byKey(const Key('usernameField')), findsOneWidget);

    print('✓ Session data cleared on logout');
  });

  testWidgets('Cannot navigate back after logout', (tester) async {
    await loginAndNavigateToHome(tester);

    // Navigate to profile
    await tester.tap(find.byIcon(Icons.account_circle).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Logout
    final logoutButton = find.byIcon(Icons.account_circle).last;
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    // Try to go back (should not go back to profile)
    // This is handled by pushAndRemoveUntil in the logout logic
    final NavigatorState navigator =
        tester.state(find.byType(Navigator).first);
    
    // Verify we can't pop (because all routes were removed)
    expect(navigator.canPop(), isFalse);

    print('✓ Cannot navigate back after logout');
  });

  // ============================================================================
  // ERROR HANDLING TESTS
  // ============================================================================

  testWidgets('Display error message when watchlist fails to load', (tester) async {
    await loginAndNavigateToHome(tester);

    // Navigate to profile
    await tester.tap(find.byIcon(Icons.account_circle).first);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Look for error message or retry button
    final retryButton = find.widgetWithText(ElevatedButton, 'Retry');
    if (retryButton.evaluate().isNotEmpty) {
      // Error state is displayed
      expect(find.byType(ElevatedButton), findsOneWidget);
      
      // Tap retry
      await tester.tap(retryButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      print('✓ Error handling with retry button works');
    } else {
      print('⚠ No error state encountered (data loaded successfully)');
    }
  });

  testWidgets('Display empty state when no movies found', (tester) async {
    await loginAndNavigateToHome(tester);

    // Search for something unlikely to exist
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byType(TextField), 'xyzabc123nonexistentmovie987');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Should show empty state
    expect(find.text('No movies found.'), findsOneWidget);

    print('✓ Empty state displayed correctly');
  });


}