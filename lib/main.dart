import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lg_task2/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "LG_TASK3",
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xffFFA384),
        appBarTheme: const AppBarTheme(
          color: Color(0xFF74BDCB),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
