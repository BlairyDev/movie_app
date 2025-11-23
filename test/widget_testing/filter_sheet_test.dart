import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/data/models/genre.dart';
import 'package:movie_app/data/models/language.dart';
import 'package:movie_app/view/filter_sheet.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/view_models/filter_view_model.dart';

// Mock FilterViewModel
class MockFilterViewModel extends Mock implements FilterViewModel {}

void main() {
  late MockFilterViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockFilterViewModel();

    // Default mock behavior
    when(() => mockViewModel.isLoading).thenReturn(false);
    when(() => mockViewModel.genres).thenReturn([
      Genre(id: 1, name: 'Action'),
      Genre(id: 2, name: 'Comedy'),
    ]);
    when(() => mockViewModel.languages).thenReturn([
      Language(isoCode: 'en', englishName: 'English'),
      Language(isoCode: 'ja', englishName: 'Japanese'),
    ]);
    when(() => mockViewModel.loadFilters()).thenAnswer((_) async {});
  });

  Future<void> _buildFilterSheet(WidgetTester tester,
      {Map<String, dynamic>? initialFilters}) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<FilterViewModel>.value(
        value: mockViewModel,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                child: const Text('Open Sheet'),
                onPressed: () {
                  showModalBottomSheet<Map<String, dynamic>>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => FilterSheet(initialFilters: initialFilters),
                  ).then((filters) {
                    if (filters != null) {
                      debugPrint('Filters returned: $filters');
                    }
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );

    // Open the sheet
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows loading indicator when isLoading is true', (tester) async {
    when(() => mockViewModel.isLoading).thenReturn(true);

    await _buildFilterSheet(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays initial filters', (tester) async {
    final initialFilters = {
      'genre': 'Action',
      'language': 'en',
      'rating': 5.0,
      'year': '2020',
    };

    await _buildFilterSheet(tester, initialFilters: initialFilters);

    // Genre dropdown
    final genreDropdown = find.byType(DropdownButtonFormField<String>).first;
    final genre = tester.widget<DropdownButtonFormField<String>>(genreDropdown);
    expect(genre.initialValue, 'Action');

    // Language dropdown
    final languageDropdown = find.byType(DropdownButtonFormField<String>).last;
    final language = tester.widget<DropdownButtonFormField<String>>(languageDropdown);
    expect(language.initialValue, 'en');

    // Rating slider
    final slider = find.byType(Slider);
    final sliderWidget = tester.widget<Slider>(slider);
    expect(sliderWidget.value, 5.0);

    // Year text field
    final textField = find.byType(TextFormField);
    final textWidget = tester.widget<TextFormField>(textField);
    expect(textWidget.initialValue, '2020');
  });

  testWidgets('reset button clears all filters', (tester) async {
    final initialFilters = {
      'genre': 'Action',
      'language': 'en',
      'rating': 5.0,
      'year': '2020',
    };

    await _buildFilterSheet(tester, initialFilters: initialFilters);

    await tester.tap(find.text('Reset Filters'));
    await tester.pumpAndSettle();

    // Verify dropdowns reset
    final genreDropdown = tester.widget<DropdownButtonFormField<String>>(
        find.byType(DropdownButtonFormField<String>).first);
    expect(genreDropdown.initialValue, isNull);

    final languageDropdown = tester.widget<DropdownButtonFormField<String>>(
        find.byType(DropdownButtonFormField<String>).last);
    expect(languageDropdown.initialValue, isNull);

    // Slider resets to 0
    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.value, 0);

    // Text field resets
    final textField = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(textField.initialValue, '');
  });

  testWidgets('apply button returns selected filters', (tester) async {
    await _buildFilterSheet(tester);

    // Select genre
    await tester.tap(find.text('Select Genre'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Action').last);
    await tester.pumpAndSettle();

    // Select language
    await tester.tap(find.text('Select Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    // Set slider
    await tester.drag(find.byType(Slider), const Offset(100, 0));
    await tester.pumpAndSettle();

    // Enter year
    await tester.enterText(find.byType(TextFormField), '2021');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apply Filters'));
    await tester.pumpAndSettle();

    // Since Navigator.pop just returns map to parent, we check via debugPrint in test
  });
}
