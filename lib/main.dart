// ignore_for_file: deprecated_member_use
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:spoton_app/screens/home_page.dart';
import 'package:spoton_app/screens/login_page.dart';
import 'package:spoton_app/screens/splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Background notifications
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // print("Firebase initialized: ${Firebase.apps.first.options.projectId}");
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color primaryRed = Color(0xFF8D1113);
  static const Color navyBlue = Color(0xFF003579);
  static const Color scaffoldDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SpotON',
      debugShowCheckedModeBanner: false,

      // ✅ LIGHT THEME: YOUR ORIGINAL UI COLORS
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFDFDFDF),
        primaryColor: primaryRed,
        cardColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: primaryRed,
          onPrimary: Colors.white,
          secondary: navyBlue,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        textTheme: GoogleFonts.sairaTextTheme().copyWith(
          bodyMedium: GoogleFonts.saira(
            color: const Color(0xFF707070),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFF707070)),
          ),
          hintStyle: GoogleFonts.saira(color: const Color(0xFF707070)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: navyBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        useMaterial3: true,
      ),

      // ✅ DARK THEME: MODERN, CLEAN, STILL BRANDED
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: scaffoldDark,
        cardColor: cardDark,
        primaryColor: primaryRed,
        appBarTheme: AppBarTheme(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryRed,
          primary: primaryRed,
          secondary: navyBlue,
          surface: cardDark,
          background: scaffoldDark,
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: navyBlue.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.white,
        ),
        useMaterial3: true,
      ),

      home: const SplashScreen(),
    );
  }
}

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
        } else if (snapshot.hasData) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
