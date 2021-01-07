import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:novotix_app/database_helper/shared_preferences.dart';
import 'scan_screen.dart';
import '../utils/multilang_strings.dart';
import '../network/ticketlist_service.dart';
import '../components/main_body.dart';
import '../utils/constants.dart';

class EventsSelectionScreen extends StatefulWidget {
  static const String id = 'events_selection_screen';
  @override
  _EventsSelectionScreenState createState() => _EventsSelectionScreenState();
}

class _EventsSelectionScreenState extends State<EventsSelectionScreen> {
  final ScrollController scrollController = ScrollController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: MainBody(
        isEventScreen: true,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              MultiLang.currentLanguage.eventSelectionMsg,
              style: TextStyle(
                  color: Colors.white, fontSize: 18, fontFamily: 'Poppins'),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: BoxDecoration(
              color: kMainBlackColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 13),
                Container(
                  color: kMainBlueColor,
                  width: MediaQuery.of(context).size.width * 0.24,
                  height: 3,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30.0, right: 10),
                    child: Theme(
                      data: ThemeData.dark().copyWith(
                        highlightColor: kMainBlueColor,
                      ),
                      child: Scrollbar(
                        isAlwaysShown: true,
                        thickness: 3,
                        controller: scrollController,
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: Values.user.eventData.length,
                          itemBuilder: (context, item) => Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: FlatButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                Values.selectedEventId =
                                    Values.user.eventData[item].eventId;
                                Values.event = Values.user.eventData[item];
                                await DataCache.preferences.setString(
                                    DataCache.selectedEventId,
                                    Values.user.eventData[item].eventId);
                                await TicketListService.ticketListRequest(item);
                                print(
                                    "Ticket List Length: ${Values.ticketList.length}");
                                if (Values.ticketList.isEmpty) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  return;
                                }
                                ShowToast.showToast(MultiLang
                                    .currentLanguage.ticketDetailsSaved);
                                setState(() {
                                  _isLoading = false;
                                });
                                Values.selectedPage = 1;
                                Navigator.pushReplacementNamed(
                                    context, ScanScreen.id);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Values.user.eventData[item].eventName,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.82,
                                    height: 1,
                                    color: kMainBlueColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
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
    );
  }
}
