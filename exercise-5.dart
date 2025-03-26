// in pubspec.yaml:
//
// under "dependencies", add:
//   audioplayers: ^6.4.0
//
// under "flutter", add:
//   assets:
//    - assets/sounds/fanfare.mp3
//    - assets/sounds/wahwahwah.mp3

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
  // current number in sequence (-1 means playback is stopped)
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
      // create new random numbers as long as we get the same one as before
      while (newnum == oldnum) {
        newnum = rand.nextInt(4);
      }
      // if we have a new number, add it to the list
      sequence.add(newnum);
      oldnum = newnum;
    }
  }

  // start the replay of the color sequence
  void start() {
    setState(() {
      current = -1;
      status = "Memorize the color sequence";
      label = "Wait...";
      // in one second from now, call next()
      Timer(const Duration(seconds: 1), next );
    });
  }

  // step through the next item in the sequence
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
    // not at the end yet, continue counting and call next() again in 1s
    setState(() {
      current++;
      Timer(const Duration(seconds: 1), next );
    });
  }

  // keyboard input and text highlighting

  // log a guess made through tapping one of the buttons
  void guess(id) {

    // if the "preview" is running, don't log any guesses
    if (current != -1) return;

    // wrap everything in setState because we need a redraw after
    setState(() {

      // add button id to list of guesses
      guesses.add(id);

      // loop through guesses and compare with original sequence
      int maxGuess = 0;
      for (int i = 0; i < guesses.length && i < sequence.length; i++) {
        int hint = sequence[i];
        int myguess = guesses[i];
        // stop the loop if the guess was wrong
        if (hint != myguess) { maxGuess = -1; break; }
        // all guesses up to the current position (i) are correct
        maxGuess = i;
      }

      status = "You guessed ${maxGuess+1} steps correctly!";
      
      // are all guesses up to the end of the sequence correct?
      if (maxGuess == sequence.length-1) { 
        status = "You won!";
        player.play(AssetSource("sounds/fanfare.mp3"));
      }
      
      // or did we stop because of a wrong guess?
      if (maxGuess == -1) {
        status = "You guessed wrong!";
        player.play(AssetSource("sounds/wahwahwah.mp3"));
      }      
    });
  }

  // get color for the currently active button, grey for all others
  Color getColor(int id) {
    // make all buttons grey during the guessing phase
    if (current == -1) return Colors.grey;
    Color buttonColor = colors[id];
    // if the current sequence entry matches the button id, give it a colour
    if (sequence[current] == id) return buttonColor;
    // keep it grey otherwise
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
                // Buttons are wrapped in Expanded so they fill the screen width
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
