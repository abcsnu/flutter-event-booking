// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/theme_state.dart';
import 'screens/events_list_screen.dart';
import 'screens/event_details_screen.dart';
import 'screens/bookings_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const EventsApp());
}

class EventsApp extends StatelessWidget {
  const EventsApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color nujranGreen = Color(0xFF1E5B3D);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Event Booking App - NUJ',
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/': (context) => const EventsListScreen(),
            '/details': (context) => const EventDetailsScreen(),
            '/bookings': (context) => const BookingsScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
          theme: ThemeData(
            primaryColor: nujranGreen,
            primarySwatch: const MaterialColor(0xFF1E5B3D, <int, Color>{
              50: Color(0xFFE4F0E7),
              100: Color(0xFFBCCCD0),
              200: Color(0xFF90A8AC),
              300: Color(0xFF638387),
              400: Color(0xFF42686F),
              500: nujranGreen,
              600: Color(0xFF1B5338),
              700: Color(0xFF174A31),
              800: Color(0xFF12412A),
              900: Color(0xFF0B301D),
            }),
            scaffoldBackgroundColor: Colors.grey.shade50,
            appBarTheme: const AppBarTheme(
              backgroundColor: nujranGreen,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: nujranGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: nujranGreen,
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(backgroundColor: nujranGreen),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: nujranGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          themeMode: currentMode,
        );
      },
    );
  }
}
