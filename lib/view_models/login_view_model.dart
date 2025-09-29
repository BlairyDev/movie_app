import 'package:flutter/material.dart';
import 'package:movie_app/data/repositories/tmdb_repository.dart';

class LoginViewModel extends ChangeNotifier{

  final TmdbRepository repository;

  LoginViewModel({
    required this.repository
  });



}