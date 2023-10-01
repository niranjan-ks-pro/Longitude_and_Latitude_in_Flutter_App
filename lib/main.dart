import 'dart:async';
import 'package:cron/cron.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:geolocator/geolocator.dart';
import 'package:telephony/telephony.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Get curent location',
      // Start the app with the "/" named route. In this case, the app starts
      // on the FirstScreen widget.
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => const FirstScreen(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/second': (context) => MyApp(),
      },
    ),
  );
  final cron = Cron();
  cron.schedule(Schedule.parse('*/1 * * * *'), () async {
    print('CRON JOB');
    print(DateTime.now().millisecondsSinceEpoch);
  });
}

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get GPS Location'),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: ElevatedButton(
          // Within the `FirstScreen` widget
          onPressed: () {
            // Navigate to the second screen using a named route.

            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => Home()),
            );
          },
          child: const Text('Get curent location'),
          ///////SMS Reading Section
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Home());
  }
}

bool loading = true;

class Home extends StatefulWidget {
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
  //sms
  String smsBody = "";
  String smsAddress = "";
  Telephony telephony = Telephony.instance;

  //sms

  @override
  void initState() {
    checkGps();
    super.initState();
    //sms
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        print(message.address); //+977981******67, sender nubmer
        print(message.body); //sms text
        print(message.date); //1659690242000, timestamp
        setState(() {
          smsBody = message.body.toString();
          smsAddress = message.address.toString();
          var mobileNumber = smsAddress;
          if (smsBody == "Where are you") {
            // ignore: unused_local_variable
            print("smsBody contains Where are you");
            var locationUrl = getLatLongURL();
            print("location url ready to send is = " + locationUrl);
            print("location url ready to send to = " + mobileNumber);

            //how to send sms to a given number
            void _sendSMS(String locationUrl, List<String> mobileNumber) async {
              String message = locationUrl;
              List<String> recipents = mobileNumber;
              String _result = await sendSMS(
                      message: locationUrl,
                      recipients: mobileNumber,
                      sendDirect: true)
                  .catchError((onError) {
                print(onError);
              });
              print(_result);
              //how to send sms to a given number
            }
          } else {
            print("smsBody does not contain Where are you");
          }
        });
      },
      listenInBackground: false,
    );
    //sms
  }

  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          print("'Location permissions are permanently denied");
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      if (haspermission) {
        setState(() {
          //refresh the UI
        });

        getLocation();
      }
    } else {
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
      //refresh the UI
    });
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position.longitude); //Output: 80.24599079
    print(position.latitude); //Output: 29.6593457

    long = position.longitude.toString();
    lat = position.latitude.toString();

    setState(() {
      //refresh UI
    });

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 100, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    // ignore: unused_local_variable
    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      print(position.longitude); //Output: 80.24599079
      print(position.latitude); //Output: 29.6593457

      long = position.longitude.toString();
      lat = position.latitude.toString();

      setState(() {
        //refresh UI on update
      });
    });
  }

  //return latlong

  getLatLongURL() {
    //List LatAndLong = getLocation();

    var url = "http://maps.google.com/maps?z=12&t=m&q=";
    getLocation();
    var urlFull = url + lat + "," + long;
    print(urlFull);
    return urlFull;
  }

  //return latlong
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text("Curent location and SMS Listener"),
          backgroundColor: Colors.redAccent,
        ),
        body: Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
          child: Column(
            //sms
            crossAxisAlignment: CrossAxisAlignment.start,
            //sms
            children: [
              Text(haspermission ? "GPS is Enabled" : "GPS is disabled."),
              const Divider(),
              Text("Your current Longitude: $long",
                  style: const TextStyle(fontSize: 20)),
              Text("Your current Latitude : $lat",
                  style: const TextStyle(fontSize: 20)),
              const Divider(),
              //sms
              const Text(
                "Recieved SMS Text:",
                style: TextStyle(fontSize: 25),
              ),
              Text(
                "SMS Text: " + smsBody,
                style: TextStyle(fontSize: 20),
              ),
              Text(
                " From: " + smsAddress,
                style: TextStyle(fontSize: 20),
              )
            ],
            //sms
          ),
        ));
  }
}
