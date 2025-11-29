import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import '../view/review_screen.dart';
import '../data/models/movie.dart';
import '../data/repositories/tmdb_repository.dart';
import '../data/services/tmdb_api_service.dart';
import '../data/models/profile.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen(this.movie, {super.key});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final String imgPath = 'https://image.tmdb.org/t/p/w500/';
  final TmdbRepository _apiRepo = TmdbRepository();

  // Rating state
  double rating = 0.0;
  final int starCount = 5;
  bool hasUserRating = false;
  bool isLoadingRating = false;

  @override
  void initState() {
    super.initState();
    // Initialize with TMDB average rating
    if (widget.movie.voteAverage != null) {
      rating = widget.movie.voteAverage! / 2; // Convert 10/10 TMDB to 5 stars
    }
    // Check if user has already rated this movie
    _checkUserRating();
  }

  Future<void> _checkUserRating() async {
  try {
    print('Checking user rating for movie ID: ${widget.movie.id}');
    final userRating = await _apiRepo.getUserMovieRating(widget.movie.id);
    
    if (userRating != null) {
      print('Found user rating: $userRating');
      setState(() {
        rating = userRating / 2; // Convert 10-scale to 5-star
        hasUserRating = true;
      });
    } else {
      print('No user rating found for this movie');
      setState(() {
        hasUserRating = false;
        // Keep TMDB average rating
        rating = widget.movie.voteAverage != null 
            ? widget.movie.voteAverage! / 2 
            : 0.0;
      });
    }
  } catch (e) {
    print('Error checking user rating: $e');
    setState(() {
      hasUserRating = false;
      rating = widget.movie.voteAverage != null 
          ? widget.movie.voteAverage! / 2 
          : 0.0;
    });
  }
}

  Future<void> _submitRating() async {
    if (rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoadingRating = true;
    });

    try {
      // Convert 5-star rating to 10-scale (0.5 to 10.0)
      final tmdbRating = rating * 2;
      
      await _apiRepo.addMovieRating(widget.movie.id, tmdbRating);

      setState(() {
        hasUserRating = true;
        isLoadingRating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        isLoadingRating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit rating: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeRating() async {
    setState(() {
      isLoadingRating = true;
    });

    try {
      await _apiRepo.removeMovieRating(widget.movie.id);

      setState(() {
        hasUserRating = false;
        // Reset to TMDB average
        rating = widget.movie.voteAverage != null 
            ? widget.movie.voteAverage! / 2 
            : 0.0;
        isLoadingRating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating removed successfully!'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      setState(() {
        isLoadingRating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove rating: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    String path;
    if (movie.posterPath != null) {
      path = imgPath + movie.posterPath!;
    } else {
      path =
          'https://images.freeimages.com/images/large-previews/5eb/movie-clapboard-1184339.jpg';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF2d0500),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6d0108),
        title: Text(movie.title,
            style: const TextStyle(
              fontFamily: 'Broadway',
              fontSize: 24,
              color: Colors.black,
            )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Poster Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(path),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontFamily: 'Broadway',
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    movie.overview,
                    style: const TextStyle(
                      fontFamily: 'CenturyGothic',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Star Rating Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            hasUserRating ? 'Your Rating:' : 'Rate this movie:',
                            style: const TextStyle(
                              fontFamily: 'CenturyGothic',
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (hasUserRating)
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      StarRating(
                        size: 40.0,
                        rating: rating,
                        color: Colors.orange,
                        borderColor: Colors.grey,
                        allowHalfRating: true,
                        starCount: starCount,
                        onRatingChanged: (newRating) {
                          setState(() {
                            rating = newRating;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rating: ${(rating * 2).toStringAsFixed(1)} / 10',
                        style: const TextStyle(
                          fontFamily: 'CenturyGothic',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Rating Action Buttons
                      if (isLoadingRating)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                          ),
                        )
                      else
                        Row(
                          children: [
                            // Submit/Update Rating Button
                            ElevatedButton.icon(
                              onPressed: _submitRating,
                              icon: Icon(
                                hasUserRating ? Icons.edit : Icons.add,
                              ),
                              label: Text(
                                hasUserRating ? 'Update Rating' : 'Add Rating',
                                style: const TextStyle(
                                  fontFamily: 'CenturyGothic',
                                  fontSize: 14,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B030C),
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Remove Rating Button (only show if user has rated)
                            if (hasUserRating)
                              ElevatedButton.icon(
                                onPressed: _removeRating,
                                icon: const Icon(Icons.delete),
                                label: const Text(
                                  'Remove',
                                  style: TextStyle(
                                    fontFamily: 'CenturyGothic',
                                    fontSize: 14,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[800],
                                  foregroundColor: Colors.white,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Add to Watchlist
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        bool isOnWatchlist =
                            await _apiRepo.isOnMovieWatchlist(movie.id);

                        if (isOnWatchlist) {
                          await _apiRepo.addMovieToWatclist(movie.id, false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Removed from Watchlist'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          await _apiRepo.addMovieToWatclist(movie.id, true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to Watchlist!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.bookmark_add),
                    label: const Text('Toggle Watchlist'),
                  ),

                  // Add to Favorites
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        bool isOnFavorites =
                            await _apiRepo.isOnMovieFavorites(movie.id);

                        if (isOnFavorites) {
                          await _apiRepo.addMovieToFavorites(movie.id, false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Removed from Favorites'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          await _apiRepo.addMovieToFavorites(movie.id, true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to Favorites!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.bookmark_add),
                    label: const Text('Toggle Favorites'),
                  ),

                  // Reviews Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReviewScreen(movie: movie),
                        ),
                      );
                    },
                    icon: const Icon(Icons.comment),
                    label: const Text(
                      'See Reviews',
                      style: TextStyle(
                        fontFamily: 'CenturyGothic',
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (states) => states.contains(MaterialState.pressed)
                            ? Colors.white
                            : const Color(0xFF8B030C),
                      ),
                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
                        (states) => states.contains(MaterialState.pressed)
                            ? const Color(0xFF8B030C)
                            : Colors.black,
                      ),
                      side: MaterialStateProperty.resolveWith<BorderSide>(
                        (states) => states.contains(MaterialState.pressed)
                            ? const BorderSide(
                                color: Color(0xFF8B030C),
                                width: 3.0,
                              )
                            : BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}