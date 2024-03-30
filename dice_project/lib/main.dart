import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'rollDice',
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'rollDice'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final double _diceSize = 100;
  double velocity = 10000;
  int _xDirection = 1;
  int _yDirection = 1;
  double _diceOrientation = 0;
  // Untouchable in the beginning so that it can go
  //through the bottom of the screen at the start
  bool? untouchable;
  bool addFriction = false;
  bool roll = false;
  Offset? _dicePosition;
  bool _xImpact = false;
  bool _yImpact = false;
  double friction = 1;
  int? slope;
  Timer? _diceAnimation;
  Timer? _stopingDice;

  get timer => null;

  @override
  Widget build(BuildContext context) {
    _dicePosition ??= Offset(
        (MediaQuery.of(context).size.width - _diceSize) / 2,
        (MediaQuery.of(context).size.height));

    void throwDice(roll) {
      if (roll) {
        setDiceInitialParams(context);
        _diceAnimation =
            Timer.periodic(const Duration(milliseconds: 33), (timer) {
          if (_dicePosition!.dy < MediaQuery.of(context).size.height * 0.5) {
            untouchable = false;
          }

          //Calculate Dice offset per tick
          double _xDistance =
              ((sqrt(velocity / ((slope! ^ 2) + 1))) * _xDirection) *
                  (friction);
          double _yDistance =
              ((sqrt(velocity - (velocity / ((slope! ^ 2) + 1)))) *
                      _yDirection) *
                  (friction);
          setState(() {
            if ((slope! % 2 != 0) && _yDistance > 0) {
              _diceOrientation = -(pi / 2 - atan(_yDistance / _xDistance));
            } else {
              if ((slope! % 2 != 0) && _yDistance < 0) {
                _diceOrientation = -(atan(_yDistance / _xDistance) + pi / 2);
              } else {
                if ((slope! % 2 == 0) && _yDistance < 0) {
                  _diceOrientation = pi - (atan(_xDistance / _yDistance));
                } else {
                  if ((slope! % 2 == 0) && _yDistance > 0) {
                    _diceOrientation = pi / 2 + (atan(_xDistance / _yDistance));
                  }
                }
              }
            }
          });

          setState(
            () {
              //Apply Dice offset
              _dicePosition = Offset(
                  _dicePosition!.dx + _xDistance * (slope! % 2 == 0 ? -1 : 1),
                  _dicePosition!.dy - _yDistance);

              ImpactHandler(context, timer);
              if (sqrt(_xDistance.abs() + _yDistance.abs()) < 0.5) {
                roll = false;
                print('THE DICE IS STOPING ...');
                _diceAnimation!.cancel();

                _stopingDice = Timer(Duration(seconds: 5), () {
                  setState(() {
                    setDiceInitialParams(context);
                  });
                  print('THE DICE IS OFFICIALLY STOPED!');
                });
              }
            },
          );
        });
      } else {
        _diceAnimation!.cancel();
        _stopingDice?.cancel();
        print('THE DICE IS OFFICIALLY STOPED');
        setDiceInitialParams(context);
      }
    }

    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            roll ? Colors.red : Colors.blue)),
                    onPressed: () {
                      setState(() {
                        roll = !roll;
                      });
                      throwDice(roll);
                    },
                    child: Text(
                      !roll ? 'Throw Dice!' : 'Stop',
                      style: TextStyle(color: Colors.white),
                    ))),
          ),
          Positioned(
            left: _dicePosition!.dx,
            top: _dicePosition!.dy,
            child: Container(
                width: _diceSize,
                height: _diceSize,
                child: RotationTransition(
                  turns: AlwaysStoppedAnimation(
                      (_diceOrientation * 180 / pi) / 360),
                  child: Image.asset(
                    "assets/gifs/d6.gif",
                    scale: 0.1,
                  ),
                )),
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void setDiceInitialParams(BuildContext context) {
    _dicePosition = Offset((MediaQuery.of(context).size.width - _diceSize) / 2,
        (MediaQuery.of(context).size.height));
    friction = 1;
    _xImpact = false;
    _yImpact = false;
    _xDirection = 1;
    _yDirection = 1;
    untouchable = true;
    addFriction = false;
    slope = (Random().nextInt(20));
  }

  void ImpactHandler(BuildContext context, timer) {
    if (detectHorizontalImpact(context)) {
      _xDirection = -1 * _xDirection;
      _xImpact = true;
      print('Outch! (x)');
      print(_dicePosition!.dx);
      friction = 1;
    }

    if (detectVerticalImpact(context)) {
      _yDirection = -1 * _yDirection;
      print('Outch! (y)');
      _yImpact = true;
      print(_dicePosition!.dy);
      friction = 1;
    }
    if (detectOutOfImpact(context)) {
      print('Out of Impact');
      addFriction = true;
      _xImpact = false;
      _yImpact = false;
    }
    if (addFriction) {
      friction = 1000 / pow(timer.tick, 3);
    }
  }

  bool detectOutOfImpact(BuildContext context) {
    if ((_dicePosition!.dx < (MediaQuery.of(context).size.width - _diceSize) &&
            (_dicePosition!.dx > 0)) &&
        (_dicePosition!.dy < (MediaQuery.of(context).size.height - _diceSize) &&
            (_dicePosition!.dy > 0)) &&
        (_yImpact || _xImpact)) {
      return true;
    } else {
      return false;
    }
  }

  bool detectVerticalImpact(BuildContext context) {
    if ((_dicePosition!.dy >=
                (MediaQuery.of(context).size.height - _diceSize * 2) ||
            _dicePosition!.dy <= 0) &&
        !_yImpact &&
        !untouchable!) {
      return true;
    } else {
      return false;
    }
  }

  bool detectHorizontalImpact(BuildContext context) {
    if ((_dicePosition!.dx >= (MediaQuery.of(context).size.width - _diceSize) ||
            _dicePosition!.dx <= 0) &&
        !_xImpact) {
      return true;
    } else {
      return false;
    }
  }
}
