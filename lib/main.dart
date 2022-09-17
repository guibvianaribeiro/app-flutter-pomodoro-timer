import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:carbon_icons/carbon_icons.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(MyApp());

//Splash Screen
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Pomodoro Timer',
        debugShowCheckedModeBanner: false,
        home: AnimatedSplashScreen(
            duration: 1500,
            splash: Icon(
              CarbonIcons.hourglass,
              color: Color.fromARGB(255, 255, 255, 255),
              size: 100.0,
            ),
            nextScreen: PomodoroScreen(),
            splashTransition: SplashTransition.fadeTransition,
            pageTransitionType: PageTransitionType.rightToLeft,
            backgroundColor: Color.fromARGB(255, 89, 149, 237)));
  }
}

//Widget TimerCard
class TimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Foco',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w700,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 3.2,
              height: 170,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 4,
                        blurRadius: 4,
                        offset: Offset(0, 2))
                  ]),
              child: Center(
                child: Text(
                  '00',
                  style: GoogleFonts.oswald(
                    fontSize: 80,
                    color: Color.fromARGB(255, 4, 67, 137),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              ':',
              style: GoogleFonts.lato(
                fontSize: 40,
                color: Colors.white,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Container(
              width: MediaQuery.of(context).size.width / 3.2,
              height: 170,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 4,
                        blurRadius: 4,
                        offset: Offset(0, 2))
                  ]),
              child: Center(
                child: Text(
                  '00',
                  style: GoogleFonts.oswald(
                    fontSize: 80,
                    color: Color.fromARGB(255, 4, 67, 137),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

//Lista de opções do Timer
List selectableTime = [
  "300",
  "600",
  "900",
  "1200",
  "1500",
  "1800",
  "2100",
  "2400",
  "2700",
  "3000",
  "3300",
];

//Opções do Timer
class TimerOptions extends StatelessWidget {
  double selectedime = 1500;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: selectableTime.map((time) {
          return Container(
            margin: EdgeInsets.only(left: 10),
            width: 70,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(width: 3, color: Colors.white30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                (int.parse(time) ~/ 60).toString(),
                style: GoogleFonts.oswald(
                  fontSize: 25,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

//Tela Principal
class PomodoroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 4, 67, 137),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 4, 67, 137),
        title: Text(
          'Pomodoro Timer',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w700,
            fontSize: 30,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                SizedBox(height: 15),
                TimerCard(),
                SizedBox(
                  height: 40,
                ),
                TimerOptions(),
              ],
            )),
      ),
    );
  }
}
