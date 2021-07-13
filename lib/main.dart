import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:toast/toast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AudioPlayer _audioPlayer = AudioPlayer();
  late AudioCache cache;

  bool isPlaying = false;
  bool filePathExists = false;

  String crtTime = "0:00:00";
  String cptTime = "0:00:00";

  String songTitle = "...";

  Duration position = new Duration();
  Duration musicLength = new Duration();

  Widget slider() {
    return Slider.adaptive(
        activeColor: Colors.lightBlue,
        inactiveColor: Colors.grey,
        value: position.inSeconds.toDouble(),
        max: musicLength.inSeconds.toDouble(),
        onChanged: (value) {
          seekToSec(value.toInt());
        });
  }

  void seekToSec(int sec) {
    Duration newPos = Duration(seconds: sec);
    _audioPlayer.seek(newPos);
  }

  @override
  void initState() {
    super.initState();

    cache = AudioCache(fixedPlayer: _audioPlayer);

    _audioPlayer.onAudioPositionChanged.listen((Duration duration) {
      setState(() {
        crtTime = duration.toString().split(".")[0];
        position = duration;
        print(position);
      });
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        cptTime = duration.toString().split(".")[0];
        musicLength = duration;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade800,
                Colors.blue.shade200,
              ]),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 48.0),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    "Now playing",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    songTitle,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                SizedBox(
                  height: 24.0,
                ),
                Center(
                  child: Container(
                    width: 280.0,
                    height: 280.0,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage("assets/bg1.gif"),
                    )),
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.0),
                        topRight: Radius.circular(25.0),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text(
                                crtTime,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Text(
                                cptTime,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        slider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.skip_previous_rounded),
                              iconSize: 40.0,
                              color: Colors.lightBlue,
                            ),
                            SizedBox(width: 20),
                            IconButton(
                              onPressed: () {
                                if (isPlaying) {
                                  _audioPlayer.pause();

                                  setState(() {
                                    isPlaying = false;
                                  });
                                } else if (filePathExists && !isPlaying) {
                                  _audioPlayer.resume();

                                  setState(() {
                                    isPlaying = true;
                                  });
                                } else if (!filePathExists && !isPlaying) {
                                  Toast.show("Choose audio file", context,
                                      duration: Toast.LENGTH_LONG,
                                      gravity: Toast.BOTTOM);
                                }
                              },
                              icon: Icon(isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded),
                              iconSize: 40.0,
                              color: Colors.blueAccent,
                            ),
                            SizedBox(width: 20),
                            IconButton(
                              onPressed: () {
                                _audioPlayer.stop();
                                crtTime = "0:00:00";
                                setState(() {
                                  isPlaying = false;
                                });
                              },
                              icon: Icon(Icons.stop_rounded),
                              iconSize: 40.0,
                              color: Colors.blueAccent,
                            ),
                            SizedBox(width: 20),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.skip_next_rounded),
                              color: Colors.lightBlue,
                              iconSize: 40.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.audiotrack_rounded),
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles();
          if (result != null) {
            PlatformFile file = result.files.first;
            songTitle = file.name.toString();

            int status =
                await _audioPlayer.play(file.path.toString(), isLocal: true);
            if (status == 1) {
              setState(() {
                isPlaying = true;
                filePathExists = true;
              });
            } else {
              setState(() {
                isPlaying = false;
                filePathExists = false;
              });
            }
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}
