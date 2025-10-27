import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/view_models/filter_view_model.dart';

class FilterSheet extends StatefulWidget {
  // 1. ADD initialFilters parameter
  final Map<String, dynamic>? initialFilters;
  const FilterSheet({super.key, this.initialFilters});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String? selectedGenre;
  String? selectedLanguage;
  double selectedRating = 0;
  String? selectedYear;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 2. Load the initial filters passed from the HomeScreen
      _loadInitialFilters();
      context.read<FilterViewModel>().loadFilters();
    });
  }

  // 3. New method to apply initial filters
  void _loadInitialFilters() {
    final filters = widget.initialFilters;
    if (filters != null) {
      setState(() {
        selectedGenre = filters['genre'] as String?;
        selectedLanguage = filters['language'] as String?;
        // Ensure rating is treated as double, defaulting to 0 if null
        selectedRating = (filters['rating'] as num?)?.toDouble() ?? 0;
        selectedYear = filters['year'] as String?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FilterViewModel>();
    final genres = vm.genres;
    final languages = vm.languages;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Material( 
          color: const Color(0xFF1c1c1c),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: SafeArea(
            top: false,
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Center(
                        child: Text(
                          'Filter Movies',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // GENRE
                      const Text('Genre', style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 8),
                      _buildDropdown(
                        value: selectedGenre,
                        items: genres.map((g) => g.name).toList(),
                        onChanged: (v) => setState(() => selectedGenre = v),
                      ),
                      const SizedBox(height: 16),

                      // LANGUAGE
                      const Text('Language', style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 8),
                      _buildDropdown(
                        value: selectedLanguage,
                        items: languages.map((l) => l.isoCode).toList(),
                        onChanged: (v) => setState(() => selectedLanguage = v),
                        labelBuilder: (v) => languages
                            .firstWhere((l) => l.isoCode == v)
                            .englishName,
                      ),
                      const SizedBox(height: 16),

                      // RATING
                      const Text('Minimum Rating',
                          style: TextStyle(color: Colors.white)),
                      Slider(
                        value: selectedRating,
                        min: 0,
                        max: 10,
                        divisions: 10,
                        label: selectedRating.toStringAsFixed(1),
                        onChanged: (v) => setState(() => selectedRating = v),
                        activeColor: Colors.redAccent,
                        inactiveColor: Colors.white24,
                      ),
                      Text('${selectedRating.toStringAsFixed(1)} / 10',
                          style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 16),

                      // YEAR
                      const Text('Release Year (optional)', style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 8),
                      TextFormField(
                        // 4. Use selectedYear in initialValue for persistence
                        initialValue: selectedYear ?? '',
                        keyboardType: TextInputType.text,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration().copyWith(
                          hintText: 'e.g. 1999 or 2010-2020',
                          hintStyle: const TextStyle(color: Colors.white54),
                        ),
                        onChanged: (val) => setState(() => selectedYear = val.trim().isEmpty ? null : val.trim()),
                      ),
                      const SizedBox(height: 24),


                      // RESET BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            // No need to call clearFilters on VM as we only use local state
                            setState(() {
                              selectedGenre = null;
                              selectedLanguage = null;
                              selectedRating = 0;
                              selectedYear = null;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white70),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Reset Filters',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // APPLY BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // 5. Return the map of currently selected filters
                            Navigator.pop(context, {
                              'genre': selectedGenre,
                              'language': selectedLanguage,
                              'rating': selectedRating,
                              'year': selectedYear,
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String Function(String)? labelBuilder,
  }) {
    // Determine the value to use for the dropdown, ensuring it's valid for the items list
    final actualValue = value != null && items.contains(value) ? value : null;

    return DropdownButtonFormField<String>(
      // 6. Use actualValue to ensure the currently selected filter is displayed
      value: actualValue,
      dropdownColor: const Color(0xFF2d2d2d),
      isExpanded: true,
      menuMaxHeight: 300,
      decoration: _inputDecoration(),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(
                  labelBuilder != null ? labelBuilder(item) : item,
                  style: const TextStyle(color: Colors.white),
                ),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _inputDecoration() => InputDecoration(
        filled: true,
        fillColor: const Color(0xFF2d2d2d),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );
}