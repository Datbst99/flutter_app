

import 'package:flutter/material.dart';
import 'package:flutter_app_bt/views/home_view.dart';
import 'package:flutter_app_bt/views/profile_view.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized;
  return runApp(MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "App Demo",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true
      ),
      home: const HomeView(),
    );
  }
}