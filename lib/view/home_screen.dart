import 'package:flutter/material.dart';
import 'package:movie_app/data/models/movie.dart';
import 'package:movie_app/view/movie_detail_screen.dart';
import 'package:movie_app/view/profile_screen.dart';
import 'package:movie_app/view_models/home_view_model.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isCarouselMode = true;
  final String imageBaseUrl = 'https://image.tmdb.org/t/p/w185/';
  final String defaultImage =
      'https://images.freeimages.com/images/large-previews/5eb/movie-clapboard-1184339.jpg';
  Icon visibleIcon = const Icon(Icons.search, color: Colors.white);
  Widget searchBar = const Text(
    'Movies',
    style: TextStyle(
      fontFamily: 'Broadway',
      fontSize: 24,
    ),
  );

  @override
  void initState() {
    Provider.of<HomeViewModel>(context, listen: false).loadUpcomingMovies();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2d0500),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6d0108),
        title: searchBar,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: visibleIcon,
            onPressed: () {
              setState(() {
                if (visibleIcon.icon == Icons.search) {
                  visibleIcon = const Icon(Icons.cancel, color: Colors.white);
                  searchBar = TextField(
                    textInputAction: TextInputAction.search,
                    onSubmitted: (String text) {
                      context.read<HomeViewModel>().loadSearchMovies(text);

                      setState(() {
                        _isCarouselMode = false;
                      });
                    },
                    style: const TextStyle(color: Colors.white, fontSize: 20.0),
                    decoration: const InputDecoration(
                      hintText: 'Search movies...',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  );
                } else {
                  visibleIcon = const Icon(Icons.search, color: Colors.white);
                  searchBar = const Text(
                    'Movies',
                    style: TextStyle(
                      fontFamily: 'Broadway',
                      fontSize: 24,
                    ),
                  );
                  context.read<HomeViewModel>().loadUpcomingMovies();

                  setState(() {
                    _isCarouselMode = true;
                  });
                }
              });
            },
          ),
        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          List<Movie>? movies = viewModel.movies;
          int movieCount = movies?.length ?? 0;

          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (movieCount == 0) {
            return const Center(
              child: Text(
                'No movies found.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }
          if (_isCarouselMode) {
            return CarouselSlider.builder(
              itemCount: movieCount,
              itemBuilder: (context, position, realIndex) {
                final Movie movie = movies![position];

                // Use the string URL directly in the Image.network widget
                String imageUrl = movie.posterPath != null
                    ? imageBaseUrl + movie.posterPath!
                    : defaultImage;

                return Container(
                  margin: const EdgeInsets.all(5.0),
                  child: Card(
                    color: Colors.white,
                    elevation: 4.0,
                    child: InkWell(
                      onTap: () {
                        MaterialPageRoute route = MaterialPageRoute(
                          builder: (_) => MovieDetailScreen(movie),
                        );
                        Navigator.push(context, route);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          // --- FIX: Syntax error and Movie Poster implementation ---
                          ClipRRect(
                            // ClipRRect for rounded corners
                            borderRadius: BorderRadius.circular(
                                8.0), // Optional: rounded corners
                            child: Image.network(
                              imageUrl,
                              height: 450.0,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return SizedBox(
                                  height: 460.0,
                                  child: Center(
                                      child: Icon(Icons.movie, size: 50.0)),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  height: 250.0,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  )),
                                );
                              },
                            ),
                          ),
                          // --- END FIX ---
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              movie.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Released: ${movie.releaseDate}\nVote: ${movie.voteAverage.toString()}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height * 0.95,
                enlargeCenterPage: true,
                autoPlay: true,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                viewportFraction: 0.30,
              ),
            );
          } else {
            return ListView.builder(
                itemCount: movieCount,
                itemBuilder: (BuildContext context, int position) {
                  final Movie movie = movies![position];

                  // Use the string URL directly in the Image.network widget
                  String imageUrl = movie.posterPath != null
                      ? imageBaseUrl + movie.posterPath!
                      : defaultImage;

                  return Card(
                      color: Colors.white,
                      elevation: 2.0,
                      child: ListTile(
                        onTap: () {
                          MaterialPageRoute route = MaterialPageRoute(
                            builder: (_) => MovieDetailScreen(movie),
                          );
                          Navigator.push(context, route);
                        },
                        // --- FIX: Replaced CircleAvatar with ClipRRect for movie poster look ---
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              4.0), // Smaller radius for ListTile
                          child: Image.network(
                            imageUrl,
                            width:
                                50.0, // Typical width for a ListTile leading image
                            height: 75.0, // Gives a 2:3 poster ratio
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return SizedBox(
                                width: 50.0,
                                height: 75.0,
                                child: Center(child: Icon(Icons.movie_filter)),
                              );
                            },
                          ),
                        ),
                        // --- END FIX ---
                        title: Text(movie.title),
                        subtitle: Text(
                          'Released: ${movie.releaseDate} - Vote: ${movie.voteAverage.toString()}',
                        ),
                      ));
                });
          }
        },
      ),
    );
  }
}
