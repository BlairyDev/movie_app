import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/profile_view_model.dart';
import '../data/models/movie.dart';
import '../data/models/profile.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 0;
  int _watchlistIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);

      if (SessionManager().accountId != null &&
          SessionManager().sessionId != null) {
        viewModel.loadWatchlistMovies();
        viewModel.loadWatchlistTv();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF2d0500),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6d0108),
        title: const Text('Your Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () {
              SessionManager().clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF4a0004),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navButton("Watchlist", 0),
                _navButton("Favorites", 1),
                _navButton("Reviews", 2),
              ],
            ),
          ),
          Expanded(child: _getSelectedPage(viewModel)),
        ],
      ),
    );
  }

  Widget _getSelectedPage(ProfileViewModel viewModel) {
    if (_selectedIndex == 0) {
      List<Movie> movies = _watchlistIndex == 0
          ? viewModel.watchlistMovies
          : viewModel.watchlistTv;

      return Column(
        children: [
          Container(
            color: const Color(0xFF4a0004),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _subNavButton("Movies", 0),
                _subNavButton("TV Shows", 1),
              ],
            ),
          ),
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : movies.isEmpty
                    ? const Center(
                        child: Text(
                          'No items in watchlist.',
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          final movie = movies[index];
                          final imageUrl = movie.posterPath.isNotEmpty
                              ? 'https://image.tmdb.org/t/p/w185/${movie.posterPath}'
                              : '';

                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              leading: imageUrl.isNotEmpty
                                  ? Image.network(imageUrl,
                                      width: 50, fit: BoxFit.cover)
                                  : const Icon(Icons.movie),
                              title: Text(movie.title),
                              subtitle: Text(
                                  'Released: ${movie.releaseDate} - Vote: ${movie.voteAverage}'),
                            ),
                          );
                        },
                      ),
          ),
        ],
      );
    }

    if (_selectedIndex == 1) {
      return const Center(
        child: Text(
          'Favorites (Coming Soon)',
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
      );
    }

    return const Center(
      child: Text(
        'Your Reviews (Coming Soon)',
        style: TextStyle(fontSize: 22, color: Colors.white),
      ),
    );
  }

  Widget _navButton(String text, int index) {
    final bool isSelected = _selectedIndex == index;

    return TextButton(
      onPressed: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.orangeAccent : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _subNavButton(String text, int index) {
    final bool isSelected = _watchlistIndex == index;

    return TextButton(
      onPressed: () {
        setState(() {
          _watchlistIndex = index;
        });
      },
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.orangeAccent : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
