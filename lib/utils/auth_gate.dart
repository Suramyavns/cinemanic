import 'package:cinemanic/screens/home_screen.dart';
import 'package:cinemanic/screens/welcome_screen.dart';
import 'package:cinemanic/widgets/theme_switcher_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              actionsPadding: EdgeInsets.symmetric(horizontal: 4),
              title: Text(
                'Cinemanic',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,

                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              actions: [ThemeSwitcherWidget()],
            ),
            body: HomeScreen(),
          );
        }

        return const WelcomeScreen();
      },
    );
  }
}
