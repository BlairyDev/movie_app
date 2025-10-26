class Language {
  final String isoCode;
  final String englishName;

  Language({required this.isoCode, required this.englishName});

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      isoCode: json['iso_639_1'],
      englishName: json['english_name'] ?? json['name'] ?? 'Unknown',
    );
  }
}
