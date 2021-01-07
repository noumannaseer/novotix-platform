import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/multilang_strings.dart';
import '../models/message_model.dart';
import '../network/headers.dart';
import '../utils/constants.dart';
import '../network/keys.dart';

class MessagesService {
  Future messagesListRequest() async {
    try {
      http.Response response = await http.get(
          Keys.baseUrl + Keys.messageListPath + Values.user.id,
          headers: Headers.headers);
      if (response.statusCode == 500) {
        ShowToast.showToast(MultiLang.currentLanguage.status500Msg);
        return null;
      }
      if (response.statusCode != 200) return null;
      return jsonDecode(response.body);
    } catch (e) {
      print(e);
    }
  }

  Future storeMessages() async {
    List filteredList = [];
    List dataList = await messagesListRequest();
    if (dataList != null)
      filteredList = dataList
          .where((element) =>
              element[MessageValues.MessageStatus] != Values.deleted)
          .toList();
    Values.messages = filteredList.map((e) => Message.fromMap(e)).toList();
  }

  static Future messageStatusUpdateRequest(
      String messageId, String messageStatus) async {
    final body = {
      MessageValues.Id: messageId,
      "UserId": Values.user.id,
      MessageValues.MessageStatus: messageStatus
    };
    http.Response response = await http.post(
      Keys.baseUrl +
          Keys.messageStatusUpdatePath +
          messageId +
          '/' +
          Values.user.id,
      headers: Headers.headers,
      body: jsonEncode(body),
    );
    if (response.statusCode == 500) {
      ShowToast.showToast(MultiLang.currentLanguage.status500Msg);
      return null;
    }
    if (response.statusCode != 200) return null;

    print("Message update status: ${response.body}");

    return jsonDecode(response.body);
  }
}
