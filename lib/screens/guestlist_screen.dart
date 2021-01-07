import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../utils/multilang_strings.dart';
import '../network/ticketlist_service.dart';
import '../components/content_box.dart';
import '../components/main_body.dart';
import '../res.dart';
import '../utils/constants.dart';
import '../components/custom_dialogbox.dart';

class GuestListScreen extends StatefulWidget {
  static const String id = 'guest_list_screen';
  @override
  _GuestListScreenState createState() => _GuestListScreenState();
}

class _GuestListScreenState extends State<GuestListScreen> {
  final ScrollController scrollController = ScrollController();

  bool _isLoading = false;

  void _initFilterList() {
    Values.filteredTicketList = Values.ticketList;
  }

  @override
  void initState() {
    _initFilterList();
    super.initState();
  }

  Future<void> _restoreTicket(int item) async {
    Navigator.pop(context);
    setState(() {
      Values.filteredTicketList[item].ticketValidated = 0;
      Values.filteredTicketList[item].ticketValidationStatus = 2;
      Values.filteredTicketList[item].ticketValidatedDateTime =
          Values.formattedDateTime(DateTime.now());
    });
    await TicketListService.acceptTicket(Values.filteredTicketList[item]);
  }

  Future<void> _acceptTicket(int item) async {
    Navigator.pop(context);
    setState(() {
      Values.filteredTicketList[item].ticketValidated = 1;
      Values.filteredTicketList[item].ticketValidationStatus = 1;
      Values.filteredTicketList[item].ticketValidatedDateTime =
          Values.formattedDateTime(DateTime.now());
    });
    await TicketListService.acceptTicket(Values.filteredTicketList[item]);
  }

  void _showDialog(int item) {
    showDialog(
        context: context,
        builder: (context) => CustomDialogBox(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    MultiLang.currentLanguage.ticketDetails,
                    style: kMainTextStyle.copyWith(
                        fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                  SizedBox(height: 20),
                  CustomDialogBoxText(
                      '${MultiLang.currentLanguage.validationStatus}: ${Values.filteredTicketList[item].ticketValidated == 1 ? MultiLang.currentLanguage.validated : MultiLang.currentLanguage.valid}'),
                  SizedBox(height: 5),
                  CustomDialogBoxText(
                      '${MultiLang.currentLanguage.validationDateTime}: ${Values.filteredTicketList[item].ticketValidatedDateTime}'),
                  SizedBox(height: 20),
                  CustomDialogBoxText(
                      '${MultiLang.currentLanguage.bookingId}: ${Values.filteredTicketList[item].bookingId}'),
                  SizedBox(height: 5),
                  CustomDialogBoxText(
                      '${MultiLang.currentLanguage.barcode}:  ${Values.filteredTicketList[item].barcodeId}'),
                  SizedBox(height: 5),
                  CustomDialogBoxText(
                      '${MultiLang.currentLanguage.ticketType}: ${Values.filteredTicketList[item].ticketType}'),
                  SizedBox(height: 20),
                  CustomDialogBoxText(
                      '${MultiLang.currentLanguage.validFrom}: ${Values.filteredTicketList[item].validFromDateTime}'),
                  SizedBox(height: 5),
                  CustomDialogBoxText(
                      '${MultiLang.currentLanguage.validTo}: ${Values.filteredTicketList[item].validToDateTime}'),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (Values.filteredTicketList[item].ticketValidated == 1)
                        FlatButton(
                            color: kMainBlueColor.withOpacity(0.8),
                            disabledColor: kMainBlueColor.withOpacity(0.2),
                            height: MediaQuery.of(context).size.height * 0.04,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            onPressed: Values.user.userRights != 'manager'
                                ? null
                                : () async {
                                    await _restoreTicket(item);
                                  },
                            child: Text(
                              MultiLang.currentLanguage.restoreTicket,
                              style: kMainTextStyle.copyWith(fontSize: 11),
                            )),
                      if (Values.filteredTicketList[item].ticketValidated != 1)
                        FlatButton(
                            color: Color(0xFF63B623).withOpacity(0.8),
                            height: MediaQuery.of(context).size.height * 0.04,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            onPressed: () async {
                              await _acceptTicket(item);
                            },
                            child: Text(
                              MultiLang.currentLanguage.acceptTicket,
                              style: kMainTextStyle.copyWith(fontSize: 11),
                            )),
                    ],
                  ),
                ],
              ),
            ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: MainBody(
        children: [
          ContentBox(
            child: ModalProgressHUD(
              inAsyncCall: _isLoading,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 12),
                    Text(
                      MultiLang.currentLanguage.guestList,
                      style: kMainTextStyle.copyWith(fontSize: 18),
                    ),
                    SizedBox(height: 12),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.80,
                      height: MediaQuery.of(context).size.height * 0.1,
                      child: TextFormField(
                        onChanged: (value) {
                          if (value.isEmpty) {
                            setState(() {
                              Values.filteredTicketList = Values.ticketList;
                            });
                            return;
                          }
                          setState(() {
                            Values.filteredTicketList =
                                Values.ticketList.where((ticket) {
                              return ticket.attendeeName
                                      .toLowerCase()
                                      .contains(value.toLowerCase()) ||
                                  ticket.barcodeId
                                      .toLowerCase()
                                      .contains(value.toLowerCase()) ||
                                  ticket.bookingId
                                      .toString()
                                      .toLowerCase()
                                      .contains(value.toLowerCase());
                            }).toList();
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(50.0),
                            ),
                          ),
                          contentPadding: const EdgeInsets.only(left: 20),
                          hintText: MultiLang.currentLanguage.search,
                          hintStyle: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Values.filteredTicketList.isEmpty
                          ? Center(
                              child: Text(
                                MultiLang.currentLanguage.noGuestFound,
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
                                  itemCount: Values.filteredTicketList.length,
                                  itemBuilder: (context, item) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
                                    child: FlatButton(
                                      padding: EdgeInsets.all(0),
                                      splashColor:
                                          kMainBlueColor.withOpacity(0.2),
                                      onPressed: () {
                                        setState(() {});
                                        _showDialog(item);
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${Values.filteredTicketList[item].attendeeName} | ${Values.filteredTicketList[item].evenDataId} ${Values.filteredTicketList[item].bookingId}',
                                                    style: kMainTextStyle.copyWith(
                                                        fontSize: 11,
                                                        color: Values
                                                                    .filteredTicketList[
                                                                        item]
                                                                    .ticketValidated ==
                                                                1
                                                            ? Colors.grey
                                                            : Colors.white),
                                                  ),
                                                ),
                                                SizedBox(width: 20),
                                                Values.filteredTicketList[item]
                                                            .ticketValidated ==
                                                        1
                                                    ? Image.asset(
                                                        Res.iconCheck,
                                                        width: 23,
                                                      )
                                                    : SvgPicture.asset(
                                                        Res.out,
                                                        width: 23,
                                                      ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
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
          ),
        ],
      ),
    );
  }
}
