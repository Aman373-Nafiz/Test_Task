import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylus/screens/home_page.dart';


void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Cloth App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}