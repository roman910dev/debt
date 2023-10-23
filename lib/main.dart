import 'package:debt/config.dart';
import 'package:debt/pages/entry_list/entry_list.dart';
import 'package:debt/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DebtSettings.load();
  if (DebtEnv.isMobile) MobileAds.instance.initialize();
  people.initialize();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: DebtSettings.themeNotifier,
        builder: (context, theme, _) => MaterialApp(
          color: Colors.white,
          title: 'Debt Tracker',
          home: const EntryList(null),
          debugShowCheckedModeBanner: false,
          themeMode: theme,
          theme: lightTheme,
          darkTheme: darkTheme,
        ),
      );
}
