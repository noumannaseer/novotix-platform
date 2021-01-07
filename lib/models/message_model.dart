import '../utils/constants.dart';

class Message {
  int id;
  int userId;
  String messageFrom;
  String messageSubject;
  String messageBody;
  String messageDateTime;
  String messageStatus;

  Message();

  Message.fromMap(Map data) {
    id = int.parse(data[MessageValues.Id]);
    userId = int.parse(data[MessageValues.UserId]);
    messageFrom = data[MessageValues.MessageFrom];
    messageSubject = data[MessageValues.MessageSubject];
    messageBody = data[MessageValues.MessageBody];
    messageDateTime = data[MessageValues.MessageDatetime];
    messageStatus = data[MessageValues.MessageStatus];
  }
}
