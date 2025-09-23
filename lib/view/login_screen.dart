import 'package:flutter/material.dart';
import '../data/services/tmdb_api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TmdbAuthService authService = TmdbAuthService();

  void login() async {
    final requestToken = await authService.fetchRequestToken();
    final valid = await authService.validateLogin(
      usernameController.text,
      passwordController.text,
      requestToken,
    );

    if (valid) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect username or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movie Database Login')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            ElevatedButton(onPressed: login, child: const Text('Sign In')),
          ],
        ),
      ),
    );
  }
}
