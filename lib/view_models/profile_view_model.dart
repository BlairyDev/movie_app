import 'package:flutter/material.dart';
import '../data/repositories/tmdb_repository.dart';

class ProfileViewModel extends ChangeNotifier {

  final TmdbRepository repository;

  ProfileViewModel({
    required this.repository
  });

}