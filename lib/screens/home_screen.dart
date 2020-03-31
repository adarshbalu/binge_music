import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibrate/vibrate.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation animation;

  @override
  void initState() {
    super.initState();
    _checkIfVibrate();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );

    animationController.repeat();
  }

  stopRotation() {
    animationController.stop();
  }

  startRotation() {
    animationController.repeat();
  }

  _checkIfVibrate() async {
    canVibrate = await Vibrate.canVibrate;
  }

  _getVibration(feedbackType) async {
    if (canVibrate) {
      Vibrate.feedback(feedbackType);
    }
  }

  bool canVibrate = false;
  IconData icon = Icons.play_arrow;
  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  double value = 0.0;
  @override
  Widget build(BuildContext context) {
    double circleRadius = MediaQuery.of(context).size.width / 3;
    double imageSize = MediaQuery.of(context).size.width / 2;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        body: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: screenHeight / 12,
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'Song Name',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: Text(
              'Artist Name',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w400,
                fontSize: 26,
              ),
            ),
          ),
          SizedBox(
            height: screenHeight / 21,
          ),
          Center(
            child: AnimatedBuilder(
              animation: animationController,
              builder: (BuildContext context, Widget _widget) {
                return Transform.rotate(
                  angle: animationController.value * 6.3,
                  child: _widget,
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: circleRadius,
                child: Image.asset(
                  'assets/music.png',
                  height: imageSize,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                ' 0.00',
                style: TextStyle(color: Colors.white),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.red[700],
                    inactiveTrackColor: Colors.red[100],
                    trackHeight: 2.0,
                    thumbColor: Colors.redAccent,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                    overlayColor: Colors.red.withAlpha(32),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                  ),
                  child: Slider(
                    min: 0,
                    value: value,
                    label: '$value',
                    onChanged: (v) {
                      setState(() {
                        value = v;
                      });
                    },
                  ),
                ),
              ),
              Text(
                '4.02 ',
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: screenWidth / 11,
                ),
                Expanded(
                  child: MaterialButton(
                    splashColor: Color(0xff42002E),
                    shape: CircleBorder(),
                    onPressed: () {
                      print('prev');
                      _getVibration(FeedbackType.light);
                    },
                    child: Icon(
                      Icons.skip_previous,
                      color: Colors.white,
                      size: screenWidth / 7,
                    ),
                  ),
                ),
                Expanded(
                  child: MaterialButton(
                    onPressed: () {
                      print('play');
                      _getVibration(FeedbackType.light);

                      if (icon == Icons.play_arrow) {
                        startRotation();
                        setState(() {
                          icon = Icons.pause;
                        });
                      } else {
                        setState(() {
                          icon = Icons.play_arrow;
                        });

                        stopRotation();
                      }
                    },
                    padding: EdgeInsets.all(10),
                    shape: CircleBorder(),
                    splashColor: Colors.white70,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: screenWidth / 6.5,
                      child: Icon(
                        icon,
                        color: Color(0xff42002E),
                        size: screenWidth / 6.5,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: MaterialButton(
                    //onLongPress: isPlaying ? () => pause() : null,
                    splashColor: Color(0xff42002E),
                    shape: CircleBorder(),
                    onPressed: () {
                      print('nxt');
                      _getVibration(FeedbackType.light);
                    },
                    child: Icon(
                      Icons.skip_next,
                      color: Colors.white,
                      size: screenWidth / 7,
                    ),
                  ),
                ),
                SizedBox(
                  width: screenWidth / 11,
                )
              ],
            ),
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    ));
  }
}
