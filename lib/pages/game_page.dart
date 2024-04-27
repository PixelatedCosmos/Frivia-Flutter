import 'package:flutter/material.dart';
import 'package:frivia/providers/game_page_provider.dart';
import 'package:provider/provider.dart';

class GamePage extends StatelessWidget {
  double? _deviceHeight, _deviceWidth;

  final int maxQuestions;
  final String difficultyLevel;
  final int category;

  GamePageProvider? _pageProvider;

  GamePage(
      {required this.maxQuestions,
      required this.difficultyLevel,
      required this.category});

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider(
      create: (_context) => GamePageProvider(
        context: context,
        maxQuestions: maxQuestions,
        difficultyLevel: difficultyLevel,
        category: category,
      ),
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(
      builder: (_context) {
        _pageProvider = _context.watch<GamePageProvider>();
        if (_pageProvider!.questions != null) {
          return Scaffold(
            body: SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _deviceHeight! * 0.05,
                ),
                child: _gameUI(_context),
              ),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
      },
    );
  }

  Widget _gameUI(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _questionText(),
            Column(
              children: [
                _tfButton("True", Colors.green),
                SizedBox(height: _deviceHeight! * 0.01),
                _tfButton("False", Colors.red),
              ],
            ),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          child: _menuButton(context),
        ),
      ],
    );
  }

  Widget _questionText() {
    return Text(
      _pageProvider!.getCurrentQuestionText(),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 25,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _tfButton(String text, Color color) {
    return MaterialButton(
      onPressed: () {
        switch (text) {
          case "True":
            _pageProvider?.answerQuestion("True");
            break;
          case "False":
            _pageProvider?.answerQuestion("False");
            break;
        }
      },
      color: color,
      minWidth: _deviceWidth! * 0.80,
      height: _deviceHeight! * 0.10,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 25,
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.home, color: Colors.white, size: 30.0),
      onPressed: () {
        Navigator.pop(context);
      },
      padding: const EdgeInsets.all(10.0),
      splashRadius: 25.0,
      splashColor: Colors.blue[100],
    );
  }
}
