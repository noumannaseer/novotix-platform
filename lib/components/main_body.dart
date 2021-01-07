import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../network/messages_service.dart';
import '../utils/multilang_strings.dart';
import '../network/authentication.dart';
import '../network/sync_status.dart';
import '../res.dart';
import '../screens/settings_screen.dart';
import '../screens/messages_screen.dart';
import '../screens/guestlist_screen.dart';
import '../screens/scan_screen.dart';
import '../utils/constants.dart';

class MainBody extends StatefulWidget {
  final List<Widget> children;
  final bool isEventScreen;

  MainBody({
    this.children,
    this.isEventScreen = false,
  });

  @override
  _MainBodyState createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _isLoading = false;

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                SvgPicture.asset(
                  Res.nt,
                  width: 40,
                ),
                SizedBox(width: 10.0),
                Text(MultiLang.currentLanguage.sureMsg),
              ],
            ),
            content: Text(MultiLang.currentLanguage.exitMsg),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  MultiLang.currentLanguage.no,
                  style: kMainTextStyle.copyWith(color: kMainBlackColor),
                ),
              ),
              FlatButton(
                color: kMainBlueColor,
                onPressed: () => Navigator.of(context).pop(true),
                child:
                    Text(MultiLang.currentLanguage.yes, style: kMainTextStyle),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          key: _scaffoldKey,
          drawer: CustomSideBar(),
          backgroundColor: kMainBlueColor,
          body: Stack(
            children: [
              Center(
                child: Image.asset(
                  Res.background,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  fit: BoxFit.contain,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.14,
                    decoration: BoxDecoration(
                      color: kMainBlackColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                    ),
                    child: SafeArea(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () => _scaffoldKey.currentState.openDrawer(),
                            child: SvgPicture.asset(
                              Res.menu,
                              width: 23,
                              color: kMainBlueColor,
                            ),
                          ),
                          Image.asset(
                            Res.logo,
                            width: MediaQuery.of(context).size.width * 0.27,
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                Values.selectedPage = 3;
                              });
                              final routeName =
                                  ModalRoute.of(context)?.settings?.name;
                              if (routeName != null &&
                                  routeName == MessagesScreen.id) {
                                return;
                              }
                              Navigator.pushReplacementNamed(
                                  context, MessagesScreen.id);
                            },
                            child: Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                Center(
                                  child: Icon(
                                    Icons.notifications_outlined,
                                    color: kMainBlueColor,
                                    size: 28,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Visibility(
                                    visible: Values.messages
                                            .where((element) =>
                                                element.messageStatus == 'new')
                                            .toList()
                                            .length >
                                        0,
                                    child: Container(
                                      width: 13,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: kMainBlueColor,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${Values.messages.where((element) => element.messageStatus == 'new').toList().length}',
                                          style: kMainTextStyle.copyWith(
                                              fontSize: 9),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ...widget.children,
                  if (!widget.isEventScreen)
                    Container(
                      height: MediaQuery.of(context).size.height * 0.18,
                      decoration: BoxDecoration(
                        color: kMainBlackColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              BottomSyncData(
                                  label: MultiLang.currentLanguage.inTxt
                                      .toUpperCase(),
                                  data: Values.ticketList
                                      .where((element) =>
                                          element?.ticketValidated == 1)
                                      .toList()
                                      .length
                                      .toString()),
                              BottomSyncData(
                                  label: MultiLang.currentLanguage.out
                                      .toUpperCase(),
                                  data: Values.ticketList
                                      .where((element) =>
                                          element?.ticketValidated == 0)
                                      .toList()
                                      .length
                                      .toString()),
                              BottomSyncData(
                                  label: MultiLang.currentLanguage.total
                                      .toUpperCase(),
                                  data: Values.ticketList.length.toString()),
                            ],
                          ),
                          SizedBox(height: 5),
                          FlatButton(
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              await SyncStatus().syncStatusRequest();
                              await MessagesService().storeMessages();
                              setState(() {
                                _isLoading = false;
                              });
                              ShowToast.showToast(
                                  MultiLang.currentLanguage.statusSynced);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.sync,
                                  color: kMainBlueColor,
                                  size: 26,
                                ),
                                SizedBox(width: 5),
                                Text(MultiLang.currentLanguage.syncStatus,
                                    style:
                                        kMainTextStyle.copyWith(fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomSyncData extends StatelessWidget {
  final String label;
  final String data;

  const BottomSyncData({
    this.label,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: kMainTextStyle.copyWith(fontSize: 11)),
        SizedBox(height: 5),
        Container(
          width: 64,
          height: 1.5,
          color: kMainBlueColor,
        ),
        SizedBox(height: 5),
        Text(data, style: kMainTextStyle.copyWith(fontSize: 11)),
      ],
    );
  }
}

class CustomSideBar extends StatefulWidget {
  @override
  _CustomSideBarState createState() => _CustomSideBarState();
}

class _CustomSideBarState extends State<CustomSideBar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Drawer(
          child: Container(
            width: double.infinity,
            color: kMainBlackColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(width: 12),
                        // Image.asset('images/logo_icon.png'),
                        SvgPicture.asset(
                          Res.nt,
                          width: 40,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Values.user.loginName,
                                style: kMainTextStyle.copyWith(fontSize: 10),
                              ),
                              SizedBox(height: 5.0),
                              Text(
                                Values.user.userRights,
                                overflow: TextOverflow.fade,
                                style: kMainTextStyle.copyWith(fontSize: 8),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    Container(
                      color: kMainBlueColor,
                      width: MediaQuery.of(context).size.width * 0.44,
                      height: 1,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15),
                        SideBarButton(
                          onPress: () {
                            setState(() {
                              Values.selectedPage = 1;
                            });
                            final routeName =
                                ModalRoute.of(context)?.settings?.name;
                            if (routeName != null &&
                                routeName == ScanScreen.id) {
                              return;
                            }
                            Navigator.pushReplacementNamed(
                                context, ScanScreen.id);
                          },
                          color: Values.selectedPage == 1
                              ? kMainBlueColor.withOpacity(0.6)
                              : Colors.transparent,
                          title: MultiLang.currentLanguage.attendeeCheckIn,
                        ),
                        SizedBox(height: 15),
                        SideBarButton(
                          onPress: () {
                            setState(() {
                              Values.selectedPage = 2;
                            });
                            final routeName =
                                ModalRoute.of(context)?.settings?.name;
                            if (routeName != null &&
                                routeName == GuestListScreen.id) {
                              return;
                            }
                            Navigator.pushReplacementNamed(
                                context, GuestListScreen.id);
                          },
                          color: Values.selectedPage == 2
                              ? kMainBlueColor.withOpacity(0.6)
                              : Colors.transparent,
                          title: MultiLang.currentLanguage.guestList,
                        ),
                        SizedBox(height: 15),
                        SideBarButton(
                          color: Values.selectedPage == 3
                              ? kMainBlueColor.withOpacity(0.6)
                              : Colors.transparent,
                          onPress: () {
                            setState(() {
                              Values.selectedPage = 3;
                            });
                            final routeName =
                                ModalRoute.of(context)?.settings?.name;
                            if (routeName != null &&
                                routeName == MessagesScreen.id) {
                              return;
                            }
                            Navigator.pushReplacementNamed(
                                context, MessagesScreen.id);
                          },
                          title: MultiLang.currentLanguage.messages,
                        ),
                        SizedBox(height: 15),
                        SideBarButton(
                          color: Values.selectedPage == 4
                              ? kMainBlueColor.withOpacity(0.6)
                              : Colors.transparent,
                          onPress: () {
                            setState(() {
                              Values.selectedPage = 4;
                            });
                            final routeName =
                                ModalRoute.of(context)?.settings?.name;
                            if (routeName != null &&
                                routeName == SettingsScreen.id) {
                              return;
                            }
                            Navigator.pushReplacementNamed(
                                context, SettingsScreen.id);
                          },
                          title: MultiLang.currentLanguage.settings,
                        ),
                        SizedBox(height: 15),
                        SideBarButton(
                          onPress: () {
                            CustomAlertDialog.showCustomDialog(
                              MultiLang.currentLanguage.sureMsg,
                              MultiLang.currentLanguage.logoutMsg,
                              context,
                              () => AuthService.logout(context),
                              () => Navigator.pop(context),
                            );
                          },
                          title: MultiLang.currentLanguage.logout,
                        ),
                      ],
                    ),
                  ],
                ),
                SideBarButton(
                  onPress: () {},
                  title: MultiLang.currentLanguage.support,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SideBarButton extends StatelessWidget {
  final Color color;
  final String title;
  final Function onPress;
  const SideBarButton({
    this.title,
    this.onPress,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FlatButton(
        color: color ?? Colors.transparent,
        onPressed: onPress,
        child: Container(
          width: double.infinity,
          child: Text(title, style: kMainTextStyle),
        ));
  }
}
