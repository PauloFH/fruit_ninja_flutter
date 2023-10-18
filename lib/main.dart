import 'package:flutter/material.dart';
import 'package:fruit_ninja_dnv/initial.dart';
import 'package:fruit_ninja_dnv/start.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/start',
      routes: {
        '/start': (context) => StartScreen(), // Rota para a tela de início
        '/game': (context) =>
            InitialScreen(), // Rota para a tela principal do jogo
      },
    );
  }
}
