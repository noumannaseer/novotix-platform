import 'package:flutter/material.dart';
import 'package:novotix_app/screens/settings_screen.dart';
import '../push_notifications/push_notifications_service.dart';
import '../utils/multilang_strings.dart';
import '../database_helper/shared_preferences.dart';
import '../network/authentication.dart';
import '../utils/constants.dart';
import '../res.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String id = 'splash_screen';
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> initApp() async {
    await PushNotificationsManager().init();
    await DataCache.init();
    Values.isSoundOn =
        DataCache.preferences.getBool(DataCache.soundOnOff) ?? true;
    print(Values.isSoundOn);
    final username = DataCache.preferences.getString(DataCache.username);
    final password = DataCache.preferences.getString(DataCache.password);
    if (username != null && password != null) {
      await AuthService().login(username, password, context);
      setState(() {});
      return;
    }
    Future.delayed(Duration(seconds: 2),
        () => Navigator.pushReplacementNamed(context, SettingsScreen.id));
  }

  @override
  void initState() {
    initApp();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    MultiLang.initLocalLang(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBlackColor,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                Res.background,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fill,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    Res.logo,
                    width: MediaQuery.of(context).size.width * 0.81,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Attendee checkin',
                    style: kMainTextStyle.copyWith(
                        fontSize: 18, color: Colors.white70, letterSpacing: 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
