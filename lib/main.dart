import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'screens/home_screen.dart';
import 'services/ads_service.dart';
import 'theme/neumorphic.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enables background playback + lock-screen controls for audio.
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.example.bagarawa_app.channel.audio',
      androidNotificationChannelName: 'Bagarawa Audio',
      androidNotificationOngoing: true,
    );
  } catch (_) {}

  // Fire-and-forget: ads only ever fetch in the background when data is
  // available, and never block app startup or offline audio playback.
  try {
    AdsService.instance.start();
  } catch (_) {}

  runApp(const IslamicAudioApp());
}

class IslamicAudioApp extends StatelessWidget {
  const IslamicAudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bagarawa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.accent,
        scaffoldBackgroundColor: AppColors.background,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
