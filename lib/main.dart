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
  bool isPlaying = false;
  bool filePathExists = false;

  String crtTime = "0:00:00";
  String cptTime = "0:00:00";

  @override
  void initState() {
    super.initState();
    
    _audioPlayer.onAudioPositionChanged.listen((Duration duration) {
      setState(() {
        crtTime = duration.toString().split(".")[0];
      });
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        cptTime  = duration.toString().split(".")[0];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Stack(
        children: [
          Image.asset(
            "assets/bg1.gif",
            fit: BoxFit.contain,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 80,
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.7,
                left: MediaQuery.of(context).size.width * 0.1),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                IconButton(
                  onPressed: () {

                    if (isPlaying) {
                      _audioPlayer.pause();

                      setState(() {
                        isPlaying = false;
                      });
                    } else if(filePathExists && !isPlaying){
                      _audioPlayer.resume();

                      setState(() {
                        isPlaying = true;
                      });
                    } else if(!filePathExists && !isPlaying){
                      Toast.show(
                        "Choose audio file",
                        context,
                        duration: Toast.LENGTH_LONG,
                          gravity:  Toast.BOTTOM
                      );
                    }
                  },
                  icon: Icon(isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded),
                  iconSize: 32.0,
                ),
                SizedBox(width: 25),
                IconButton(
                  onPressed: () {
                    _audioPlayer.stop();
                    crtTime = "0:00:00";
                    setState(() {
                      isPlaying = false;
                    });
                  },
                  icon: Icon(Icons.stop_rounded),
                  iconSize: 32.0,
                ),

                SizedBox(width: 20),

                Text(crtTime, style: TextStyle(fontWeight: FontWeight.w700),),

                Text("  |  "),

                Text(cptTime, style: TextStyle(fontWeight: FontWeight.w300),),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.audiotrack_rounded),
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles();
          if (result != null) {
            PlatformFile file = result.files.first;
            print(file.path);
            int status =
                await _audioPlayer.play(file.path.toString(), isLocal: true);
            if (status == 1) {
              setState(() {
                isPlaying = true;
                filePathExists = true;
              });
            }
            else {
              setState(() {
                isPlaying = false;
                filePathExists = false;
              });
            }
          }
        },
      ),
    );
  }
}
