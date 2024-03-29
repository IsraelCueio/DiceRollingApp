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
      title: 'RollingDice',
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
      home: const MyHomePage(title: 'RollingDice'),
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
  final double _diceSize = 50;
  double velocity = 400;
  int _xDirection = 1;
  int _yDirection = 1;
  bool rolling = false;
  Offset? _dicePosition;
  double? friction;
  bool conflicted = false;
  
  
  @override
  
  Widget build(BuildContext context) {
    _dicePosition ??= Offset(
        (MediaQuery.of(context).size.width - _diceSize) / 2,
        (MediaQuery.of(context).size.height - _diceSize) / 2);
    void throwDice(){
      friction = 1;
      int slope = (Random().nextInt(5 + 1) + 2);
    Timer.periodic(const Duration(milliseconds: 33), (timer) { 
      double _xDistance = ((sqrt(velocity / ((slope ^ 2) + 1)))*_xDirection)*(friction!.toDouble());
      double _yDistance = ((sqrt(velocity - (velocity / ((slope ^ 2) + 1))))*_yDirection)*(friction!.toDouble());
      setState(() {
        _dicePosition = Offset(_dicePosition!.dx + _xDistance,
            _dicePosition!.dy - _yDistance);
            print(conflicted);
            if((_dicePosition!.dx >=(MediaQuery.of(context).size.width - _diceSize)||_dicePosition!.dx <=0)&&!conflicted){
              _xDirection = -1*_xDirection;
              friction = 1;
              conflicted = true;
            } 
            if((_dicePosition!.dx <(MediaQuery.of(context).size.width - _diceSize)&&(_dicePosition!.dx >0))&&conflicted){
              
              friction = 5/timer.tick.toInt();
              conflicted = false;
            }
            if((_dicePosition!.dy >=(MediaQuery.of(context).size.height - _diceSize*2) ||_dicePosition!.dy <=0)&&!conflicted){
              _yDirection = -1*_yDirection;
              friction = 1;
              conflicted = true;
            }
            if((_dicePosition!.dy <(MediaQuery.of(context).size.height - _diceSize)&&(_dicePosition!.dy >0))&&conflicted){
              friction = 5/timer.tick.toInt();
              conflicted = false;
            }
            if(_xDistance.abs() <0.1&&_yDistance.abs() <0.1 &&rolling){
              timer.cancel();
              print('stoping ...');
              Timer(Duration(seconds: 5), () {
                
                stopRolling(timer, context); });
              
            }
      });
      if(!rolling){
        stopRolling(timer, context);
      }
    });
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
          Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                  style: ButtonStyle(
                      padding: MaterialStatePropertyAll(
                          EdgeInsets.only(bottom: 20))),
                  onPressed: () {
                    setState(() {
                      rolling = !rolling;
                      throwDice();
                    });
                    
                    
                    
                  },
                  child: Text(!rolling?'Throw Dice!':'Stop'))),
          Positioned(
            left: _dicePosition!.dx,
            top: _dicePosition!.dy,
            child: Container(
              width: _diceSize,
              height: _diceSize,
              decoration: BoxDecoration(color: Colors.blue),
            ),
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void stopRolling(Timer timer, BuildContext context) {
    setState(() {
      conflicted = false;
      velocity = 400;
    rolling = false;
    _dicePosition = Offset(
    (MediaQuery.of(context).size.width - _diceSize) / 2,
    (MediaQuery.of(context).size.height - _diceSize) / 2);
    _xDirection =1;
    _yDirection =1;
    friction = 1;
    });
    print("STOPPP!");
    timer.cancel();
    timer.cancel;
  }
}
