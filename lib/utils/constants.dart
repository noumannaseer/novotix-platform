import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../network/messages_service.dart';
import '../network/sync_status.dart';
import '../database_helper/database_helper.dart';
import '../res.dart';
import '../models/message_model.dart';
import '../models/ticket_model.dart';
import '../network/keys.dart';
import '../models/user_model.dart';
import 'multilang_strings.dart';

const kMainBlackColor = Color(0xFF313131);
const kMainBlueColor = Color(0xFF00B3FE);
const kMainTextStyle =
    TextStyle(fontSize: 14, color: Colors.white, fontFamily: 'Poppins');

class Values {
  static const Duration time = Duration(minutes: 1);
  static const String deleted = 'deleted';
  static String selectedEventId = '';
  static bool isSoundOn = true;
  static int selectedPage = 0;
  static User user;
  static EventData event;
  static TicketModel ticket;
  static const String eventTypeTheme = 'theme';
  static List<Message> messages = [];
  static List<TicketModel> ticketList = [];
  static List<TicketModel> filteredTicketList = [];
  static const String en = 'en';
  static const String nl = 'nl';
  static String apiLang = 'en';
  static const String restoration = 'restoration';
  static const String validation = 'validation';
  static final defaultBody = {
    Keys.phoneLanguage: apiLang,
  };

  static String formattedDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime).toString();
  }
}

class TicketValues {
  static const String evenDataId = 'Id';
  static const String bookingId = 'BookingId';
  static const String eventId = 'EventId';
  static const String barcodeId = 'BarcodeId';
  static const String attendeeName = 'AttendeeName';
  static const String ticketType = 'TicketType';
  static const String validFromDateTime = 'ValidFromDatetime';
  static const String validToDateTime = 'ValidToDatetime';
  static const String ticketValidated = 'TicketValidated';
  static const String ticketValidatedDateTime = 'TicketValidatedDatetime';
  static const String status = 'Status';
  static const String ticketValidationStatus = 'TicketValidationStatus';
  static const String ticketValidationUserId = 'TicketValidationUserId';
  static const String TicketValidationStatus = 'TicketValidationStatus';
}

class MessageValues {
  static const String Id = "Id";
  static const String UserId = "UserId";
  static const String MessageFrom = "MessageFrom";
  static const String MessageSubject = "MessageSubject";
  static const String MessageBody = "MessageBody";
  static const String MessageDatetime = "MessageDatetime";
  static const String MessageStatus = "MessageStatus";
}

class ShowToast {
  static void showToast(String message) {
    Fluttertoast.showToast(
      backgroundColor: kMainBlackColor.withOpacity(0.8),
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 2,
    );
  }
}

class OnError {
  static void onError(String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ButtonBarTheme(
        data: ButtonBarThemeData(alignment: MainAxisAlignment.center),
        child: AlertDialog(
          title: Row(
            children: [
              SvgPicture.asset(
                Res.nt,
                width: 40,
              ),
              SizedBox(width: 10.0),
              Text(
                MultiLang.currentLanguage.error,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          content: Text(
            message,
            style: kMainTextStyle.copyWith(color: kMainBlackColor),
          ),
          actions: [
            FlatButton(
                minWidth: 100,
                color: kMainBlueColor,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  MultiLang.currentLanguage.ok,
                  style: kMainTextStyle,
                ))
          ],
        ),
      ),
    );
  }
}

class CustomAlertDialog {
  static void showCustomDialog(String title, String message,
      BuildContext context, Function onYes, Function onNo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            SvgPicture.asset(
              Res.nt,
              width: 40,
            ),
            SizedBox(width: 10.0),
            Text(title),
          ],
        ),
        content: Text(
          message,
          style: kMainTextStyle.copyWith(color: kMainBlackColor),
        ),
        actions: <Widget>[
          FlatButton(
            splashColor: kMainBlueColor.withOpacity(0.2),
            onPressed: onNo,
            child: Text(
              MultiLang.currentLanguage.no,
              style: kMainTextStyle.copyWith(color: kMainBlackColor),
            ),
          ),
          FlatButton(
            color: kMainBlueColor,
            onPressed: onYes,
            child: Text(
              MultiLang.currentLanguage.yes,
              style: kMainTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class InitData {
  static Future<void> initializeData() async {
    DatabaseHelper database = DatabaseHelper.instance;
    Timer.periodic(
      Values.time,
      (Timer t) {
        SyncStatus().syncStatusRequest();
        MessagesService().storeMessages();
      },
    );
    SyncStatus().syncStatusRequest();
    Values.ticketList = await database.getAllTicketsFromDatabase();
  }
}
