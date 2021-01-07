import '../utils/constants.dart';

class TicketModel {
  int evenDataId;
  int bookingId;
  int eventId;
  String barcodeId;
  String attendeeName;
  String ticketType;
  String validFromDateTime;
  String validToDateTime;
  int ticketValidated;
  String ticketValidatedDateTime;
  int ticketValidationStatus;
  String status;

  Map<String, dynamic> toMap() {
    return {
      TicketValues.evenDataId: evenDataId,
      TicketValues.bookingId: bookingId,
      TicketValues.eventId: eventId,
      TicketValues.barcodeId: barcodeId,
      TicketValues.attendeeName: attendeeName,
      TicketValues.ticketType: ticketType,
      TicketValues.validFromDateTime: validFromDateTime,
      TicketValues.validToDateTime: validToDateTime,
      TicketValues.ticketValidated: ticketValidated,
      TicketValues.ticketValidatedDateTime: ticketValidatedDateTime,
      TicketValues.TicketValidationStatus: ticketValidationStatus,
      TicketValues.status: status,
    };
  }

  TicketModel();
  static TicketModel mapToTicket(Map data) {
    TicketModel ticket = new TicketModel();
    ticket.evenDataId = data[TicketValues.evenDataId];
    ticket.bookingId = data[TicketValues.bookingId];
    ticket.eventId = data[TicketValues.eventId];
    ticket.barcodeId = data[TicketValues.barcodeId];
    ticket.attendeeName = data[TicketValues.attendeeName];
    ticket.ticketType = data[TicketValues.ticketType];
    ticket.validFromDateTime = data[TicketValues.validFromDateTime];
    ticket.validToDateTime = data[TicketValues.validToDateTime];
    ticket.ticketValidated = data[TicketValues.ticketValidated];
    ticket.ticketValidatedDateTime = data[TicketValues.ticketValidatedDateTime];
    ticket.ticketValidationStatus = data[TicketValues.TicketValidationStatus];
    ticket.status = data[TicketValues.status];
    return ticket;
  }

  static List<TicketModel> getFromListItems(String data) {
    List<String> newData = data.split("\n");
    newData.removeAt(0);
    List<TicketModel> tickets = newData.map((e) {
      if (e.isEmpty) {
        return null;
      }
      List<String> csvItems = e.split(",");
      print(csvItems.toString());
      TicketModel ticketModel = TicketModel();
      ticketModel.evenDataId = int.parse(csvItems[0]);
      ticketModel.bookingId = int.parse(csvItems[1]);
      ticketModel.eventId = int.parse(csvItems[2]);
      ticketModel.barcodeId = csvItems[3];
      ticketModel.attendeeName = csvItems[4];
      ticketModel.ticketType = csvItems[5];
      ticketModel.validFromDateTime = csvItems[6];
      ticketModel.validToDateTime = csvItems[7];
      ticketModel.ticketValidated = int.parse(
          csvItems[8] == null || csvItems[8] == "" ? "0" : csvItems[8]);
      ticketModel.ticketValidatedDateTime = csvItems[9];
      ticketModel.ticketValidationStatus = int.parse(csvItems[10]);
      ticketModel.status = csvItems[11];
      return ticketModel;
    }).toList();
    return tickets;
  }

  @override
  String toString() {
    return 'TicketModel{id: $evenDataId, bookingId: $bookingId, eventId: $eventId, barcodeId: $barcodeId, attendeeName: $attendeeName, ticketType: $ticketType, validFromDateTime: $validFromDateTime, validToDateTime: $validToDateTime, ticketValidate: $ticketValidated, ticketValidatedDateTime: $ticketValidatedDateTime, ticketValidationStatus: $ticketValidationStatus ,status: $status}';
  }
}
