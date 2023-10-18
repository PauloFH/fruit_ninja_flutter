import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'models/fruit.dart';
import 'models/fruit_part.dart';
import 'models/touch_slice.dart';
import 'slice_painter.dart';

class CanvasArea extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CanvasAreaState();
  }
}

class _CanvasAreaState<CanvasArea> extends State {
  AudioCache audio = AudioCache();

  int _score = 0;
  int _errors = 0;
  int temp = 0;
  double screenWidth = 0.0;
  double screenHeight = 0.0;
  TouchSlice? _touchSlice;
  final List<Fruit> _fruits = <Fruit>[];
  final List<FruitPart> _fruitParts = <FruitPart>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        screenWidth = size.width;
        screenHeight = size.height;
      });

      _spawnRandomFruit(screenWidth, screenHeight);
      _tick();
    });
    audio.load('shout.mp3');
  }

  void _spawnRandomFruit(double screenWidth, double screenHeight) async {
    final double randomX =
        Random().nextDouble() * (screenWidth - 100); // 100 é a largura da fruta
    final double startY = screenHeight / 2 +
        Random().nextDouble() *
            (screenHeight / 2 -
                180); // A fruta começa do meio da tela para cima
    final double randomRotation = Random().nextDouble() / 3 - 0.16;

    const ImageProvider fruitImage = AssetImage('assets/melon_uncut.png');
    await precacheImage(fruitImage, context);

    final fruit = Fruit(
      position: Offset(randomX, startY - 180),
      width: 100,
      height: 180,
      additionalForce:
          Offset(5 + Random().nextDouble() * 5, Random().nextDouble() * -10),
      rotation: randomRotation,
      imageProvider: fruitImage,
    );

    setState(() {
      _fruits.add(fruit);
    });
  }

  void _tick() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    setState(() {
      for (Fruit fruit in _fruits) {
        fruit.applyGravity();
      }
      for (FruitPart fruitPart in _fruitParts) {
        fruitPart.applyGravity();
      }

      if (Random().nextDouble() > 0.97) {
        _spawnRandomFruit(screenWidth, screenHeight);
      }
    });

    Future<void>.delayed(const Duration(milliseconds: 30), _tick);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Stack(children: _getStack(screenWidth, screenHeight));
  }

  List<Widget> _getStack(double screenWidth, double screenHeight) {
    List<Widget> widgetsOnStack = <Widget>[];

    widgetsOnStack.add(
      Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/wallpapers.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );

    widgetsOnStack.add(_getSlice());
    widgetsOnStack.addAll(_getFruitParts());
    widgetsOnStack.addAll(_getFruits());
    widgetsOnStack.add(_getGestureDetector());
    widgetsOnStack.add(
      Align(
        alignment: Alignment.topCenter,
        child: Text(
          'Score: $_score',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.yellow,
          ),
        ),
      ),
    );

    return widgetsOnStack;
  }

  Container _getBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          stops: <double>[0.2, 1.0],
          colors: <Color>[Color(0xffFFB75E), Color(0xffED8F03)],
        ),
      ),
    );
  }

  Widget _getSlice() {
    if (_touchSlice == null) {
      return Container();
    }

    return CustomPaint(
      size: Size.infinite,
      painter: SlicePainter(
        pointsList: _touchSlice!.pointsList,
      ),
    );
  }

  List<Widget> _getFruits() {
    List<Widget> list = <Widget>[];

    for (Fruit fruit in _fruits) {
      list.add(
        Positioned(
          top: fruit.position.dy,
          left: fruit.position.dx,
          child: Transform.rotate(
            angle: fruit.rotation * pi * 2,
            child: _getMelon(fruit),
          ),
        ),
      );
    }

    return list;
  }

  List<Widget> _getFruitParts() {
    List<Widget> list = <Widget>[];

    for (FruitPart fruitPart in _fruitParts) {
      list.add(
        Positioned(
          top: fruitPart.position.dy,
          left: fruitPart.position.dx,
          child: _getMelonCut(fruitPart),
        ),
      );
    }

    return list;
  }

  Widget _getMelonCut(FruitPart fruitPart) {
    return Transform.rotate(
      angle: fruitPart.rotation * pi * 2,
      child: Image.asset(
        fruitPart.isLeft
            ? 'assets/melon_cut.png'
            : 'assets/melon_cut_right.png',
        height: 80,
        fit: BoxFit.fitHeight,
      ),
    );
  }

  Widget _getMelon(Fruit fruit) {
    return Image.asset(
      'assets/melon_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getGestureDetector() {
    return GestureDetector(
      onScaleStart: (ScaleStartDetails details) {
        setState(() => _setNewSlice(details));
      },
      onScaleUpdate: (ScaleUpdateDetails details) {
        setState(
          () {
            _addPointToSlice(details);
            _checkCollision();
          },
        );
      },
      onScaleEnd: (ScaleEndDetails details) {
        setState(() => _resetSlice());
      },
    );
  }

  void _checkCollision() {
    if (_touchSlice == null) {
      return;
    }

    bool hitFruit =
        false; // Variável para rastrear se o jogador acertou alguma fruta

    for (Fruit fruit in List<Fruit>.from(_fruits)) {
      if (fruit.position.dx >= 0 &&
          fruit.position.dx <= screenWidth &&
          fruit.position.dy >= 0) {
    
        for (Offset point in _touchSlice!.pointsList) {
          if (fruit.isPointInside(point)) {
            _fruits.remove(fruit);
            _turnFruitIntoParts(fruit);
            _score += 10;
            temp + 1;
            if (temp > 10) {
              audio.play('shout.mp3');
              temp = 0;
            }
            hitFruit = true; // O jogador acertou a fruta
            break;
          }
        }
      }
    }

    if (!hitFruit) {
      _errors++;
      print('Erros: $_errors');
    }
  }

  void _turnFruitIntoParts(Fruit hit) {
    FruitPart leftFruitPart = FruitPart(
      position: Offset(
        hit.position.dx - hit.width / 8,
        hit.position.dy,
      ),
      width: hit.width / 2,
      height: hit.height,
      isLeft: true,
      gravitySpeed: hit.gravitySpeed,
      additionalForce: Offset(
        hit.additionalForce.dx - 1,
        hit.additionalForce.dy - 5,
      ),
      rotation: hit.rotation,
    );

    FruitPart rightFruitPart = FruitPart(
      position: Offset(
        hit.position.dx + hit.width / 4 + hit.width / 8,
        hit.position.dy,
      ),
      width: hit.width / 2,
      height: hit.height,
      isLeft: false,
      gravitySpeed: hit.gravitySpeed,
      additionalForce: Offset(
        hit.additionalForce.dx + 1,
        hit.additionalForce.dy - 5,
      ),
      rotation: hit.rotation,
    );

    setState(() {
      _fruitParts.add(leftFruitPart);
      _fruitParts.add(rightFruitPart);
      _fruits.remove(hit);
    });
  }

  void _resetSlice() {
    _touchSlice = null;
  }

  void _setNewSlice(details) {
    _touchSlice = TouchSlice(pointsList: <Offset>[details.localFocalPoint]);
  }

  void _addPointToSlice(ScaleUpdateDetails details) {
    if (_touchSlice?.pointsList == null || _touchSlice!.pointsList.isEmpty) {
      return;
    }

    if (_touchSlice!.pointsList.length > 16) {
      _touchSlice!.pointsList.removeAt(0);
    }
    _touchSlice!.pointsList.add(details.localFocalPoint);
  }
}
