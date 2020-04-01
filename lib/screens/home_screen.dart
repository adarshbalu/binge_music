import 'dart:math';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    getSong();
    super.initState();

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

  IconData icon = Icons.play_arrow;
  List<SongInfo> songs;
  int songsLength;
  String image = 'assets/music.png';
  SongInfo song;

  getSongs() async {
    songs = await audioQuery.getSongs();
    songsLength = songs.length;
    if (songs.isNotEmpty) {
      print('done');
    }
  }

  getSong() async {
    await getSongs();
    SongInfo tempSong;
    tempSong = songs[_random.nextInt(songsLength)];
    song = tempSong;
    print(song.title);
    localPath = song.filePath;
    setState(() {
      artistName = song.artist;
      songName = song.title;
      duration = double.parse(song.duration);
//      image = song.albumArtwork ?? 'assets/music.png';
    });
  }

  String localPath;
  startMusic() async {
    int play = await audioPlayer.play(localPath, isLocal: true);
    if (play == 1) {
      isStart = true;
      getDuration();
    }
  }

  Color color = Colors.transparent;
  playNext() async {
    stopRotation();
    setState(() {
      color = Colors.white;
    });
    audioPlayer.stop();
    audioPlayer.release();
    SongInfo tempSong;
    bool isMusic = false;
    tempSong = songs[_random.nextInt(songsLength)];
    song = tempSong;
    localPath = song.filePath;

    setState(() {
      isPlaying = true;
      artistName = song.artist;
      songName = song.title;
      duration = double.parse(song.duration);
      color = Colors.transparent;
      startRotation();

//      image = song.albumArtwork ?? 'assets/music.png';
    });

    startMusic();
    print(duration);
  }

  bool isStart = false;

  getDuration() async {
    String newDuration = song.duration;
    setState(() {
      duration = double.parse(newDuration);
    });
  }

  double pos = 1;
  getCurrentPosition() async {
    int newPos = await audioPlayer.getCurrentPosition();
    setState(() {
      pos = newPos.ceilToDouble();
    });
  }

  double duration = 500;
  String songName = 'Song Name';
  String artistName = 'Artist Name';
  bool isPlaying = false;
  double value = 0.0;
  final _random = new Random();
  @override
  Widget build(BuildContext context) {
    double circleRadius = MediaQuery.of(context).size.width / 3;
    double imageSize = MediaQuery.of(context).size.width / 1.5;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
//    if (audioPlayer.state == AudioPlayerState.COMPLETED) {
//      playNext();
//    }
    return Scaffold(
        body: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          SizedBox(
            height: 15,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                songName,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Expanded(
            child: Padding(
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
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  if (audioPlayer.state == AudioPlayerState.PLAYING) {
                    audioPlayer.pause();
                    setState(() {
                      isPlaying = false;
                      stopRotation();
                    });
                  } else if (audioPlayer.state == AudioPlayerState.PAUSED) {
                    audioPlayer.resume();
                    setState(() {
                      isPlaying = true;
                      startRotation();
                    });
                  } else if (audioPlayer.state == AudioPlayerState.STOPPED) {
                    startMusic();
                    isPlaying = true;
                    startRotation();
                  } else if (audioPlayer.state == AudioPlayerState.COMPLETED) {
                    playNext();
                    isPlaying = true;
                    startRotation();
                  }
                },
                child: AnimatedBuilder(
                  animation: animationController,
                  builder: (BuildContext context, Widget _widget) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                ' 0:00',
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
                    max: duration > 0 ? duration : 50,
                    value: pos > 0 ? pos : 2,
                    onChanged: (v) {
                      setState(() {});
                    },
                  ),
                ),
              ),
              Text(
                duration.toString(),
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
                            if (audioPlayer.state == AudioPlayerState.PAUSED)
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
                    //onLongPress: isPlaying ? () => pause() : null,
                    splashColor: Color(0xff42002E),
                    shape: CircleBorder(),
                    onPressed: () async {
                      print('nxt');
                      _getVibration(FeedbackType.light);
                      playNext();
//                      await getSongs();
//                      audioPlayer.stop();
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
