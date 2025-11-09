// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spoton_app/main.dart'; // AuthGate
import 'package:animated_text_kit/animated_text_kit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isOn = false;

  @override
  void initState() {
    super.initState();

    // animation
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted)
        setState(() {
          _isOn = true;
          HapticFeedback.heavyImpact(); // Vibration
        });
    });

    // Navigate b3d el animation
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const AuthGate(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isOn
                ? [const Color(0xFF003579), const Color(0xFF0055A4)]
                : [const Color(0xFFDFDFDF), const Color(0xFFCCCCCC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 30),

              // Toggle
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutCubic,
                width: 275,
                height: 95,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color:
                      _isOn ? const Color(0xFF003579) : const Color(0xFFC4C4C4),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Stack(
                  children: [
                    // Animated Spot bt7rk mkan kelmet Spot bs
                    AnimatedPadding(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeInOutCubic,
                      padding: EdgeInsets.only(
                        left: _isOn ? 20 : 40,
                        right: _isOn ? 83 : 15,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Spot',
                          style: GoogleFonts.righteous(
                            fontSize: 64,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            height: 1,
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    // Sliding ON/OFF bt7rk eldayra
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeInOutCubic,
                      alignment:
                          _isOn ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 78,
                        height: 78,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _isOn ? Colors.white : Colors.black,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          _isOn ? 'ON' : 'OFF',
                          style: GoogleFonts.righteous(
                            fontSize: 32,
                            color: _isOn ? Colors.black : Colors.white,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Animated elklam ely t7t ellogo
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _isOn ? 1 : 0,
                child: _isOn
                    ? SizedBox(
                        height: 30,
                        child: DefaultTextStyle(
                          style: GoogleFonts.righteous(
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          child: AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                'Find your spot. Instantly.',
                                speed: const Duration(milliseconds: 80),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(height: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
