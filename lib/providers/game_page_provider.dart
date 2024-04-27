import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:audioplayers/audioplayers.dart';

class GamePageProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  final int maxQuestions;
  final String difficultyLevel;
  final int category;

  int _correctCount = 0;

  List? questions;
  int _currentQuestionCount = 0;

  BuildContext context;
  GamePageProvider({
    required this.context,
    required this.maxQuestions,
    required this.difficultyLevel,
    required this.category,
  }) {
    _dio.options.baseUrl = 'https://opentdb.com/api.php';
    _getQuestionsFromAPI();
  }

  Future<void> _getQuestionsFromAPI() async {
    var _response = await _dio.get(
      '',
      queryParameters: {
        'amount': maxQuestions,
        'difficulty': difficultyLevel,
        'category': category,
        'type': 'boolean',
      },
    );

    var _data = jsonDecode(_response.toString());
    questions = _data["results"];

    if (questions!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No questions available for the selected category"),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } else {
      notifyListeners();
    }
  }

  String getCurrentQuestionText() {
    var unescape = HtmlUnescape();
    return unescape.convert(questions![_currentQuestionCount]["question"]);
  }

  void answerQuestion(String _answer) async {
    bool isCorrect =
        questions![_currentQuestionCount]["correct_answer"] == _answer;
    _currentQuestionCount++;

    final player = AudioPlayer();

    if (isCorrect) {
      _correctCount++;
      await player.setVolume(1);
      await player.play(AssetSource("sounds/correct_answer_tone.wav"));
    } else {
      await player.setVolume(0.35);
      await player.play(AssetSource("sounds/incorrect_answer_tone.wav"));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? 'Correct Answer' : 'Incorrect Answer'),
        backgroundColor: (isCorrect ? Colors.green : Colors.red),
        duration: const Duration(seconds: 1),
      ),
    );

    if (_currentQuestionCount == maxQuestions) {
      endGame();
    } else {
      Future.delayed(
        const Duration(seconds: 1),
        () {
          notifyListeners();
        },
      );
    }
  }

  Future<void> endGame() async {
    showDialog(
      context: context,
      builder: (BuildContext _context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(31, 31, 31, 1),
          title: const Text(
            "End game!",
            style: TextStyle(fontSize: 25, color: Colors.white),
          ),
          content: Text(
            "Score: $_correctCount/$maxQuestions",
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        );
      },
    );
    await Future.delayed(
      const Duration(seconds: 3),
    );
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
