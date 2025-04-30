import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  double _value = 0.5;  // position of the slider
  bool _left = false;   // is the left button active?

  int _num = 0;         // how many clicks/taps have been measured?
  int _last = 0;        // time of last click/tap
  double _sum = 0.0;    // total sum of click/tap times
  double _avg = 0;      // average of click/tap times

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  var initializationSettings;

  // reset everything to initial state
  void resetState() {
    setState(() {
      _num = 0;
      _sum = 0;
      _avg = 0;
      _last = 0;
    });
  }

  // set the slider position
  void setValue(double value) {
    setState(() {
      _value = value;
    });
  }

  // active button was clicked/tapped, measure time and swap button
  void toggleButton() {
    setState(() {
      _left = !_left;                                   // toggle the active button

      int now = DateTime.now().millisecondsSinceEpoch;  // current time
      int diff = (now - _last);                         // time since previous click/tap 
      _last = now;                                      // current time is new previous time
      print(diff);

      if (diff > 1000) return;                          // ignore everything slower than 1000 ms
      _sum = _sum + diff;                               // add to total sum
      _num++;                                           // increase count
      _avg = _sum / _num;                               // calculate average
    });
  }

  @override
  Widget build(BuildContext context) {

    if (initializationSettings == null) {

      print("init notifiy");
      AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings("@mipmap/ic_launcher"); //"@drawable/app_icon");
      DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();
      LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(defaultActionName: 'Open notification',defaultIcon: AssetsLinuxIcon('res/app_icon.png'));

      initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
        linux: initializationSettingsLinux);
    
      flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: null ); 
    }

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Slider(
              value: _value,
              divisions: 10,
              onChanged: (value) { setValue(value); },
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // force widget size (see https://stackoverflow.com/a/54847521)
                  Container(
                    width: (_value+0.5)*100,
                    height: (_value+0.5)*100,
                    child: ElevatedButton(
                      onPressed: () { if (_left) toggleButton(); },
                      // set color (see https://stackoverflow.com/a/66835254)
                      style: ElevatedButton.styleFrom(backgroundColor: _left ? Colors.red : null),
                      child: Text("😁")
                    ),
                  ),
                  // put some distance between the buttons
                  SizedBox(width: (_value+0.5)*100),
                  Container(
                    width: (_value+0.5)*100,
                    height: (_value+0.5)*100,
                    child: ElevatedButton(
                      onPressed: () { if (!_left) toggleButton(); },
                      // the condition ? value1 : value2 expression is a short form of "if (condition) return value1 else return value2"
                      style: ElevatedButton.styleFrom(backgroundColor: !_left ? Colors.red : null),
                      child: Text("😁"),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height:20),
            // Dart lets you use variable substition in strings using "$"
            Text("Number of clicks: $_num"),
            Text("Average time: $_avg"),
            ElevatedButton(onPressed: () { resetState(); }, child: Text("Reset")),
            ElevatedButton(onPressed: () { 
              const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
              flutterLocalNotificationsPlugin.show(0, 'plain title', 'plain body', notificationDetails, payload: 'item x');
            }, child: Text("Notify")),
          ],
        ),
      ),
    );
  }
}
