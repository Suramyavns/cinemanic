import 'package:cinemanic/screens/home_screen.dart';
import 'package:cinemanic/screens/welcome_screen.dart';
import 'package:cinemanic/utils/notifiers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

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
              actions: [
                ValueListenableBuilder(
                  valueListenable: isDarkNotifier,
                  builder: (context, isDark, child) {
                    return IconButton(
                      onPressed: () {
                        isDarkNotifier.value = !isDark;
                      },
                      icon: Icon(
                        isDark ? CupertinoIcons.moon : CupertinoIcons.sun_max,
                      ),
                    );
                  },
                ),
              ],
            ),
            body: HomeScreen(),
          );
        }

        return const WelcomeScreen();
      },
    );
  }
}
