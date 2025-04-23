// in android/app/src/main/AndroidManifest.xml, add <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR KEY HERE"/> in <application>

// dependencies:
//   google_maps_flutter: ^2.12.0
//   shared_preferences: ^2.5.0

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // starting point for map: GooglePlex in San Francisco
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  // object for saving preferences for next app start
  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

  int _counter = 0;
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  Random rng = Random();

  @override
  void initState() {
    super.initState();
    // get the list of saved markers
    asyncPrefs.getStringList("markers").then((value) {
      // don't do anything if there are no saved markers
      if (value == null) return;
      // put list of markers into our list variable and trigger a redraw by using setState()
      setState(() {
        for (String pos in value) {
          // debug output
          print(pos);
          // convert JSON lat/lng to LatLng object
          LatLng? tmp = LatLng.fromJson(jsonDecode(pos));
          // skip on conversion error
          if (tmp == null) continue;
          // add marker to list, don't sync with shared_prefs
          addMarker(tmp, do_sync: false);
        } 
      });
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void removeMarker(MarkerId id) {
    setState(() {
      _markers.remove(id);
    });
  }

  void addMarker(LatLng pos, { bool do_sync = true }) {
    setState(() {
      // create a random marker identifier
      int tmp_num = rng.nextInt(1000000);
      MarkerId tmp_id = MarkerId("$tmp_num");
      // store a new marker with the identifier into our map
      _markers[tmp_id] = Marker(
        markerId: tmp_id,
        position: pos,
        onTap: () => removeMarker(tmp_id)
      );
      // check if we need to sync list of markers with shared_prefs
      if (!do_sync) return;
      // store every marker as JSON into a string list
      List<String> result = [];
      for (Marker marker in _markers.values) {
        result.add(marker.position.toJson().toString());
      }
      // put list into preferences
      asyncPrefs.setStringList("markers",result);
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // wrap map widget in flexible so it doesn't expand too much
            Flexible( child: GoogleMap(
              initialCameraPosition: _kGooglePlex,      // starting position of map
              markers: Set<Marker>.of(_markers.values), // convert marker map to set
              onLongPress: addMarker                    // what to do on long press
            )),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
