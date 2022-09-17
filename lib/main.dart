import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:carbon_icons/carbon_icons.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Pomodoro Timer',
        debugShowCheckedModeBanner: false,
        home: AnimatedSplashScreen(
            duration: 1500,
            splash: Icon(CarbonIcons.hourglass,
              color: Colors.white,
              size: 100.0,
          ),
            nextScreen: MainScreen(),
            splashTransition: SplashTransition.fadeTransition,
            pageTransitionType: PageTransitionType.rightToLeft,
            backgroundColor: Colors.blue));
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 0, 4, 255),
    );j
  }
}