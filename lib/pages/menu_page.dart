import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'game_page.dart';

class MenuPage extends StatefulWidget {
  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  List<String> categories = [];
  final dio = Dio();

  double _selectedDifficulty = 1;
  double _selectedNumOfQuestions = 10.0;
  String _selectedCategory = "All";

  late Future<Response> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = dio.get('https://opentdb.com/api_category.php');
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Container(
          width: _deviceWidth * 0.85,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildTitle(),
              buildDifficultySlider(),
              buildNumOfQuestionsDropDown(),
              buildCategoriesDropDown(),
              buildStartGameButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTitle() {
    return const Text(
      "Frivia",
      style: TextStyle(color: Colors.white, fontSize: 50),
    );
  }

  Widget buildDifficultySlider() {
    return Column(
      children: [
        Slider(
          value: _selectedDifficulty,
          min: 1,
          max: 3,
          divisions: 2,
          onChanged: (double value) {
            setState(() {
              _selectedDifficulty = value;
            });
          },
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Easy', style: TextStyle(color: Colors.white)),
            Text('Medium', style: TextStyle(color: Colors.white)),
            Text('Hard', style: TextStyle(color: Colors.white)),
          ],
        ),
      ],
    );
  }

  Widget buildNumOfQuestionsDropDown() {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: const Color.fromRGBO(12, 74, 14, 1),
      ),
      child: DropdownButton<double>(
        value: _selectedNumOfQuestions,
        icon: const Icon(Icons.arrow_downward),
        iconSize: 24,
        elevation: 16,
        style: const TextStyle(color: Colors.white),
        underline: Container(
          height: 2,
          color: const Color.fromRGBO(12, 74, 14, 1),
        ),
        onChanged: (double? newValue) {
          setState(() {
            _selectedNumOfQuestions = newValue!;
          });
        },
        items: <double>[10, 20, 30, 40, 50]
            .map<DropdownMenuItem<double>>((double value) {
          return DropdownMenuItem<double>(
            value: value,
            child: Text(value
                .toInt()
                .toString()), // Convert the double to int before converting to String
          );
        }).toList(),
      ),
    );
  }

  Widget buildStartGameButton() {
    return MaterialButton(
      onPressed: _startGame,
      color: const Color.fromRGBO(12, 74, 14, 1),
      minWidth: _deviceWidth * 0.5,
      height: _deviceHeight * 0.08,
      child: const Text(
        "Start",
        style: TextStyle(
          color: Colors.white,
          fontSize: 30,
        ),
      ),
    );
  }

  var categoriesList = [];

  Widget buildCategoriesDropDown() {
    return FutureBuilder<Response>(
      future: _categoriesFuture,
      builder: (BuildContext context, AsyncSnapshot<Response> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          var data = snapshot.data!.data;
          var categoryList = data['trivia_categories'];
          categoriesList = categoryList;
          if (!categoryList.any((category) => category['name'] == 'All')) {
            categoryList.insert(0, {'name': 'All'});
          }
          return Theme(
            data: Theme.of(context).copyWith(
              canvasColor: const Color.fromRGBO(12, 74, 14, 1),
            ),
            child: DropdownButton<String>(
              value: _selectedCategory,
              icon: const Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.white),
              underline: Container(
                height: 2,
                color: const Color.fromRGBO(12, 74, 14, 1),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
              items: categoryList.map<DropdownMenuItem<String>>((category) {
                return DropdownMenuItem<String>(
                  value: category['name'],
                  child: Text(category['name']),
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }

  List prepareGameData() {
    String difficulty;
    switch (_selectedDifficulty.toInt()) {
      case 1:
        difficulty = "easy";
        break;
      case 2:
        difficulty = "medium";
        break;
      case 3:
        difficulty = "hard";
        break;
      default:
        difficulty = "easy";
        break;
    }

    int? categoryID;

    if (_selectedCategory == "All") {
      categoryID = 0;
    } else {
      var selectedCategory = categoriesList
          .firstWhere((category) => category['name'] == _selectedCategory);
      categoryID = selectedCategory['id'];
    }

    int numOfQuestions = _selectedNumOfQuestions.toInt();

    return [numOfQuestions, difficulty, categoryID];
  }

  void _startGame() {
    var list = prepareGameData();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext _context) {
          return GamePage(
            maxQuestions: list[0],
            difficultyLevel: list[1],
            category: list[2],
          );
        },
      ),
    );
  }
}
