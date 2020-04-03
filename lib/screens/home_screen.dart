import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibrate/vibrate.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation animation;
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  AudioPlayer audioPlayer = AudioPlayer();
  @override
  void initState() {
    super.initState();
    checkPermissions();
    _checkIfVibrate();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );
    animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    audioPlayer.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  stopRotation() {
    animationController.stop();
  }

  startRotation() {
    animationController.repeat();
  }

  _getVibration(feedbackType) async {
    Vibrate.feedback(feedbackType);
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

  IconData icon = Icons.play_arrow;
  List<SongInfo> songs;
  int songsLength;
  String image = 'assets/music.png';
  SongInfo song;
  double tempDuration;
  double tempSeconds;
  double tempMinutes;
  String localPath;
  bool isStart = false;
  Duration songDuration;
  double duration = 500;
  String songName = 'Song Name';
  String artistName = 'Artist Name';
  bool isPlaying = false;
  double value = 0.0;
  final _random = new Random();
  int startSeconds = 0;
  int endSeconds = 0;
  bool loaded = false;
  Color color = Colors.transparent;
  bool firstRun = false;

  // ignore: missing_return
  Future<SongInfo> getSongs() async {
    if (!loaded) {
      print('load songs');
      songs = await audioQuery.getSongs();
      songsLength = songs.length;
      loaded = true;
      print('done');
    }
    if (songs.isNotEmpty) {
      if (audioPlayer.state == AudioPlayerState.PAUSED ||
          audioPlayer.state == AudioPlayerState.PLAYING) {
        return song;
      } else if (audioPlayer.state == AudioPlayerState.COMPLETED) {
        playNext();
        return song;
      } else if (audioPlayer.state == AudioPlayerState.STOPPED) {
        startMusic();
        return song;
      } else {
        song = songs[_random.nextInt(songsLength)];
        localPath = song.filePath;
        setState(() {
          artistName = song.artist;
          songName = song.artist;
        });
        audioPlayer.setUrl(localPath, isLocal: true);
        return song;
      }
    }
  }

  startMusic() async {
    int play = await audioPlayer.play(localPath, isLocal: true);
    tempDuration = double.parse(song.duration);
    tempSeconds = (tempDuration / 1000);
    tempMinutes = tempDuration / 60000;
    if (play == 1) {
      isStart = true;
      setState(() {
        songDuration = Duration(
            seconds: tempSeconds.toInt(), minutes: tempMinutes.toInt());
      });
    }
  }

  playNext() async {
    audioPlayer.stop();
    stopRotation();
    setState(() {
      color = Colors.white;
    });
    do {
      song = songs[_random.nextInt(songsLength)];
    } while (!song.isMusic ||
        song.isNotification ||
        song.isAlarm ||
        song.isPodcast ||
        song.isRingtone);
    setState(() {
      localPath = song.filePath;
      isPlaying = true;
      artistName = song.artist;
      songName = song.title;
      color = Colors.transparent;
      startRotation();
    });
    startMusic();
  }

  @override
  Widget build(BuildContext context) {
    double circleRadius = MediaQuery.of(context).size.width / 3;
    double imageSize = MediaQuery.of(context).size.width / 1.5;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
          child: FutureBuilder(
              future: getSongs(),
              builder: (context, futureSnapshot) {
                if (futureSnapshot.hasData) {
                  if (audioPlayer.state == AudioPlayerState.COMPLETED) {
                    playNext();
                    return LoadScreen();
                  } else
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        SizedBox(
                          height: 15,
                        ),
                        SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  songName,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5.0),
                                child: Text(
                                  artistName,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                if (audioPlayer.state ==
                                    AudioPlayerState.PLAYING) {
                                  audioPlayer.pause();
                                  setState(() {
                                    isPlaying = false;
                                    stopRotation();
                                  });
                                } else if (audioPlayer.state ==
                                    AudioPlayerState.PAUSED) {
                                  audioPlayer.resume();
                                  setState(() {
                                    isPlaying = true;
                                    startRotation();
                                  });
                                } else if (audioPlayer.state ==
                                    AudioPlayerState.COMPLETED) {
                                  playNext();
                                  isPlaying = true;
                                  startRotation();
                                } else {
                                  startMusic();
                                  isPlaying = true;
                                  startRotation();
                                }
                              },
                              child: AnimatedBuilder(
                                animation: animationController,
                                builder:
                                    (BuildContext context, Widget _widget) {
                                  return Transform.rotate(
                                    angle: animationController.value * 6.3,
                                    child: _widget,
                                  );
                                },
                                child: CircleAvatar(
                                  backgroundColor: color,
                                  radius: circleRadius,
                                  child: Image.asset(
                                    image,
                                    width: imageSize,
                                    height: imageSize,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        StreamBuilder<Duration>(
                            stream: audioPlayer.onAudioPositionChanged,
                            builder: (context, snapshot) {
                              String startSecond;
                              startSecond = ' ';
                              if (snapshot.hasData) {
                                if (audioPlayer.state ==
                                    AudioPlayerState.COMPLETED) playNext();
                                startSeconds = snapshot.data.inSeconds;
                                if (startSeconds > 59) {
                                  startSeconds = startSeconds -
                                      snapshot.data.inMinutes * 60;
                                } else if (startSeconds < 10) {
                                  startSecond = startSeconds.toString() + '0';
                                }
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      snapshot.data.inMinutes.toString() +
                                          ':' +
                                          startSeconds.toString(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          activeTrackColor: Colors.red[700],
                                          inactiveTrackColor: Colors.red[100],
                                          trackHeight: 3.0,
                                          thumbColor: Colors.redAccent,
                                          thumbShape: RoundSliderThumbShape(
                                              enabledThumbRadius: 12.0),
                                          overlayColor:
                                              Colors.red.withAlpha(32),
                                          overlayShape: RoundSliderOverlayShape(
                                              overlayRadius: 24.0),
                                        ),
                                        child: Slider(
                                          min: 0,
                                          max: double.parse(song.duration) > 0
                                              ? double.parse(song.duration)
                                              : 500,
                                          value: snapshot.data.inMilliseconds
                                                      .ceilToDouble() >
                                                  Duration(seconds: 0)
                                                      .inMilliseconds
                                                      .ceilToDouble()
                                              ? snapshot.data.inMilliseconds
                                                  .ceilToDouble()
                                              : 200,
                                          onChanged: (v) {
                                            stopRotation();
                                            setState(() {
                                              isPlaying = false;
                                            });
                                            audioPlayer.pause();
                                            audioPlayer.seek(Duration(
                                                milliseconds: v.toInt()));
                                            audioPlayer.resume();
                                            startRotation();
                                            setState(() {
                                              isPlaying = true;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                if (audioPlayer.state ==
                                    AudioPlayerState.COMPLETED) playNext();
                                return Row(
                                  children: <Widget>[
                                    Text('0:0',
                                        style: TextStyle(color: Colors.white)),
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          activeTrackColor: Colors.red[700],
                                          inactiveTrackColor: Colors.red[100],
                                          trackHeight: 3.0,
                                          thumbColor: Colors.redAccent,
                                          thumbShape: RoundSliderThumbShape(
                                              enabledThumbRadius: 12.0),
                                          overlayColor:
                                              Colors.red.withAlpha(32),
                                          overlayShape: RoundSliderOverlayShape(
                                              overlayRadius: 24.0),
                                        ),
                                        child: Slider(
                                          onChanged: (v) {},
                                          min: 0,
                                          max: 50,
                                          value: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                            }),
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
                                    print('repeat');
                                    _getVibration(FeedbackType.light);
                                    audioPlayer.stop();
                                    setState(() {
                                      isPlaying = false;
                                    });
                                    stopRotation();
                                    startMusic();
                                    setState(() {
                                      isPlaying = true;
                                    });
                                    startRotation();
                                  },
                                  child: Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: screenWidth / 7,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: !isPlaying
                                    ? MaterialButton(
                                        onPressed: () async {
                                          _getVibration(FeedbackType.light);
                                          startRotation();
                                          print('playing');
                                          if (audioPlayer.state ==
                                              AudioPlayerState.PAUSED)
                                            audioPlayer.resume();
                                          else
                                            await startMusic();
                                          setState(() {
                                            isPlaying = true;
                                          });
                                        },
                                        padding: EdgeInsets.all(10),
                                        shape: CircleBorder(),
                                        splashColor: Colors.white70,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: screenWidth / 6.5,
                                          child: Icon(
                                            Icons.play_arrow,
                                            color: Color(0xff42002E),
                                            size: screenWidth / 6.5,
                                          ),
                                        ),
                                      )
                                    : MaterialButton(
                                        onPressed: () async {
                                          print('pause');
                                          audioPlayer.pause();
                                          _getVibration(FeedbackType.light);
                                          stopRotation();
                                          setState(() {
                                            isPlaying = false;
                                          });
                                        },
                                        padding: EdgeInsets.all(10),
                                        shape: CircleBorder(),
                                        splashColor: Colors.white70,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: screenWidth / 6.5,
                                          child: Icon(
                                            Icons.pause,
                                            color: Color(0xff42002E),
                                            size: screenWidth / 6.5,
                                          ),
                                        ),
                                      ),
                              ),
                              Expanded(
                                child: MaterialButton(
                                  splashColor: Color(0xff42002E),
                                  shape: CircleBorder(),
                                  onPressed: () async {
                                    print('nxt');
                                    _getVibration(FeedbackType.light);
                                    playNext();
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
                    );
                } else {
                  return LoadScreen();
                }
              })),
    );
  }
}

class LoadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
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
                    fontSize: 30.0, color: Colors.white, fontFamily: "satisfy"),
                textAlign: TextAlign.start,
                alignment: AlignmentDirectional.topStart // or Alignment.topLeft
                ),
          ),
        ],
      ),
    );
  }
}

class Song{
  SongInfo song;
  String songName;
  String artistName;
  String albumArt;

  Song({this.song,this.songName,this.artistName,});
}
