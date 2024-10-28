import 'package:alarm_smoking/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:alarm_smoking/main_page.dart';
import 'background_service.dart';
import 'package:permission_handler/permission_handler.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Permission.notification.isDenied.then(
    (value){
      if(value){
        Permission.notification.request();
      }
    }
  );
  //await initializeService();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alarm Smoking',
      theme: ThemeData(
         useMaterial3: true,
      ),
      home: const AlarmWidgetState(),
    );
  }
}

