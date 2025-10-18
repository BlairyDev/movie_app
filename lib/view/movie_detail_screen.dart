import 'package:flutter/material.dart';
import '../view/review_screen.dart'; // Assuming this path is correct
import '../data/models/movie.dart'; // Assuming this path is correct

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;
  final String imgPath = 'https://image.tmdb.org/t/p/w500/';

  MovieDetailScreen(this.movie, {super.key});

  @override
  Widget build(BuildContext context) {
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
        // Use Padding directly instead of a Container with fixed width
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Poster Image (Left Side) - Fixed Size
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                path,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Use minimum vertical space
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

                  // Movie Overview/Summary
                  Text(
                    movie.overview,
                    style: const TextStyle(
                      fontFamily: 'CenturyGothic',
                      fontSize:
                          16, // Adjusted font size slightly for better fit
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Correctly closed ElevatedButton.icon
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
                    label: const Text('See Reviews',
                        style: TextStyle(
                            fontFamily: 'CenturyGothic',
                            fontSize: 16,
                            color: Colors.black)),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.white;
                          }
                          return const Color(0xFF8B030C);
                        },
                      ),
                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return const Color(0xFF8B030C);
                          }
                          return Colors.black;
                        },
                      ),
                      side: MaterialStateProperty.resolveWith<BorderSide>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return const BorderSide(
                              color: Color(0xFF8B030C),
                              width: 3.0,
                            );
                          }
                          return BorderSide.none;
                        },
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
