import 'package:cinemanic/firebase_options.dart';
import 'package:cinemanic/utils/auth_gate.dart';
import 'package:cinemanic/utils/constants.dart';
import 'package:cinemanic/utils/notifiers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    loadThemeMode();
    super.initState();
  }

  void loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Load the initial value
    isDarkNotifier.value = prefs.getBool(isDarkKey) ?? true;

    // 2. Add a listener to save the value whenever it changes
    isDarkNotifier.addListener(() {
      prefs.setBool(isDarkKey, isDarkNotifier.value);
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkNotifier,
      builder: (context, isDark, child) {
        return MaterialApp(
          title: 'Cinemanic',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // TRY THIS: Try running your application with "flutter run". You'll see
            // the application has a purple toolbar. Then, without quitting the app,
            // try changing the seedColor in the colorScheme below to Colors.green
            // and then invoke "hot reload" (save your changes or press the "hot
            // reload" button in a Flutter-supported IDE, or press "r" if you used
            // the command line to start the app).
            //
            // Notice that the counter didn't reset back to zero; the application
            // state is not lost during the reload. To reset the state, use hot
            // restart instead.
            //
            // This works for code too, not just values: Most code changes can be
            // tested with just a hot reload.
            colorScheme: .fromSeed(
              seedColor: Colors.blue,
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
          ),
          debugShowCheckedModeBanner: false,
          home: AuthGate(),
        );
      },
    );
  }
}
