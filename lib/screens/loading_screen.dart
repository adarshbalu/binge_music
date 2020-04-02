import 'package:bingemusic/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibrate/vibrate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    checkPermissions();
    _checkIfVibrate();
  }

  checkPermissions() async {
    if (await Permission.storage.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
    }

// You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();
    print(statuses[Permission.storage]);
  }

  _checkIfVibrate() async {
    canVibrate = await Vibrate.canVibrate;
  }

  bool canVibrate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Text(
                  'Binge Music',
                  style: TextStyle(
                      fontSize: 60, color: Colors.white, fontFamily: 'satisfy'),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                width: 260,
                child: TypewriterAnimatedTextKit(
                    totalRepeatCount: 4,
                    speed: Duration(milliseconds: 500),
                    pause: Duration(milliseconds: 1000),
                    text: [
                      'The Music Player',
                      'Minimal Music',
                    ],
                    textStyle: TextStyle(
                        fontSize: 30.0,
                        color: Colors.white,
                        fontFamily: "satisfy"),
                    textAlign: TextAlign.start,
                    alignment:
                        AlignmentDirectional.topStart // or Alignment.topLeft
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
