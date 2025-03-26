import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String status = 'Push the button to start!';
  // sequence for buttons to light up
  List<int> sequence = [0,2,1,3,0,1,2,3,2,1,0];
  // sequence guessed by the player
  List<int> guesses = [];
  // colors for buttons numbered from 0 - 3
  List<Color> colors = [Colors.red, Colors.green, Colors.yellow, Colors.blue];
  // current number in sequence
  int current = 0;

  void start() {
    setState(() {
      current = 0;
      status = "Memorize the color sequence";
      Timer(const Duration(seconds: 1), next );
    });
    print(guesses);
  }

  void next() {
    if (current >= sequence.length-1) {
      setState(() { status = "Repeat the color sequence!"; });
      return;
    }
    setState(() {
      current++;
      Timer(const Duration(seconds: 1), next );
    });
    //print(current);
  }

  Color getColor(int id) {
    Color currentButton = colors[id];
    if (sequence[current] == id) return currentButton;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(children: [
              MaterialButton(onPressed: (){ guesses.add(0); }, height: 200, minWidth: 180, color: getColor(0)),
              MaterialButton(onPressed: (){ guesses.add(1); }, height: 200, minWidth: 180, color: getColor(1)),
            ],),
            Row(children: [
              MaterialButton(onPressed: (){ guesses.add(2); }, height: 200, minWidth: 180, color: getColor(2)),
              MaterialButton(onPressed: (){ guesses.add(3); }, height: 200, minWidth: 180, color: getColor(3)),
            ],),
            Text(status),
            MaterialButton( onPressed: start, color: Colors.blueGrey, child: Text("Start!"))
          ],
        ),
      ),
    );
  }
}
