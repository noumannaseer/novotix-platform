import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:novotix_app/utils/multilang_strings.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:audioplayers/audio_cache.dart';
import '../res.dart';
import '../network/ticketlist_service.dart';
import '../components/custom_dialogbox.dart';
import '../utils/constants.dart';
import '../components/main_body.dart';

class ScanScreen extends StatefulWidget {
  static const String id = 'scan_screen';
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final player = AudioCache();

  QRViewController _controller;
  bool _tapToScan = true;
  bool _isScannerOpened = false;
  bool _ticketIsValid = false;
  bool _ticketIsInvalid = false;
  bool _ticketNotFound = false;
  bool _ticketExpired = false;

  void _playInvalidSound() {
    if (Values.isSoundOn) player.play('invalid.mp3');
  }

  void _playValidSound() {
    if (Values.isSoundOn) player.play('success.mp3');
  }

  void _updateTicketForStatusNull() {
    setState(() {
      _ticketIsValid = false;
      _isScannerOpened = false;
      _tapToScan = false;
      _ticketIsInvalid = true;
      _ticketNotFound = true;
      _ticketExpired = false;
    });
    _playInvalidSound();
    _controller?.dispose();
  }

  void _updateTicketForStatusValidated() {
    setState(() {
      _ticketIsValid = false;
      _isScannerOpened = false;
      _tapToScan = false;
      _ticketIsInvalid = true;
      _ticketNotFound = false;
      _ticketExpired = false;
    });
    _playInvalidSound();
    _controller?.dispose();
  }

  void _updateTicketForStatusExpired() {
    setState(() {
      _ticketIsValid = false;
      _isScannerOpened = false;
      _tapToScan = false;
      _ticketIsInvalid = false;
      _ticketNotFound = false;
      _ticketExpired = true;
    });
    _playInvalidSound();
    _controller?.dispose();
    _showWarningDialog();
  }

  void _updateTicketForStatusAccepted() {
    setState(() {
      _ticketIsValid = true;
      _isScannerOpened = false;
      _tapToScan = false;
      _ticketIsInvalid = false;
      _ticketNotFound = false;
      _ticketExpired = false;
    });
    _playValidSound();
    _controller?.dispose();
  }

  void _onQRViewCreated(QRViewController controller) async {
    String qrText = "";
    this._controller = controller;
    qrText = await controller.scannedDataStream.first;

    print("QR Code: $qrText");

    int validation = await TicketListService.validateTicket(qrText);

    print("case: $validation");

    switch (validation) {
      case TicketListService.TICKET_STATUS_NULL:
        _updateTicketForStatusNull();
        break;
      case TicketListService.TICKET_STATUS_VALIDATED:
        _updateTicketForStatusValidated();
        break;
      case TicketListService.TICKET_STATUS_EXPIRED:
        _updateTicketForStatusExpired();
        break;
      case TicketListService.TICKET_STATUS_ACCEPTED:
        _updateTicketForStatusAccepted();
        break;
      default:
        _updateTicketForStatusNull();
        break;
    }
  }

  void _showWarningDialog() {
    showDialog(
        context: context,
        builder: (context) => CustomDialogBox(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    MultiLang.currentLanguage.warning,
                    style: kMainTextStyle.copyWith(
                        fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                  SizedBox(height: 20),
                  CustomDialogBoxText(MultiLang.currentLanguage.outsideTxt),
                  SizedBox(height: 20),
                  CustomDialogBoxText(
                      '${MultiLang.currentLanguage.original} ${MultiLang.currentLanguage.validFrom.toLowerCase()}: ${Values.ticket.validFromDateTime}'),
                  SizedBox(height: 10),
                  CustomDialogBoxText(
                      '${MultiLang.currentLanguage.original} ${MultiLang.currentLanguage.validTo.toLowerCase()}: ${Values.ticket.validToDateTime}'),
                  SizedBox(height: 20),
                  CustomDialogBoxText(
                      '${MultiLang.currentLanguage.dateTimeNow}: ${Values.formattedDateTime(DateTime.now())}'),
                  SizedBox(height: 20),
                  CustomDialogBoxText(MultiLang.currentLanguage.confirmAccept),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FlatButton(
                          color: Color(0xFFE82121),
                          height: MediaQuery.of(context).size.height * 0.04,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          onPressed: () {
                            setState(() {
                              _ticketIsValid = false;
                              _isScannerOpened = false;
                              _tapToScan = false;
                              _ticketIsInvalid = true;
                              _ticketNotFound = true;
                              _ticketExpired = false;
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            MultiLang.currentLanguage.declineTicket,
                            style: kMainTextStyle.copyWith(fontSize: 11),
                          )),
                      FlatButton(
                          color: Color(0xFF63B623),
                          height: MediaQuery.of(context).size.height * 0.04,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);

                            Values.ticket.ticketValidated = 1;
                            Values.ticket.ticketValidationStatus = 1;
                            Values.ticket.ticketValidatedDateTime =
                                Values.formattedDateTime(DateTime.now());
                            await TicketListService.acceptTicket(Values.ticket);
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
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MainBody(
          isEventScreen: false,
          children: [
            if (_tapToScan)
              BodyContainer(
                onPress: () {
                  setState(() {
                    _isScannerOpened = true;
                    _ticketIsValid = false;
                    _tapToScan = false;
                    _ticketIsInvalid = false;
                    _ticketNotFound = false;
                    _ticketExpired = false;
                  });
                },
                child: BodyInnerContent(
                  fontSize: 18,
                  text: MultiLang.currentLanguage.tapToScan,
                ),
              ),
            if (_isScannerOpened)
              Stack(
                children: [
                  BodyContainer(
                    onPress: null,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          (MediaQuery.of(context).size.width * 0.82) / 2),
                      child: QRView(
                        key: qrKey,
                        onQRViewCreated: _onQRViewCreated,
                        overlay: QrScannerOverlayShape(
                          borderColor: kMainBlueColor,
                          borderWidth: 5,
                          cutOutSize: MediaQuery.of(context).size.width * 0.59,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 25,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isScannerOpened = false;
                          _ticketIsValid = false;
                          _tapToScan = true;
                          _ticketIsInvalid = false;
                          _ticketNotFound = false;
                          _ticketExpired = false;
                        });
                      },
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 25,
                    child: GestureDetector(
                      onTap: () {
                        print('Flash Light off');

                        _controller.toggleFlash();

                        print('Flash Light on');
                      },
                      child: Icon(
                        Icons.highlight_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            if (_ticketIsValid)
              TicketValidation(
                onPress: () {
                  setState(() {
                    _isScannerOpened = false;
                    _ticketIsValid = false;
                    _tapToScan = true;
                    _ticketIsInvalid = false;
                    _ticketNotFound = false;
                    _ticketExpired = false;
                  });
                },
                ticketStatusText:
                    MultiLang.currentLanguage.successfullyCheckedIn,
                color: Color(0xFF63B623),
                text: MultiLang.currentLanguage.valid.toUpperCase(),
                icon: Icon(
                  Icons.check,
                  size: 131,
                  color: Colors.white,
                ),
              ),
            if (_ticketIsInvalid)
              TicketValidation(
                onPress: () {
                  setState(() {
                    _isScannerOpened = false;
                    _ticketIsValid = false;
                    _tapToScan = true;
                    _ticketIsInvalid = false;
                    _ticketNotFound = false;
                    _ticketExpired = false;
                  });
                },
                headerText: _ticketNotFound
                    ? MultiLang.currentLanguage.ticketNotFound
                    : null,
                checkInText: _ticketNotFound
                    ? MultiLang.currentLanguage.unknownTicket
                    : null,
                regularTicketText:
                    _ticketNotFound ? MultiLang.currentLanguage.notFound : null,
                ticketStatusText: _ticketNotFound
                    ? MultiLang.currentLanguage.notFoundInDb
                    : MultiLang.currentLanguage.alreadyChecked,
                color: Color(0xFFE82121),
                text: MultiLang.currentLanguage.invalid.toUpperCase(),
                icon: Icon(
                  Icons.close,
                  size: 131,
                  color: Colors.white,
                ),
              ),
            if (_ticketExpired)
              TicketValidation(
                onPress: () {
                  setState(() {
                    _isScannerOpened = false;
                    _ticketIsValid = false;
                    _tapToScan = true;
                    _ticketIsInvalid = false;
                    _ticketNotFound = false;
                    _ticketExpired = false;
                  });
                },
                checkInText: MultiLang.currentLanguage.outsideValidation,
                ticketStatusText: MultiLang.currentLanguage.wantToAcceptTicket,
                color: Color(0xFFE8BC21),
                text:
                    '${MultiLang.currentLanguage.valid} \n${MultiLang.currentLanguage.warning}',
                icon: Icon(
                  Icons.check,
                  size: 131,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class TicketValidation extends StatelessWidget {
  final String text;
  final Widget icon;
  final Color color;
  final String headerText;
  final String checkInText;
  final String regularTicketText;
  final String ticketStatusText;
  final Function onPress;

  const TicketValidation({
    Key key,
    this.text,
    this.icon,
    this.color,
    this.headerText,
    this.checkInText,
    this.regularTicketText,
    this.ticketStatusText,
    this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          headerText ?? "${Values.ticket.attendeeName}",
          style: kMainTextStyle.copyWith(fontSize: 18),
        ),
        Text(
          checkInText ??
              '${MultiLang.currentLanguage.checkedInAt} ${Values.ticket.ticketValidatedDateTime}',
          style: kMainTextStyle,
        ),
        SizedBox(height: 25),
        BodyContainer(
          onPress: onPress,
          color: color,
          child: BodyInnerContent(
            text: text,
            icon: icon,
          ),
        ),
        SizedBox(height: 10),
        Text(
          regularTicketText ?? '${Values.ticket.ticketType}',
          style: kMainTextStyle.copyWith(fontSize: 18),
        ),
        Text(
          ticketStatusText,
          style: kMainTextStyle,
        ),
      ],
    );
  }
}

class BodyInnerContent extends StatelessWidget {
  final Widget icon;
  final String text;
  final double fontSize;

  const BodyInnerContent({
    Key key,
    this.icon,
    this.text,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon ??
            SvgPicture.asset(
              Res.tap,
              width: 72,
              color: kMainBlueColor,
            ),
        SizedBox(height: 25),
        Text(
          text,
          textAlign: TextAlign.center,
          style: kMainTextStyle.copyWith(fontSize: fontSize ?? 36),
        ),
      ],
    );
  }
}

class BodyContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final Function onPress;

  const BodyContainer({this.child, this.color, this.onPress});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.82,
      height: MediaQuery.of(context).size.width * 0.82,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color ?? kMainBlackColor,
      ),
      child: FlatButton(
        padding: EdgeInsets.all(0),
        onPressed: onPress,
        child: child,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              (MediaQuery.of(context).size.width * 0.82) / 2),
        ),
      ),
    );
  }
}
