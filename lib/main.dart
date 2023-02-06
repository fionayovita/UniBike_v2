import 'dart:io';
// import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:unibike/api/api_service.dart';
import 'package:unibike/common/router.dart';
import 'package:unibike/common/styles.dart';
import 'package:unibike/provider/bike_provider.dart';
import 'package:unibike/ui/splash_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (Platform.isAndroid) {
    // await AndroidAlarmManager.initialize();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => BikeProvider(apiService: ApiService())),
      ],
      child: MaterialApp(
          theme: themeData,
          initialRoute: SplashScreen.routeName,
          onGenerateRoute: RouterHelper.generateRoute),
    );
  }
}
