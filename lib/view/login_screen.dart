import 'package:flutter/material.dart';
import '../data/services/tmdb_api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/models/profile.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TmdbAuthService authService = TmdbAuthService();
  static final Uri _registerUrl =
      Uri.parse('https://www.themoviedb.org/signup');
  static final Uri _passwordResetUrl =
      Uri.parse('https://www.themoviedb.org/reset-password');

  void login() async {
    try {
      final requestToken = await authService.fetchRequestToken();

      final valid = await authService.validateLogin(
        usernameController.text,
        passwordController.text,
        requestToken,
      );

      if (valid) {
        final sessionId = await authService.createSession(requestToken);

        final accountData = await authService.fetchAccountDetails(sessionId);
        final accountId = accountData['id'] as int?;

        if (sessionId != null && accountId != null) {
          final sessionManager = SessionManager();
          sessionManager.sessionId = sessionId;
          sessionManager.accountId = accountId;

          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to retrieve account details')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect username or password')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6d0108),
        title: const Text(
          'Movie Database Login',
          style: TextStyle(
              fontFamily: 'Broadway', fontSize: 30, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(
                    fontFamily: 'CenturyGothic',
                    fontSize: 20,
                    color: Color(0xFF8B030C)),
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(
                    fontFamily: 'CenturyGothic',
                    fontSize: 20,
                    color: Color(0xFF8B030C)),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: login,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.white;
                    }
                    return const Color(0xFF8B030C);
                  },
                ),
                foregroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return const Color(0xFF8B030C);
                    }
                    return Colors.black;
                  },
                ),
                side: MaterialStateProperty.resolveWith<BorderSide>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return const BorderSide(
                        color: Color(0xFF8B030C),
                        width: 3.0,
                      );
                    }
                    return BorderSide.none;
                  },
                ),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(
                  fontFamily: 'Broadway',
                  fontSize: 24,
                ),
              ),
            ),
            TextButton(
              onPressed: () => launchUrl(_registerUrl),
              child: const Text(
                'Need an account? Register',
                style: TextStyle(
                  fontFamily: 'CenturyGothic',
                  fontSize: 20,
                  color: Color(0xFF8B030C),
                ),
              ),
            ),
            TextButton(
              onPressed: () => launchUrl(_passwordResetUrl),
              child: const Text(
                'Forgot Password? Reset Password',
                style: TextStyle(
                  fontFamily: 'CenturyGothic',
                  fontSize: 20,
                  color: Color(0xFF8B030C),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
