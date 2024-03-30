import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_offline_fm/services/music_client.dart';

import 'package:flutter_offline_fm/services/music_player.dart';
import 'package:flutter_offline_fm/pages/main_page.dart';
import 'package:flutter_offline_fm/services/back_services.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  try {
    await MusicPlayerSingleton.init();
    await MusicClientSingleton().initPrefs();
    WidgetsFlutterBinding.ensureInitialized();

    await Permission.notification.isDenied.then(
      (value) {
        if (value) Permission.notification.request();
      },
    );

    await initializeService();

    // FlutterBackgroundService().invoke('setAsForeground');
// FlutterBackgroundService().invoke('setAsBackground');
    // FlutterBackgroundService().startService();
    // FlutterBackgroundService().invoke('stopService');
  } catch (e) {
    log('Main error: ${e.toString()}');
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MainPage());
  }
}
