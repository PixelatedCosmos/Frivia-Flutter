import 'package:flutter/material.dart';
import 'package:frivia/pages/menu_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frivia',
      theme: ThemeData(
        fontFamily: 'Lato',
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(12, 74, 14, 1)),
        scaffoldBackgroundColor: const Color.fromRGBO(31, 31, 31, 1),
        useMaterial3: true,
      ),
      home: MenuPage(),
    );
  }
}
