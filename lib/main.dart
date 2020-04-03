import 'package:bingemusic/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Binge Music',
      theme: ThemeData(
        fontFamily: 'OpenSans',
        scaffoldBackgroundColor: Color(0xff42002E),
      ),
      home: HomeScreen(),
    );
  }
}
