import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/multilang_strings.dart';
import '../database_helper/database_helper.dart';
import '../models/ticket_model.dart';
import '../utils/constants.dart';
import 'headers.dart';
import 'keys.dart';

class TicketListService {
  static const TICKET_STATUS_NULL = 0;
  static const TICKET_STATUS_VALIDATED = TICKET_STATUS_NULL + 1;
  static const TICKET_STATUS_EXPIRED = TICKET_STATUS_VALIDATED + 1;
  static const TICKET_STATUS_ACCEPTED = TICKET_STATUS_EXPIRED + 1;

  static Future _ticketListRequest(String id) async {
    http.Response response = await http.post(
        Keys.baseUrl + Keys.ticketListPath + id,
        headers: Headers.headers,
        body: jsonEncode(Values.defaultBody));
    if (response.statusCode == 500) {
      ShowToast.showToast(MultiLang.currentLanguage.status500Msg);
      return null;
    }
    if (response.statusCode == 404) {
      ShowToast.showToast(MultiLang.currentLanguage.status404Msg);
      return null;
    }
    if (response.statusCode != 200) return null;
    return response.body;
  }

  static Future ticketValidationRequest(String id, dynamic body) async {
    http.Response response = await http.post(
      Keys.baseUrl + Keys.ticketValidatePath + id,
      headers: Headers.headers,
      body: jsonEncode({
        ...body,
        ...Values.defaultBody,
      }),
    );
    if (response.statusCode == 500) {
      ShowToast.showToast(MultiLang.currentLanguage.status500Msg);
      return null;
    }
    if (response.statusCode == 404) {
      ShowToast.showToast(MultiLang.currentLanguage.status404Msg);
      return null;
    }
    if (response.statusCode != 200) return null;

    return jsonDecode(response.body);
  }

  static Future<void> ticketListRequest(int item) async {
    print('event id: ${Values.user.eventData[item].eventId}');
    String data = await _ticketListRequest(Values.user.eventData[item].eventId);
    if (data == null) return;
    await _save(data);
  }

  static Future<void> _save(String data) async {
    DatabaseHelper database = DatabaseHelper.instance;

    await database.deleteTable();
    List<TicketModel> ticketList = TicketModel.getFromListItems(data);

    ticketList.forEach((ticket) async {
      if (ticket == null) return;
      await database.insert(ticket);
      print("New Id: ${ticket.evenDataId}");
    });
    Values.ticketList = await database.getAllTicketsFromDatabase();
    Values.filteredTicketList = ticketList;
  }

  static Future<int> validateTicket(String barcode) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    Values.ticket = await helper.queryTicketList(barcode);

    if (Values.ticket == null) return TICKET_STATUS_NULL;

    if (Values.ticket.ticketValidated == TICKET_STATUS_VALIDATED)
      return TICKET_STATUS_VALIDATED;

    DateTime dateFrom =
        DateTime.parse(jsonDecode(Values.ticket.validFromDateTime));
    DateTime dateTo = DateTime.parse(jsonDecode(Values.ticket.validToDateTime));
    print('Event type ${Values.event.eventType}');
    if (Values.event.eventType == Values.eventTypeTheme) if (DateTime.now()
            .isBefore(dateFrom) ||
        DateTime.now().isAfter(dateTo)) return TICKET_STATUS_EXPIRED;

    Values.ticket.ticketValidated = 1;
    Values.ticket.ticketValidationStatus = 1;
    Values.ticket.ticketValidatedDateTime =
        Values.formattedDateTime(DateTime.now());

    acceptTicket(Values.ticket);
    return TICKET_STATUS_ACCEPTED;
  }

  static Future<void> acceptTicket(TicketModel ticket) async {
    Values
        .ticketList[Values.ticketList
            .indexWhere((element) => element.barcodeId == ticket.barcodeId)]
        .ticketValidated = ticket.ticketValidated;
    Values
        .ticketList[Values.ticketList
            .indexWhere((element) => element.barcodeId == ticket.barcodeId)]
        .ticketValidationStatus = ticket.ticketValidationStatus;
    Values
        .ticketList[Values.ticketList
            .indexWhere((element) => element.barcodeId == ticket.barcodeId)]
        .ticketValidatedDateTime = ticket.ticketValidatedDateTime;

    DatabaseHelper helper = DatabaseHelper.instance;
    await helper.updateValidTicketInDatabase(
      TicketValues.ticketValidationStatus,
      ticket.barcodeId,
      ticket.ticketValidationStatus.toString(),
    );
    await helper.updateValidTicketInDatabase(
      TicketValues.ticketValidated,
      ticket.barcodeId,
      ticket.ticketValidated.toString(),
    );

    await helper.updateValidTicketInDatabase(
      TicketValues.ticketValidatedDateTime,
      ticket.barcodeId,
      ticket.ticketValidatedDateTime,
    );

    final body = {
      TicketValues.evenDataId: ticket.evenDataId,
      TicketValues.eventId: ticket.eventId,
      TicketValues.barcodeId: ticket.barcodeId,
      TicketValues.ticketValidated: ticket.ticketValidated,
      TicketValues.ticketValidatedDateTime: ticket.ticketValidatedDateTime,
      TicketValues.ticketValidationStatus:
          ticket.ticketValidated == 1 ? Values.validation : Values.restoration,
      TicketValues.ticketValidationUserId: Values.user.id,
    };
    final data = await ticketValidationRequest(ticket.eventId.toString(), body);

    print("Accepted ticket: $data");
  }
}
