import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fruit_ninja_dnv/initial.dart';
import 'package:fruit_ninja_dnv/start.dart';

void main() {
  AudioCache audioCache = AudioCache();
  audioCache.load('music.mp3'); 
  audioCache.play('music.mp3');
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/start',
      routes: {
        '/start': (context) => StartScreen(), 
        '/game': (context) =>
            InitialScreen(), 
      },
    );
  }
}
