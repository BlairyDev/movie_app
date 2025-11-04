import 'package:flutter/material.dart';
import 'package:movie_app/data/models/movie.dart';
import 'package:movie_app/view/movie_detail_screen.dart';
import 'package:movie_app/view/profile_screen.dart';
import 'package:movie_app/view_models/home_view_model.dart';
import 'package:movie_app/view/filter_sheet.dart';
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
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<HomeViewModel>(context, listen: false).loadUpcomingMovies();
  });
}

  Widget _buildMovieListItem(Movie movie) {
    String imageUrl = movie.posterPath != null
        ? imageBaseUrl + movie.posterPath!
        : defaultImage;

    return Card(
      color: Colors.white,
      elevation: 2.0,
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MovieDetailScreen(movie)),
          );
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: Image.network(
            imageUrl,
            width: 50.0,
            height: 75.0,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                width: 50.0,
                height: 75.0,
                child: Center(child: Icon(Icons.movie_filter)),
              );
            },
          ),
        ),
        title: Text(movie.title),
        subtitle: Text(
          'Released: ${movie.releaseDate} - Vote: ${movie.voteAverage.toString()}',
        ),
      ),
    );
  }

  Widget _buildPaginationControls(HomeViewModel viewModel) {
    if (viewModel.totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: viewModel.currentPage > 1 && !viewModel.isPageLoading
                ? () => viewModel.previousPage()
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6d0108),
              foregroundColor: Colors.white,
            ),
            child: const Text('Previous Page'),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: Center(
              child: viewModel.isPageLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      '${viewModel.currentPage} / ${viewModel.totalPages}',
                      style: const TextStyle(color: Colors.white),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: viewModel.currentPage < viewModel.totalPages && !viewModel.isPageLoading
                ? () => viewModel.nextPage()
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6d0108),
              foregroundColor: Colors.white,
            ),
            child: const Text('Next Page'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2d0500),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6d0108),
        title: searchBar,
        actions: <Widget>[
          if(!_isCarouselMode || visibleIcon.icon == Icons.cancel)
            IconButton(
              icon: const Icon(Icons.filter_alt, color: Colors.white),
              tooltip: 'Filter',
              onPressed: () async {
                final filters = await showModalBottomSheet<Map<String, dynamic>>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => FilterSheet(initialFilters: context.read<HomeViewModel>().currentFilters),
                );

                if (filters != null) {
                  context.read<HomeViewModel>().applyFilters(filters);
                  setState(() {
                    _isCarouselMode = false; 
                  });
                }
              },
            ),
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
                    searchBar =TextField(
                      controller: TextEditingController(text: context.read<HomeViewModel>().currentSearchQuery),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (String text) {
                        context.read<HomeViewModel>().searchMovies(text);
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
                    
                    final viewModel = context.read<HomeViewModel>();

                    viewModel.clearSearch(); 
                    viewModel.clearFilters();
                    viewModel.loadUpcomingMovies(); 
                    
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No movies found.',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  if (viewModel.totalPages > 1)
                    _buildPaginationControls(viewModel),
                ],
              ),
            );
          }
          
          bool showCarousel = _isCarouselMode && 
                              viewModel.currentSearchQuery.isEmpty && 
                              viewModel.currentFilters.isEmpty;

          if (showCarousel) {
            return CarouselSlider.builder(
              itemCount: movieCount,
              itemBuilder: (context, position, realIndex) {
                final Movie movie = movies![position];

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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0), 
                            child: Image.network(
                              imageUrl,
                              height: 450.0,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox(
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
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  )),
                                );
                              },
                            ),
                          ),
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
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: movieCount,
                    itemBuilder: (BuildContext context, int position) {
                      final Movie movie = movies![position];
                      return _buildMovieListItem(movie);
                    },
                  ),
                ),
                _buildPaginationControls(viewModel), 
              ],
            );
          }
        },
      ),
    );
  }
}