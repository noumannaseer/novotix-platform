class User {
  String id;
  String loginName;
  String userName;
  String userRights;
  List<EventData> eventData = [];
  bool grandAccess;
  String message;

  User();

  static User mapToUser(Map data) {
    User user = new User();
    user.id = data['Id'];
    user.loginName = data['LoginName'];
    user.userName = data['UserName'];
    List<dynamic> eventMap = data["EventData"];

    user.eventData = eventMap.map((e) {
          return EventData.mapToEventData(e);
        })?.toList() ??
        [];

    user.userRights = data['UserRights'];
    user.grandAccess = data['GrandAccess'];
    user.message = data['Msg'];

    return user;
  }
}

class EventData {
  String eventId;
  String eventName;
  DateTime startDateTime;
  DateTime endDateTime;
  Address address;
  DateTime createdDataTime;
  String eventType;
  String status;

  EventData();

  static EventData mapToEventData(Map data) {
    EventData eventData = new EventData();
    eventData.eventId = data['EventId'];
    eventData.eventName = data['EventName'];
    eventData.startDateTime = data['StartDateTime'];
    eventData.endDateTime = data['EndDateTime'];
    eventData.address = Address.mapToAddress(data['Address']);
    eventData.createdDataTime = data['CreatedDataTime'];
    eventData.eventType = data['EventType'];
    eventData.status = data['Status'];
    return eventData;
  }
}

class Address {
  String streetName;
  String streetNumber;
  String zipCode;
  String city;
  String province;
  String country;
  String countryCode;

  static Address mapToAddress(Map data) {
    Address address = new Address();
    address.streetName = data['Streetname'];
    address.streetNumber = data['Streetnumber'];
    address.zipCode = data['Zipcode'];
    address.city = data['City'];
    address.province = data['Province'];
    address.country = data['Country'];
    address.countryCode = data['CountryCode'];
    return address;
  }
}
