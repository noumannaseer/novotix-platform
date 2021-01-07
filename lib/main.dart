import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:novotix_app/utils/constants.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/events_selection_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/guestlist_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale(Values.en, ''), // English, no country code
        const Locale(Values.nl, ''),
      ],
      initialRoute: SplashScreen.id,
      debugShowCheckedModeBanner: false,
      routes: {
        SplashScreen.id: (context) => SplashScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        EventsSelectionScreen.id: (context) => EventsSelectionScreen(),
        ScanScreen.id: (context) => ScanScreen(),
        GuestListScreen.id: (context) => GuestListScreen(),
        MessagesScreen.id: (context) => MessagesScreen(),
        SettingsScreen.id: (context) => SettingsScreen(),
      },
    );
  }
}
