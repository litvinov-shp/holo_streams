import 'package:dart_holodex_api/dart_holodex_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:holo_streams/controllers/data/channels.dart';
import 'package:holo_streams/controllers/data/streams.dart';
import 'package:holo_streams/controllers/filters.dart';
import 'package:holo_streams/controllers/shared_prefs.dart';
import 'package:holo_streams/controllers/time.dart';
import 'package:holo_streams/ui/screens/home/home_screen.dart';

import 'controllers/settings.dart';

// Data collected from Holodex API https://docs.holodex.net/#section/LICENSE
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Future.wait([
    SharedPrefs.initialize(),
    dotenv.load(),
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final HolodexClient holodexClient = HolodexClient(apiKey: dotenv.env['HOLODEX_API_KEY']!);

  ThemeData generateThemeData(Brightness brightness) {
    final themeData = ThemeData.from(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue, brightness: brightness),
      useMaterial3: true,
    );
    final defaultListTileTheme = themeData.listTileTheme;
    final isCompact = Settings.to.layoutMode == LayoutMode.compact;
    return themeData.copyWith(
      listTileTheme: defaultListTileTheme.copyWith(
        titleTextStyle: TextStyle(
          fontSize: isCompact ? 14.0 : 16.0,
          color: themeData.colorScheme.onSurface,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: isCompact ? 12.0 : 14.0,
          color: themeData.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Get.put(Settings(), permanent: true);
    Get.put(FiltersController(), permanent: true);
    Get.put(StreamsController(holodexClient: holodexClient), permanent: true);
    Get.put(ChannelsController(holodexClient: holodexClient), permanent: true);
    Get.put(TimeController(), permanent: true);
  }

  @override
  void dispose() {
    holodexClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetX<Settings>(
      builder: (controller) {
        return MaterialApp(
          title: 'Hololive Streams',
          theme: generateThemeData(Brightness.light),
          darkTheme: generateThemeData(Brightness.dark),
          themeMode: controller.themeMode,
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
