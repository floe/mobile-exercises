import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// based on https://stackoverflow.com/a/46246111
class SignaturePainter extends CustomPainter {
  SignaturePainter(this.points);

  List<List<Offset>> points;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;
    for (var stroke in points) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) {
    return true; //oldDelegate.points != points;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  
  int _counter = 0;
  List<List<Offset>> _points = [[]];
  
  // figure out the actual size of the canvas/gesturedetector after layout
  GlobalKey key = GlobalKey(); // key (will be assigned to gesturedetector)

  void _clear() {
    setState(() {
      _counter++;
      _points = [[]];
    });
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
          //mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text( 'Top Headline Text' ),
            Flexible( child: Stack( children: <Widget>[
              CustomPaint( painter: SignaturePainter(_points)),
              GestureDetector( 
                key: key, 
                onPanUpdate: (DragUpdateDetails details) {
                  // check if we are inside the canvas bounds
                  RenderBox rb = key.currentContext?.findRenderObject() as RenderBox;
                  if (!rb.size.contains(details.localPosition)) return;
                  // if yes, append point to most recent stroke
                  setState(() { _points.last.add(details.localPosition); });
                },
                // append a new empty stroke list to the list of strokes
                onPanEnd: (DragEndDetails details) { setState(() { _points.add([]); }); }, 
              ),
            ])),
            Text( 'You have cleared the canvas $_counter times.' ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clear,
        tooltip: 'Clear',
        child: const Icon(Icons.delete),
      ),
    );
  }
}
