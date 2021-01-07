import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'events_selection_screen.dart';
import '../utils/multilang_strings.dart';
import '../database_helper/shared_preferences.dart';
import '../network/authentication.dart';
import '../utils/constants.dart';
import '../components/content_box.dart';
import '../components/main_body.dart';

class SettingsScreen extends StatefulWidget {
  static const String id = "settings_screen";
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // bool _status = true;
  @override
  Widget build(BuildContext context) {
    return MainBody(
      children: [
        ContentBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(height: 25),
                    Text(
                      MultiLang.currentLanguage.settings,
                      style: kMainTextStyle.copyWith(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    SettingsOption(
                      optionText: MultiLang.currentLanguage.soundOnOff,
                      switchStatus: Values.isSoundOn,
                      onChange: (statusValue) async {
                        await DataCache.preferences
                            .setBool(DataCache.soundOnOff, statusValue);
                        setState(() {
                          Values.isSoundOn = statusValue;
                        });
                      },
                    ),
                    // SettingsOption(
                    //   optionText: 'Setting #2',
                    //   switchStatus: _status,
                    //   onChange: (statusValue) {
                    //     setState(() {
                    //       _status = statusValue;
                    //     });
                    //   },
                    // ),
                    // SettingsOption(
                    //   optionText: 'Setting #3',
                    //   switchStatus: _status,
                    //   onChange: (statusValue) {
                    //     setState(() {
                    //       _status = statusValue;
                    //     });
                    //   },
                    // ),
                    SettingsOption(
                      optionText: MultiLang.currentLanguage.appVersion,
                      isVersionRow: true,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.32,
                        child: FlatButton(
                            padding: EdgeInsets.all(0),
                            height: MediaQuery.of(context).size.height * 0.04,
                            onPressed: () {
                              Values.selectedPage = null;
                              Navigator.pushReplacementNamed(
                                  context, EventsSelectionScreen.id);
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            color: kMainBlueColor,
                            child: Text(
                              MultiLang.currentLanguage.switchEvent,
                              textAlign: TextAlign.center,
                              style: kMainTextStyle.copyWith(fontSize: 10),
                            )),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.32,
                        child: FlatButton(
                            padding: EdgeInsets.all(0),
                            height: MediaQuery.of(context).size.height * 0.04,
                            onPressed: () {
                              CustomAlertDialog.showCustomDialog(
                                MultiLang.currentLanguage.sureMsg,
                                MultiLang.currentLanguage.logoutMsg,
                                context,
                                () => AuthService.logout(context),
                                () => Navigator.pop(context),
                              );
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            color: kMainBlueColor,
                            child: Text(
                              MultiLang.currentLanguage.logout,
                              textAlign: TextAlign.center,
                              style: kMainTextStyle.copyWith(fontSize: 10),
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class SettingsOption extends StatefulWidget {
  final String optionText;
  bool switchStatus;
  final Function(bool) onChange;
  final bool isVersionRow;

  SettingsOption({
    Key key,
    this.switchStatus,
    this.onChange,
    this.optionText,
    this.isVersionRow = false,
  }) : super(key: key);

  @override
  _SettingsOptionState createState() => _SettingsOptionState();
}

class _SettingsOptionState extends State<SettingsOption> {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(0),
      onPressed: () {
        setState(() {
          widget.switchStatus = !widget.switchStatus;
        });
        widget.onChange.call(widget.switchStatus);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.optionText,
                style: kMainTextStyle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!widget.isVersionRow)
                FlutterSwitch(
                  activeColor: kMainBlueColor,
                  toggleColor: kMainBlackColor,
                  valueFontSize: 0,
                  toggleSize: 15,
                  width: 31,
                  height: 17,
                  padding: 0,
                  value: widget.switchStatus,
                  onToggle: widget.onChange,
                ),
              if (widget.isVersionRow)
                Text(
                  'V1.0',
                  style: kMainTextStyle.copyWith(fontSize: 12),
                ),
            ],
          ),
          SizedBox(height: 15),
          Container(
            height: 2,
            color: kMainBlueColor,
          ),
        ],
      ),
    );
  }
}
