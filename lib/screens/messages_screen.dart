import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../network/messages_service.dart';
import '../utils/multilang_strings.dart';
import '../components/custom_dialogbox.dart';
import '../res.dart';
import '../utils/constants.dart';
import '../components/content_box.dart';
import '../components/main_body.dart';

class MessagesScreen extends StatefulWidget {
  static const String id = 'messages_screen';
  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final ScrollController scrollController = ScrollController();
  String read = 'read';
  String newMsg = 'new';
  String deleteMsg = 'delete';

  void _messageStatusUpdate(int item) {
    Navigator.pop(context);
    if (Values.messages[item].messageStatus == read) {
      setState(() {
        Values.messages[item].messageStatus = newMsg;
      });
      MessagesService.messageStatusUpdateRequest(
          Values.messages[item].id.toString(),
          Values.messages[item].messageStatus);
      return;
    }
    setState(() {
      Values.messages[item].messageStatus = read;
    });
    MessagesService.messageStatusUpdateRequest(
            Values.messages[item].id.toString(),
            Values.messages[item].messageStatus)
        .then((value) => null);
  }

  void _deleteMessage(int item) {
    CustomAlertDialog.showCustomDialog(
      MultiLang.currentLanguage.sureMsg,
      MultiLang.currentLanguage.deleteMsg,
      context,
      () {
        MessagesService.messageStatusUpdateRequest(
            Values.messages[item].id.toString(), Values.deleted);
        setState(() {
          Values.messages.removeAt(item);
        });

        Navigator.pop(context);
      },
      () {
        Navigator.pop(context);
      },
    );
  }

  void _showMessageDialog(int item) {
    showDialog(
        context: context,
        builder: (context) => CustomDialogBox(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    MultiLang.currentLanguage.message,
                    style: kMainTextStyle.copyWith(
                        fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                  SizedBox(height: 20),
                  CustomDialogBoxText(
                      '${MultiLang.currentLanguage.from}: ${Values.messages[item].messageFrom}'),
                  SizedBox(height: 5),
                  CustomDialogBoxText(
                      '${MultiLang.currentLanguage.date}: ${Values.messages[item].messageDateTime}'),
                  SizedBox(height: 5),
                  CustomDialogBoxText(
                      '${MultiLang.currentLanguage.subject}: ${Values.messages[item].messageSubject}'),
                  SizedBox(height: 20),
                  CustomDialogBoxText('${Values.messages[item].messageBody}'),
                  SizedBox(height: 20),
                  CustomDialogBoxText(
                      '${MultiLang.currentLanguage.regards}, ${Values.messages[item].messageFrom}'),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.27,
                        height: MediaQuery.of(context).size.height * 0.04,
                        child: FlatButton(
                            padding: EdgeInsets.all(0),
                            color: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            onPressed: () {
                              Navigator.pop(context);

                              _deleteMessage(item);
                            },
                            child: Text(
                              MultiLang.currentLanguage.delete,
                              style: kMainTextStyle.copyWith(fontSize: 10),
                            )),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.27,
                        height: MediaQuery.of(context).size.height * 0.04,
                        child: FlatButton(
                            padding: EdgeInsets.all(0),
                            color: kMainBlueColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            onPressed: () {
                              _messageStatusUpdate(item);
                            },
                            child: Text(
                              Values.messages[item].messageStatus == read
                                  ? MultiLang.currentLanguage.markAsUnread
                                  : MultiLang.currentLanguage.markAsRead,
                              style: kMainTextStyle.copyWith(fontSize: 10),
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return MainBody(
      children: [
        ContentBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                SizedBox(height: 12),
                Text(
                  MultiLang.currentLanguage.messages,
                  style: kMainTextStyle.copyWith(fontSize: 18),
                ),
                Expanded(
                  child: Values.messages.isEmpty
                      ? Center(
                          child: Text(
                            MultiLang.currentLanguage.noMsg,
                            style: kMainTextStyle.copyWith(fontSize: 18),
                          ),
                        )
                      : Theme(
                          data: ThemeData.dark().copyWith(
                            highlightColor: kMainBlueColor,
                          ),
                          child: Scrollbar(
                            isAlwaysShown: true,
                            thickness: 3,
                            controller: scrollController,
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: Values.messages.length,
                              itemBuilder: (context, item) => Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: FlatButton(
                                  padding: EdgeInsets.all(0),
                                  splashColor: kMainBlueColor.withOpacity(0.2),
                                  onPressed: () {
                                    setState(() {});
                                    _showMessageDialog(item);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 20.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${Values.messages[item].messageDateTime} | ${Values.messages[item].messageFrom}',
                                                    style:
                                                        kMainTextStyle.copyWith(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Values
                                                                  .messages[
                                                                      item]
                                                                  .messageStatus ==
                                                              read
                                                          ? Colors.grey
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${Values.messages[item].messageSubject}',
                                                    style:
                                                        kMainTextStyle.copyWith(
                                                      fontSize: 10,
                                                      color: Values
                                                                  .messages[
                                                                      item]
                                                                  .messageStatus ==
                                                              read
                                                          ? Colors.grey
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 20),
                                            SvgPicture.asset(
                                              Values.messages[item]
                                                          .messageStatus ==
                                                      read
                                                  ? Res.read
                                                  : Res.unread,
                                              width: 23,
                                              color: kMainBlueColor,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Container(
                                          height: 2,
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
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
