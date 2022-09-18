import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:carbon_icons/carbon_icons.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(ChangeNotifierProvider<TimerService>(
    create: (_) => TimerService(),
    child: MyApp(),
  ));
}

//Timer Service
class TimerService extends ChangeNotifier {
  late Timer timer;
  double currentDuration = 1500;
  double selectedTime = 1500;
  bool timerPlaying = false;
  int rounds = 0;
  int goal = 0;
  String currentState = "Foco";

  void start() {
    timerPlaying = true;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (currentDuration == 0) {
        handleNextRound();
      } else {
        currentDuration--;
      }
      notifyListeners();
    });
  }

  void pause() {
    timer.cancel();
    timerPlaying = false;
    notifyListeners();
  }

  void selectTime(double seconds) {
    selectedTime = seconds;
    currentDuration = seconds;
    notifyListeners();
  }

  void reset() {
    timer.cancel();
    currentState = "Foco";
    currentDuration = selectedTime = 1500;
    rounds = goal = 0;
    timerPlaying = false;
    notifyListeners();
  }

  void handleNextRound() {
    if (currentState == "Foco" && rounds != 3) {
      currentState = "Pausa";
      currentDuration = 300;
      selectedTime = 300;
      rounds++;
      goal++;
    } else if (currentState == "Pausa") {
      currentState = "Foco";
      currentDuration = 1500;
      selectedTime = 1500;
    } else if (currentState == "Foco" && rounds == 3) {
      currentState = "Pausa Longa";
      currentDuration = 1500;
      selectedTime = 1500;
      rounds++;
      goal++;
    } else if (currentState == "Pausa Longa") {
      currentState = "Foco";
      currentDuration = 1500;
      selectedTime = 1500;
      rounds = 0;
    }
    notifyListeners();
  }
}

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
          backgroundColor: Color.fromARGB(255, 4, 67, 137)),
    );
  }
}

//Widget TimerCard
class TimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimerService>(context);
    final seconds = provider.currentDuration % 60;
    return Column(
      children: [
        Text(
          provider.currentState,
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
                  (provider.currentDuration ~/ 60).toString(),
                  style: GoogleFonts.oswald(
                    fontSize: 80,
                    color: renderColor(provider.currentState),
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
                  seconds == 0
                      ? "${seconds.round()}0"
                      : (provider.currentDuration % 60).round().toString(),
                  style: GoogleFonts.oswald(
                    fontSize: 80,
                    color: renderColor(provider.currentState),
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
  "0",
  "300",
  "600",
  "900",
  "1200",
  "1500",
  "1800",
];

//Mudança de cor de fundo
Color renderColor(String currentState) {
  if (currentState == "Foco") {
    return Color.fromRGBO(4, 67, 137, 1);
  } else {
    return Color.fromARGB(255, 219, 57, 42);
  }
}

//Opções do Timer
class TimerOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimerService>(context);
    return SingleChildScrollView(
      controller: ScrollController(initialScrollOffset: 185),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: selectableTime.map((time) {
          return InkWell(
            onTap: () => provider.selectTime(double.parse(time)),
            child: Container(
              margin: EdgeInsets.only(left: 10),
              width: 70,
              height: 50,
              decoration: int.parse(time) == provider.selectedTime
                  ? BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    )
                  : BoxDecoration(
                      border: Border.all(width: 3, color: Colors.white30),
                      borderRadius: BorderRadius.circular(10),
                    ),
              child: Center(
                child: Text(
                  (int.parse(time) ~/ 60).toString(),
                  style: int.parse(time) == provider.selectedTime
                      ? GoogleFonts.oswald(
                          fontSize: 25,
                          color: renderColor(provider.currentState),
                        )
                      : GoogleFonts.oswald(
                          fontSize: 25,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

//Widget Controlador de Tempo
class TimerController extends StatefulWidget {
  @override
  _TimerControllerState createState() => _TimerControllerState();
}

class _TimerControllerState extends State<TimerController> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimerService>(context);
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.black26,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: IconButton(
          icon: provider.timerPlaying
              ? Icon(
                  CarbonIcons.pause_filled,
                  size: 45,
                )
              : Icon(
                  CarbonIcons.play_filled_alt,
                  size: 40,
                ),
          color: Colors.white,
          iconSize: 45,
          onPressed: () {
            provider.timerPlaying
                ? Provider.of<TimerService>(context, listen: false).pause()
                : Provider.of<TimerService>(context, listen: false).start();
          },
        ),
      ),
    );
  }
}

//Widget Opções
class OptionsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimerService>(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              '${provider.rounds}/4',
              style: GoogleFonts.oswald(
                fontSize: 30,
                color: Colors.grey[350],
              ),
            ),
            Text(
              '${provider.goal}/12',
              style: GoogleFonts.oswald(
                fontSize: 30,
                color: Colors.grey[350],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Round',
              style: GoogleFonts.oswald(
                fontSize: 30,
                color: Colors.grey[350],
              ),
            ),
            Text(
              'Goal',
              style: GoogleFonts.oswald(
                fontSize: 30,
                color: Colors.grey[350],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Round',
              style: GoogleFonts.oswald(
                fontSize: 80,
                color: renderColor(provider.currentState),
              ),
            ),
            Text(
              'Goal',
              style: GoogleFonts.oswald(
                fontSize: 80,
                color: renderColor(provider.currentState),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

//Tela Principal
class PomodoroScreen extends StatefulWidget {
  @override
  _PomodoroScreen createState() => _PomodoroScreen();
}

class _PomodoroScreen extends State<PomodoroScreen> {
  int selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      Icon(CarbonIcons.alarm, size: 30),
      Icon(CarbonIcons.face_cool, size: 30),
    ];
    final provider = Provider.of<TimerService>(context);
    return Scaffold(
      backgroundColor: renderColor(provider.currentState),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: renderColor(provider.currentState),
        title: Text(
          'Pomodoro Timer',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w700,
            fontSize: 30,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              CarbonIcons.reset,
              color: Colors.white,
            ),
            padding: const EdgeInsets.only(right: 20),
            iconSize: 30,
            onPressed: () =>
                Provider.of<TimerService>(context, listen: false).reset(),
          ),
        ],
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
              SizedBox(
                height: 30,
              ),
              TimerController(),
              SizedBox(
                height: 30,
              ),
              OptionsWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
