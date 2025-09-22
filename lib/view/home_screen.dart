import 'package:flutter/material.dart';
import 'package:movie_app/data/models/movie.dart';
import 'package:movie_app/view/movie_detail_screen.dart';
import 'package:movie_app/view_models/home_view_model.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String iconBase = 'https://image.tmdb.org/t/p/w92/';
  final String defaultImage =
      'https://images.freeimages.com/images/large-previews/5eb/movie-clapboard-1184339.jpg';
  Icon visibleIcon = Icon(Icons.search);
  Widget searchBar = Text('Movies');

  @override
  void initState() {
    Provider.of<HomeViewModel>(context, listen: false).loadUpcomingMovies();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    NetworkImage image;

    return Scaffold(
      appBar: AppBar(
        title: searchBar,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                if (this.visibleIcon.icon == Icons.search) {
                  this.visibleIcon = Icon(Icons.cancel);
                  this.searchBar = TextField(
                    textInputAction: TextInputAction.search,
                    onSubmitted: (String text) {
                      context.read<HomeViewModel>().loadSearchMovies(text);
                    },
                    style: TextStyle(color: Colors.black, fontSize: 20.0),
                  );
                } else {
                  this.visibleIcon = Icon(Icons.search);
                  this.searchBar = Text('Movies');
                }
              });
            },
          ),
        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          List? movies = viewModel.movies;
          int? movieCount = movies.length;

          return Center(
            child: viewModel.isLoading ? CircularProgressIndicator() : ListView.builder(
              itemCount: movieCount,
              itemBuilder: (BuildContext context, int position) {
                if (movies?[position].posterPath != null) {
                  image = NetworkImage(iconBase + movies[position].posterPath);
                } else {
                  image = NetworkImage(defaultImage);
                }
                return Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: ListTile(
                    onTap: () {
                      MaterialPageRoute route = MaterialPageRoute(
                        builder: (_) => MovieDetailScreen(movies[position]),
                      );
                      Navigator.push(context, route);
                    },
                    leading: CircleAvatar(backgroundImage: image),
                    title: Text(movies?[position].title),
                    subtitle: Text(
                      'Released: ' +
                          movies[position].releaseDate +
                          ' - Vote: ' +
                          movies![position].voteAverage.toString(),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
