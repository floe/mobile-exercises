import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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

  // prompt for the user
  String status = 'Push the button to start!';
  // button label
  String label = "Start!";
  // sequence for buttons to light up
  List<int> sequence = [0,2,1,3,0,1,2,3,2,1,0];
  // sequence guessed by the player
  List<int> guesses = [];
  // colors for buttons numbered from 0 - 3
  List<Color> colors = [Colors.red, Colors.green, Colors.yellow, Colors.blue];
  // current number in sequence
  int current = -1;
  // sequence length
  int maxlength = 10;

  // audioplayer
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    sequence.clear();
    var rand = Random();
    int oldnum = -1;
    int newnum = -1;
    for (int i = 0; i < maxlength; i++) {
      while (newnum == oldnum) {
        newnum = rand.nextInt(4);
      }
      sequence.add(newnum);
      oldnum = newnum;
    }
  }

  void start() {
    setState(() {
      // start the replay of the color sequence
      current = -1;
      status = "Memorize the color sequence";
      label = "Wait...";
      // in one second from now, call next()
      Timer(const Duration(seconds: 1), next );
    });
  }

  void next() {
    // are we at the end of the sequence?
    if (current >= sequence.length-1) {
      // reset the guesses and prompt text
      setState(() { 
        status = "Repeat the color sequence!";
        label = "Restart";
        current = -1;
        guesses.clear();
      });
      return;
    }
    // not at the end yet, continue counting
    setState(() {
      current++;
      Timer(const Duration(seconds: 1), next );
    });
  }

  // - play sounds ✅
  // - make the user interface look nicer ✅
  // - generate a random sequence ✅
  // - show a message when you guess wrong ✅

  void guess(id) {
    if (current != -1) return;
    setState(() {
      guesses.add(id);
      int maxGuess = 0;
      for (int i = 0; i < guesses.length && i < sequence.length; i++) {
        int hint = sequence[i];
        int myguess = guesses[i];
        if (hint != myguess) { maxGuess = -1; break; }
        maxGuess = i;
      }
      status = "You guessed ${maxGuess+1} steps correctly!";
      if (maxGuess == sequence.length-1) { 
        status = "You won!";
        player.play(AssetSource("sounds/fanfare.mp3"));
      }
      if (maxGuess == -1) {
        status = "You guessed wrong!";
        //player.play(AssetSource("sounds/wahwahwah.mp3"));
      }      
    });
  }

  // get color for the currently active button, grey for all others
  Color getColor(int id) {
    if (current == -1) return Colors.grey;
    Color buttonColor = colors[id];
    if (sequence[current] == id) return buttonColor;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded( child: MaterialButton(onPressed: (){ guess(0); }, height: 200, minWidth: 180, color: getColor(0), splashColor: colors[0] )),
                Expanded( child: MaterialButton(onPressed: (){ guess(1); }, height: 200, minWidth: 180, color: getColor(1), splashColor: colors[1] )),
            ],),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded( child: MaterialButton(onPressed: (){ guess(2); }, height: 200, minWidth: 180, color: getColor(2), splashColor: colors[2] )),
                Expanded( child: MaterialButton(onPressed: (){ guess(3); }, height: 200, minWidth: 180, color: getColor(3), splashColor: colors[3] )),
            ],),
            Text(status),
            MaterialButton( onPressed: start, color: Colors.blueGrey, child: Text(label))
          ],
        ),
      ),
    );
  }
}
