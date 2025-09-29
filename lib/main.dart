import 'package:flutter/material.dart';
import 'package:movie_app/data/repositories/tmdb_repository.dart';
import 'package:movie_app/di/locator.dart';
import 'package:movie_app/view/home_screen.dart';
import 'package:movie_app/view/profile_screen.dart';
import 'package:movie_app/view_models/home_view_model.dart';
import 'package:movie_app/view_models/login_view_model.dart';
import 'package:movie_app/view_models/profile_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'view/login_screen.dart';

Future main() async {
  await dotenv.load(fileName: ".env");

  setupLocator();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel(repository: locator<TmdbRepository>())
        ),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(repository: locator<TmdbRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(repository: locator<TmdbRepository>()),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Movies',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: const LoginScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
      }
    );
  }
}
