import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_app/weather_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //to remove debug tag
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 0, 120, 176)
        /* appBarTheme: AppBarTheme(
          backgroundColor: Colors.amber
        ) */
      ), 
      //copyWith for applying theme
      home: WeatherScreen()

    );
  }
}