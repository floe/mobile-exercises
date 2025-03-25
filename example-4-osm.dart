// dependencies:
//   flutter_osm_plugin: ^1.3.0
//   shared_preferences: ^2.5.0

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:flutter_osm_plugin/flutter_osm_plugin.dart";

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

  // list of all current markers, described as strings
  List<String> markers = [];
  bool firstRun = true;
  
  // a map controller that starts out centered on Aalborg
  final MapController controller = MapController.withPosition(
      initPosition: GeoPoint(latitude: 57, longitude: 10)
    );

  // object for saving preferences for next app start
  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

  // the icon we'll be using for the map markers
  final MarkerIcon icon = MarkerIcon(
    icon: Icon(
      Icons.person_pin_circle,
      color: Colors.blue,
      size: 56,
  ));
  
  @override
  void initState() {
    super.initState();
    // get the list of saved markers
    asyncPrefs.getStringList("markers").then((value) {
      // don't do anything if there are no saved markers
      if (value == null) return;
      // put list of markers into our list variable and trigger a redraw by using setState()
      setState(() { markers = value; });
      // debug output
      print(value);
    });
  }

  // add a single marker to the map
  void addMarker(GeoPoint gp) {
    controller.addMarker(
      // marker position
      gp,
      // marker icon
      markerIcon: icon,
      // how to position the icon (on top of the GeoPoint)
      iconAnchor: IconAnchor(anchor:Anchor.top)
    );
  }

  @override
  Widget build(BuildContext context) {

    // we need to wait for the first run of the build method before we can add the saved markers,
    // otherwise the controller object might not yet have been initialized
    if (firstRun && markers.isNotEmpty) {
      // loop through all markers
      for (var str in markers) {
        // convert to GeoPoint
        GeoPoint gp = GeoPoint.fromString(str);
        // add to map
        addMarker(gp);
      }
      // only do this once
      firstRun = false;
    }
    
    // listen for long taps on the map
    controller.listenerMapLongTapping.addListener(() {
      // the GeoPoint that has been tapped
      var value = controller.listenerMapLongTapping.value;
      // add to map
      addMarker(value!);
      // add to marker string list
      markers.add("${value.latitude},${value.longitude}");
      // save updated list
      asyncPrefs.setStringList("markers",markers);
    });

    return 
      Material(
        child: Column(
          children: [
            // dummy TextField to show combination with other widgets
            TextField(),
            // wrap OSMFlutter in a Flexible widget so it doesn't expand infinitely
            Flexible( child: OSMFlutter(
              controller: controller, 
              osmOption: OSMOption(
                // set initial zoom level
                zoomOption: ZoomOption(initZoom:10)),
                // a marker has been clicked, remove it
                onGeoPointClicked: (gp) {
                  // remove the marker from the map
                  controller.removeMarker(gp);
                  // remove the marker from the string list
                  markers.remove("${gp.latitude},${gp.longitude}");
                  // save the updated list
                  asyncPrefs.setStringList("markers",markers);
                } 
              )
            ),
          ],
        ),
      );
  }
}
