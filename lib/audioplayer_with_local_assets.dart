import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerWithLocalAssets extends StatefulWidget {
  @override
  _AudioPlayerWithLocalAssetsState createState() =>
      _AudioPlayerWithLocalAssetsState();
}

class _AudioPlayerWithLocalAssetsState
    extends State<AudioPlayerWithLocalAssets> {
  AudioPlayer audioPlayer = AudioPlayer();
  PlayerState audioPlayerState = PlayerState.PAUSED;
  late AudioCache audioCache;
  String path = 'music.mp3';

  @override
  void initState() {
    super.initState();
    audioCache = AudioCache(fixedPlayer: audioPlayer);
    audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
      setState(() {
        audioPlayerState = s;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.release();
    audioPlayer.dispose();
    audioCache.clearAll();
  }

  playMusic() async {
    await audioCache.play(path);
  }

  pauseMusic() async {
    await audioPlayer.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(audioPlayerState == PlayerState.PLAYING
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded),
              iconSize: 50.0,
              onPressed: () {
                audioPlayerState == PlayerState.PLAYING
                    ? pauseMusic()
                    : playMusic();
              },
            ),
          ],
        ),
      ),
    );
  }
}
