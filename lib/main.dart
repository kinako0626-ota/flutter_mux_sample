import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mux/dashboard_page.dart';
import 'package:video_stream/camera.dart';

import 'firebase_options.dart';

// Global variable for storing the list of available cameras
List<CameraDescription> cameras = [];
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Get the available device cameras
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint(e.toString());
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const DashboardPage());
  }
}
