import 'dart:convert';
import 'package:http/http.dart' as http;
import '../database_helper/database_helper.dart';
import '../utils/multilang_strings.dart';
import '../network/headers.dart';
import '../network/keys.dart';
import '../utils/constants.dart';

class SyncStatus {
  Future<void> syncStatusRequest() async {
    DatabaseHelper database = DatabaseHelper.instance;

    final body = {
      Keys.appUserId: Values.user.id,
      Keys.phoneLanguage: Values.apiLang
    };

    http.Response response = await http.post(
      Keys.baseUrl + Keys.ticketListUpdatePath + Values.selectedEventId,
      headers: Headers.headers,
      body: jsonEncode(body),
    );
    if (response.statusCode == 500) {
      ShowToast.showToast(MultiLang.currentLanguage.status500Msg);
      return;
    }

    List data = jsonDecode(response.body);
    if (data.isEmpty || data.first[TicketValues.status] == 'empty') return;
    data.forEach((e) async {
      await database.syncLocalDatabase(
        int.parse(e[TicketValues.evenDataId]),
        e[TicketValues.status] == "validated" ? 1 : 0,
        e[TicketValues.status] == "validated" ? 1 : 2,
        e[TicketValues.ticketValidatedDateTime].toString(),
      );
    });
    Values.ticketList = await database.getAllTicketsFromDatabase();
    Values.filteredTicketList = Values.ticketList;
  }
}
