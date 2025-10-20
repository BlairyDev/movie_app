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
      viewModel.loadWatchlistMovies();
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
              viewModel.clearWatchlists();
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
            child: _watchlistIndex == 0
                ? _buildMovieWatchlist(viewModel)
                : _buildTvWatchlist(viewModel),
          ),
        ],
      );
    } else if (_selectedIndex == 1) {
      return const Center(
        child: Text(
          'Favorites - Coming Soon',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    } else {
      return const Center(
        child: Text(
          'Reviews - Coming Soon',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }
  }

  Widget _buildMovieWatchlist(ProfileViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orangeAccent),
      );
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              viewModel.error!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.loadWatchlistMovies(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.watchlistMovies.isEmpty) {
      return const Center(
        child: Text(
          'No movies in your watchlist',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.loadWatchlistMovies(),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: viewModel.watchlistMovies.length,
        itemBuilder: (context, index) {
          final movie = viewModel.watchlistMovies[index];
          return _buildMovieCard(movie);
        },
      ),
    );
  }

  Widget _buildTvWatchlist(ProfileViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orangeAccent),
      );
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              viewModel.error!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.loadWatchlistTv(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.tvWatchlist.isEmpty) {
      return const Center(
        child: Text(
          'No TV shows in your watchlist',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.loadWatchlistTv(),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: viewModel.tvWatchlist.length,
        itemBuilder: (context, index) {
          final show = viewModel.tvWatchlist[index];
          return _buildTvCard(show);
        },
      ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return Card(
      color: const Color(0xFF4a0004),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: movie.posterPath != null
            ? Image.network(
                'https://image.tmdb.org/t/p/w92${movie.posterPath}',
                width: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.movie, color: Colors.white, size: 50),
              )
            : const Icon(Icons.movie, color: Colors.white, size: 50),
        title: Text(
          movie.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          movie.releaseDate.isNotEmpty
              ? 'Release: ${movie.releaseDate}'
              : 'Release date unknown',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              movie.voteAverage.toStringAsFixed(1),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTvCard(Map<String, dynamic> show) {
    final name = show['name'] ?? 'Unknown Title';
    final posterPath = show['poster_path'];
    final firstAirDate = show['first_air_date'] ?? '';
    final voteAverage = show['vote_average'] ?? 0.0;

    return Card(
      color: const Color(0xFF4a0004),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: posterPath != null
            ? Image.network(
                'https://image.tmdb.org/t/p/w92$posterPath',
                width: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.tv, color: Colors.white, size: 50),
              )
            : const Icon(Icons.tv, color: Colors.white, size: 50),
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          firstAirDate.isNotEmpty
              ? 'First aired: $firstAirDate'
              : 'Air date unknown',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              voteAverage.toStringAsFixed(1),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
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
          final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
          if (index == 0) {
            viewModel.loadWatchlistMovies();
          } else {
            viewModel.loadWatchlistTv();
          }
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
