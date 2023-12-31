# Longitude_and_Latitude_in_Flutter_App
 https://www.fluttercampus.com/guide/212/get-gps-location/
How to Get Current GPS Location: Longitude and Latitude in Flutter App
======================================================================

In this example, we are going to show you how to get the current GPS geolocation i.e. Longitude and Latitude in Flutter App. We have also shown how to listen to GPS Location: Longitude and Latitude change automatically. See the example:

First, you need to add [geolocator](https://pub.dev/packages/geolocator) Flutter package in your project by adding the following lines in pubspect.yaml file.

```
dependencies:
  flutter:
    sdk: flutter
  geolocator: ^8.0.0
```

Add this permission on AndroidManifest.xml file located at android/app/src/main/AndroidManifest.xml

```
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

Import:

```
import 'package:geolocator/geolocator.dart';
```

[ How to check if GPS is enabled:](https://www.fluttercampus.com/guide/212/get-gps-location/#how-to-check-if-gps-is-enabled)
----------------------------------------------------------------------------------------------------------------------------

```
bool servicestatus = await Geolocator.isLocationServiceEnabled();

if(servicestatus){
   print("GPS service is enabled");
}else{
   print("GPS service is disabled.");
}
```

You can check if the GPS service is enabled or disabled using the asynchronous method `Geolocator.isLocationServiceEnabled();`

[ How to check Location Permission or Request Location Permission:](https://www.fluttercampus.com/guide/212/get-gps-location/#how-to-check-location-permission-or-request-location-permission)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

```
LocationPermission permission = await Geolocator.checkPermission();

if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
    }else if(permission == LocationPermission.deniedForever){
        print("'Location permissions are permanently denied");
    }else{
        print("GPS Location service is granted");
    }
}else{
    print("GPS Location permission granted.");
}
```

You can check for permission with `Geolocator.checkPermission()` or request permission `Geolocator.requestPermission()` if the permission was not granted.

```
Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
print(position.longitude); //Output: 80.24599079
print(position.latitude); //Output: 29.6593457

String long = position.longitude.toString();
String lat = position.latitude.toString();
```

You can get current GPS locations such as Longitude and Latitude with `Geolocator.getCurrentPosition()`.

[ How to Listen to GPS Location: Longitude and Latitude Change Stream:](https://www.fluttercampus.com/guide/212/get-gps-location/#how-to-listen-to-gps-location-longitude-and-latitude-change-stream)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

```
import 'dart:async';
```

```
LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 100, //minimum distance (measured in meters) a
                            //device must move horizontally before an update event is generated;
);

StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings).listen((Position position) {
      print(position.longitude); //Output: 80.24599079
      print(position.latitude); //Output: 29.6593457

      String long = position.longitude.toString();
      String lat = position.latitude.toString();
});
```

Here, the Geolocator will automatically send you data on Location change. 

[ Full Flutter/Dart App Code Example:](https://www.fluttercampus.com/guide/212/get-gps-location/#full-flutter-dart-app-code-example)
------------------------------------------------------------------------------------------------------------------------------------

```
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
     return MaterialApp(
         home: Home()
      );
  }
}

class Home extends  StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
       String long = "", lat = "";
  late StreamSubscription<Position> positionStream;

   @override
  void initState() {
    checkGps();
    super.initState();
  }

  checkGps() async {
      servicestatus = await Geolocator.isLocationServiceEnabled();
      if(servicestatus){
            permission = await Geolocator.checkPermission();

            if (permission == LocationPermission.denied) {
                permission = await Geolocator.requestPermission();
                if (permission == LocationPermission.denied) {
                    print('Location permissions are denied');
                }else if(permission == LocationPermission.deniedForever){
                    print("'Location permissions are permanently denied");
                }else{
                   haspermission = true;
                }
            }else{
               haspermission = true;
            }

            if(haspermission){
                setState(() {
                  //refresh the UI
                });

                getLocation();
            }
      }else{
        print("GPS Service is not enabled, turn on GPS location");
      }

      setState(() {
         //refresh the UI
      });
  }

  getLocation() async {
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print(position.longitude); //Output: 80.24599079
      print(position.latitude); //Output: 29.6593457

      long = position.longitude.toString();
      lat = position.latitude.toString();

      setState(() {
         //refresh UI
      });

      LocationSettings locationSettings = LocationSettings(
            accuracy: LocationAccuracy.high, //accuracy of the location data
            distanceFilter: 100, //minimum distance (measured in meters) a
                                 //device must move horizontally before an update event is generated;
      );

      StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
            locationSettings: locationSettings).listen((Position position) {
            print(position.longitude); //Output: 80.24599079
            print(position.latitude); //Output: 29.6593457

            long = position.longitude.toString();
            lat = position.latitude.toString();

            setState(() {
              //refresh UI on update
            });
      });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
         appBar: AppBar(
            title: Text("Get GPS Location"),
            backgroundColor: Colors.redAccent
         ),
          body: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(50),
             child: Column(
                children: [

                     Text(servicestatus? "GPS is Enabled": "GPS is disabled."),
                     Text(haspermission? "GPS is Enabled": "GPS is disabled."),

                     Text("Longitude: $long", style:TextStyle(fontSize: 20)),
                     Text("Latitude: $lat", style: TextStyle(fontSize: 20),)

                ]
              )
          )
    );
  }
}
```

[ Output Screenshot:](https://www.fluttercampus.com/guide/212/get-gps-location/#output-screenshot)
--------------------------------------------------------------------------------------------------

![](https://www.fluttercampus.com/img/uploads/web/2021/12/afdec7005cc9f14302cd0474fd0f3c96.webp)

