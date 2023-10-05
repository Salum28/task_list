import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:task_list/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home()
    )
  );
}
