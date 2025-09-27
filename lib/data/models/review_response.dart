import 'package:movie_app/data/models/review.dart';
class ReviewResponse {
  late int page;
  late int totalPages;
  late int totalResults;
  late List<Review> results;

  ReviewResponse({
    required this.page,
    required this.totalPages,
    required this.totalResults,
    required this.results,
  });

  ReviewResponse.fromJson(Map<String, dynamic> json) {
    page = json['page'] ?? 1;
    totalPages = json['total_pages'] ?? 1;
    totalResults = json['total_results'] ?? 0;

    results = (json['results'] as List?)
            ?.map((item) => Review.fromJson(item))
            .toList() ??
        [];
  }
}

