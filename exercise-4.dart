import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:shared_preferences/shared_preferences.dart';
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
  
   MapController controller = MapController.withPosition(
    initPosition: GeoPoint(latitude: 57, longitude: 10)
  );

  //final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

  final MarkerIcon icon = MarkerIcon(
    icon: Icon(
      Icons.person_pin_circle,
      color: Colors.blue,
      size: 56,
    ));

  @override
  Widget build(BuildContext context) {
    //asyncPrefs.getString('marker').then((value) { GeoPoint gp = GeoPoint.fromString(value!); print(gp); /*controller.addMarker(gp);*/ });
    controller.listenerMapLongTapping.addListener(() {
      var value = controller.listenerMapLongTapping.value;
      controller.addMarker(
        value!,
        markerIcon: icon,
        iconAnchor: IconAnchor(anchor:Anchor.top)
      );
      //asyncPrefs.setString('marker', "${value.latitude},${value.longitude}");
    });
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
     
    return 
      Material(
        child: Column(
          children: [
            TextField(),
            Flexible( child: OSMFlutter(
              controller: controller, 
              osmOption: OSMOption(
                zoomOption: ZoomOption(initZoom:10)),
                onGeoPointClicked: (gp) { controller.removeMarker(gp);} 
              )
            ),
          ],
        ),
      );
  }
}
