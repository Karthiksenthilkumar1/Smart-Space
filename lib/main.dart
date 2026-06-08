import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'features/auth/login_screen.dart';
import 'core/theme/app_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'core/providers/theme_provider.dart';

final FlutterLocalNotificationsPlugin
    flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  const AndroidInitializationSettings
    initializationSettingsAndroid =
    AndroidInitializationSettings(
        '@mipmap/ic_launcher');

  const InitializationSettings
      initializationSettings =
      InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin
      .initialize(
    initializationSettings,
  );

  FirebaseMessaging.onMessage.listen(
    (RemoteMessage message) async {
      print("NOTIFICATION RECEIVED");

      await flutterLocalNotificationsPlugin.show(
        0,
        message.notification?.title ??
            "SpaceFit",
        message.notification?.body ??
            "",
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'spacefit_channel',
            'SpaceFit Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    },
  );

  final token =
      await FirebaseMessaging.instance.getToken();

  debugPrint("FCM TOKEN = $token");

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider =
      Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      darkTheme: AppTheme.darkTheme,

      themeMode:
          themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,

      home: LoginScreen(),
    );
  }
}