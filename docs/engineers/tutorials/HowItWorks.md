
# Articles that I used
- https://pieces.app/blog/using-mvvm-architecture-in-flutter (Most important)

- https://medium.com/@ayseleynavuz/implementing-api-in-flutter-using-mvvm-architecture-clean-code-53b69cfd9db1


# Libraries/Dependencies that we will use to make MVVM work

- **GetIt** - this makes it that you only get one instance of a class (Singleton Pattern)
            - Specifically this makes it so that `user_repository` only gets one instance to use for everything

- **Provider** - State management solution to make it so that the Widgets listens to if data changes. Example: ViewModel the variable's value suddenly changed then view data will update


# I will create a new page for an example, I will use the "get recommendation" in TMDB


## What I recommend is this steps when creating a new page:

**Api -> Repository -> ViewModel -> main.dart -> view**

1. Go to `data/services/tmdb_api_service.dart`
2. Add your new function to get recommendation:

```dart
//function might be wrong but this is just an example
Future<Map<String, dynamic>> fetchRecommendation(String movieId) async {
    final String upcomingAPI = urlBase + apiUpcoming + movieId + apiKey! + urlLanguage;
    return runAPI(upcomingAPI);
}
```
3. Go to `repositories\tmdb_repository` this is an abstract class and create a new function
```dart
abstract class TmdbRepository {
  Future<List<Movie>> getUpcomingMovies();
  Future<List<Movie>> getSearchMovies(String title);
  Future<List<Movie>> getRecommendation(String movieId);
}
```
4. Now add this to `tmdb_repository_fake.dart` and `tmdb_repository_real.dart`
```dart
    //tmdb_repository_real.dart
    @override
    Future<List<Movie>> getRecommendation(String movieId) {
        try {
            //calls the fetchRecommendation in `tmdb_api_service.dart`
            final result = await _service.fetchRecommendation(movieId); 
            final moviesMap = result['results'];

            List<Movie> movies = moviesMap.map<Movie>((i) => Movie.fromJson(i)).toList();
            return movies;
        } catch (e) {
        throw Exception(e);
        }
    }
    // tmdb_repository_fake.dart should be fine to put empty just add the function for 
    //reference check out tmdb_repository_fake.dart
```

1. Now go to `view_models` folder and create a new file called recommendation_view_model.dart
2. Now create this in your new file:
   ```dart
    class RecommendationViewModel extends ChangeNotifier{
        final TmdbRepository repository;

        RecommendationViewModel({
            required this.repository
        })

        bool _isLoading = true;
        bool get isLoading => _isLoading;

        List<Movie> _movies = [];//this is the variable that changes
        List<Movie> get movies => _movies;//this going to be used by View

        Future<void> loadRecommenations() async {
            _isLoading = true;
            try {

            _movies = await repository.getRecommendation();
            notifyListeners();//if function is called then this updates the value in View

            } catch (e) {
            _movies = [];
            throw Exception(e);
            }
            finally {
            _isLoading = false;
            }
        }
    }
    ```
3. Go to your `main.dart` and Add this in main():
    ```dart
    Future main() async {
        setupLocator();
        runApp(
            MultiProvider(
            providers: [
                ChangeNotifierProvider(
                create: (_) => HomeViewModel(repository: locator<TmdbRepository>()),
                ),
                //newly added for recommendation viewmodel
                ChangeNotifierProvider(
                create: (_) => RecommendationViewModel(repository: locator<TmdbRepository>()),
                ),
            ],
            child: MyApp(),
            ),
        );
    }
    

4. Finally we are now going to create a new file in `view` folder named recommendation_screen.dart and create a StateFulWidget

```dart
class _HomeScreenState extends State<HomeScreen> {
  final String iconBase = 'https://image.tmdb.org/t/p/w92/';
  final String defaultImage =
      'https://images.freeimages.com/images/large-previews/5eb/movie-clapboard-1184339.jpg';
  Icon visibleIcon = Icon(Icons.search);
  Widget searchBar = Text('Movies');

  @override
  void initState() {
    //just so we can call when we go to this page
    Provider.of<RecomendationViewModel>(context, listen: false).loadRecommendation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    NetworkImage image;

    return Scaffold(
      appBar:....
      //this builder is the most important to get the RecommendationViewModel
      body: Consumer<RecommendationViewModel>(
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
```

5. My recommendation when naming function is load -> get -> fetch

| View | ViewModel     | Repository   | API / Data   |
|------|---------------|--------------|--------------|
|      | loadMovies()  | getMovies()  | fetchMovies()|




6. To use a mock data if for example API is not working then we can use `repositories/tmdb_repository_fake.dart` to use it go to `di/locator.dart`
   
   ```dart
    import 'package:get_it/get_it.dart';
    import 'package:movie_app/data/repositories/tmdb_repository.dart';
    import 'package:movie_app/data/repositories/tmdb_repository_fake.dart' show TmdbRepositoryFake;
    import 'package:movie_app/data/repositories/tmdb_repository_real.dart';

    final GetIt locator = GetIt.instance;

    void setupLocator() {
        locator.registerFactory<TmdbRepository>(
            () => TmdbRepositoryFake() //changed from TmdbRepositoryReal to Fake
        );
    }
