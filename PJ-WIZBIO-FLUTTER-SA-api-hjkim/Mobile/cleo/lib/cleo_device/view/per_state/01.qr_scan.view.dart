import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cleo/cleo_device/cartridge_info.dart';
import 'package:cleo/cleo_device/cleo_device.dart';
import 'package:cleo/cleo_device/cleo_state.dart';
import 'package:cleo/provider/bluetooth.provider.dart';
import 'package:cleo/screen/common/confirm_button.dart';
import 'package:cleo/util/device_mem.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:cleo/constants.dart' as cons;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScanView extends StatefulWidget {
  const QrScanView({Key? key}) : super(key: key);

  @override
  State<QrScanView> createState() => _QrScanViewState();
}

class _QrScanViewState extends State<QrScanView> with TickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? _qrViewController;
  bool showMessage = false;
  bool newTestBusy = false;

  final PageController _pageController = PageController(initialPage: 0);

  final TextEditingController _testTypeCtrl =
      TextEditingController(text: 'COVID-19');
  final TextEditingController _refNoCtrl = TextEditingController();
  final TextEditingController _lotNumberCtrl = TextEditingController();
  final TextEditingController _expDateCtrl = TextEditingController();
  String _ctValue = '100';

  String _cycle = '50'; //50,30sec reference
  String _isoTemperature = '61'; //61
  String _current = '2'; //2
  String _gainDefault = '2'; //2
  String _gainSelect = '2'; //2
  String _preTestCycle = '30'; //30,SP
  String _preTestTime = '10'; //10,SP
  String _afterTestCycle = '50'; //50,SC
  String _afterTestTime = '30'; //30,SC
  String _rtTemperature = '50'; //50
  String _rtTime = '300'; //300

  String pageTitle = 'Prepare Test';
  AssetsAudioPlayer? player;
  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page! >= 1) {
        setState(() {
          pageTitle = 'Begin Test';
        });
      } else {
        setState(() {
          pageTitle = 'Prepare Test';
        });
      }
    });

    player = AssetsAudioPlayer.newPlayer()
      ..open(
        Audio("assets/video/qr.mp3"),
        autoStart: true,
      );

    Future.delayed(const Duration(seconds: 10), () {
      setState(() {
        showMessage = true;
      });
    });
  }

  @override
  void dispose() {
    player?.stop();
    player?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _qrViewController!.pauseCamera();
    } else if (Platform.isIOS) {
      _qrViewController!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        goBack(context);
        return false;
      },
      child: Scaffold(
        appBar: !Platform.isAndroid
            ? AppBar(
                title: Text(
                  pageTitle,
                  style: const TextStyle(color: cons.primary),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(
                  color: Colors.black, //change your color here
                ),
                systemOverlayStyle: SystemUiOverlayStyle.dark,
              )
            : null,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  pageSnapping: false,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    buildQrView(context),
                    buildManualForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    // var scanArea = (MediaQuery.of(context).size.width < 400 ||
    //         MediaQuery.of(context).size.height < 400)
    //     ? 150.0
    //     : 300.0;
    var size = MediaQuery.of(context).size;
    var scanArea = size.width * 0.7;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: cons.primary,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: scanArea,
                  cutOutBottomOffset: 0,
                ),
                onPermissionSet: (ctrl, p) =>
                    _onPermissionSet(context, ctrl, p),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: size.height / 2 + size.width * 0.3,
          child: Container(
            width: size.width,
            padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.15, vertical: 24),
            child: const Text(
              'Align the code on the CLEO Test Cartridge pouch within the frame to scan.', //2023.10.16_CJH
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
        if (showMessage)
          Positioned(
            top: size.height / 2 + size.width * 0.3,
            child: Container(
              width: size.width,
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.15, vertical: 24),
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Please, ',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text:
                          'try moving the code or mobile camera to focus better. The code shouldn’t take up the entire screen.',  //2023.10.16_CJH
                      style: TextStyle(color: Colors.red),
                    )
                  ],
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    print('qr view created');

    _qrViewController = controller;
    controller.scannedDataStream.listen((Barcode? scanData) {
      setState(() {
        if (scanData == null) return;

        if (scanData.format != BarcodeFormat.dataMatrix) return;

        if (scanData.code == null) return;

        String scanCode =
            scanData.code!.replaceAll(RegExp('[^0-9a-zA-Z-]'), '');

        String? uniqueKey = scanCode.substring(2, 16);

        if (uniqueKey == null) return;

        switch (uniqueKey) {
          case '08800151200173':
            _testTypeCtrl.text = 'COVID-19';
            _refNoCtrl.text = 'CL1101P';
            _ctValue = '100';

            _cycle = '50'; //50,30sec reference
            _isoTemperature = '50'; //61->50
            _current = '12'; //12
            _gainDefault = '2'; //2
            _gainSelect = '2'; //2
            _preTestCycle = '30'; //30,SP
            _preTestTime = '10'; //10,SP
            _afterTestCycle = '50'; //40,SC
            _afterTestTime = '30'; //30,SC
            _rtTemperature = '50'; //50
            _rtTime = '0'; //300
            break;
          case '08800151200180':
            _testTypeCtrl.text = 'COVI-Flu';
            _refNoCtrl.text = 'CL1102P';
            _ctValue = '100';

            _cycle = '50'; //50,30sec reference
            _isoTemperature = '50'; //61
            _current = '12'; //12
            _gainDefault = '2'; //2
            _gainSelect = '2'; //2
            _preTestCycle = '30'; //30,SP
            _preTestTime = '10'; //10,SP
            _afterTestCycle = '50'; //40,SC
            _afterTestTime = '30'; //30,SC
            _rtTemperature = '50'; //50
            _rtTime = '0'; //300
            break;
          case '08800151200197':
            _testTypeCtrl.text = 'Influenza';
            _refNoCtrl.text = 'CL1103P';
            _ctValue = '100';

            _cycle = '50'; //50,30sec reference
            _isoTemperature = '50'; //61
            _current = '12'; //12
            _gainDefault = '2'; //2
            _gainSelect = '2'; //2
            _preTestCycle = '30'; //30,SP
            _preTestTime = '10'; //10,SP
            _afterTestCycle = '50'; //40,SC
            _afterTestTime = '30'; //30,SC
            _rtTemperature = '50'; //50
            _rtTime = '0'; //300
            break;
          case '08800151200074':
            _testTypeCtrl.text = 'RSV-MPV';
            _refNoCtrl.text = 'CL1104P';
            _ctValue = '100';

            _cycle = '50'; //50,30sec reference
            _isoTemperature = '50'; //61
            _current = '12'; //12
            _gainDefault = '2'; //2
            _gainSelect = '2'; //2
            _preTestCycle = '30'; //30,SP
            _preTestTime = '10'; //10,SP
            _afterTestCycle = '50'; //40,SC
            _afterTestTime = '30'; //30,SC
            _rtTemperature = '50'; //50
            _rtTime = '0'; //300
            break;
          case '08800151201019':
            _testTypeCtrl.text = 'CMV';
            _refNoCtrl.text = 'CL1105P';
            _ctValue = '100';

            _cycle = '50'; //50,30sec reference
            _isoTemperature = '50'; //50
            _current = '12'; //12
            _gainDefault = '2'; //2
            _gainSelect = '2'; //2
            _preTestCycle = '30'; //30,SP
            _preTestTime = '10'; //10,SP
            _afterTestCycle = '50'; //40,SC
            _afterTestTime = '30'; //30,SC
            _rtTemperature = '50'; //50
            _rtTime = '0'; //300
            break;
          case '08800151201026':
            _testTypeCtrl.text = 'RSV';
            _refNoCtrl.text = 'CL1106P';
            _ctValue = '100';

            _cycle = '50'; //50,30sec reference
            _isoTemperature = '50'; //50
            _current = '12'; //12
            _gainDefault = '2'; //2
            _gainSelect = '2'; //2
            _preTestCycle = '30'; //30,SP
            _preTestTime = '10'; //10,SP
            _afterTestCycle = '50'; //40,SC
            _afterTestTime = '30'; //30,SC
            _rtTemperature = '50'; //50
            _rtTime = '0'; //300
            break;
          default:
            _testTypeCtrl.text = 'Unknown';
            _refNoCtrl.text = 'CL0000';
            _ctValue = '100';

            _cycle = '50'; //50,30sec reference
            _isoTemperature = '50'; //50
            _current = '12'; //12
            _gainDefault = '2'; //2
            _gainSelect = '2'; //2
            _preTestCycle = '30'; //30,SP
            _preTestTime = '10'; //10,SP
            _afterTestCycle = '50'; //40,SC
            _afterTestTime = '30'; //30,SC
            _rtTemperature = '50'; //50
            _rtTime = '0'; //300
            break;
        }
        // String? expDate = scanCode.substring(18, 24);
        // String? lotNum = scanCode.substring(26);
        String divCheck = scanCode.substring(16, 18);
        String? lotNum, expDate;
        if (divCheck == '10') {
          lotNum = scanCode.substring(18, 27);
          expDate = scanCode.substring(29);
        } else {
          expDate = scanCode.substring(18, 24);
          lotNum = scanCode.substring(26);
        }

        if (expDate != null && lotNum != null) {
          String expString =
              '20${expDate.substring(0, 2)}-${expDate.substring(2, 4)}-${expDate.substring(4)}';
          // String expString =
          //     '20${expDate.substring(0, 2)}-01-${expDate.substring(4)}';
          if (DateTime.parse(expString).millisecondsSinceEpoch >
              DateTime.now().millisecondsSinceEpoch) {
            // 현재 시간보다 미래인지 확인
            _expDateCtrl.text = DateFormat('dd.MMM.yyy')
                .format(DateTime.parse(expString))
                .toUpperCase();
            _lotNumberCtrl.text = lotNum;

            _pageController.animateToPage(1,
                duration: const Duration(milliseconds: 1),
                curve: Curves.easeInOut);
            // _tabController.animateTo(1);
          } else {
            showExpiredError(
                'The Cartridge is invalid as it’s expired. You should use a valid CLEO ONE TEST Cartridge.');
            return;
          }
        }
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    debugPrint('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  Widget buildManualForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                maxHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Platform.isAndroid)
                  Text(
                    pageTitle,
                    style: const TextStyle(
                      color: cons.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: _testTypeCtrl,
                        readOnly: true,
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                              color: Colors.grey,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                              color: Colors.grey,
                            ),
                          ),
                          hintText: 'Search id or name',
                          label: Text('TEST TYPE'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        readOnly: true,
                        controller: _lotNumberCtrl,
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                              color: Colors.grey,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                              color: Colors.grey,
                            ),
                          ),
                          // hintText: 'Search id or name',
                          label: Text('LOT NUMBER'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _expDateCtrl,
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                              color: Colors.grey,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                              color: Colors.grey,
                            ),
                          ),
                          // hintText: 'Search id or name',
                          label: Text('EXP DATE'),
                        ),
                        readOnly: true,
                        onTap: () async {
                          // DateTime? selectedDate = await showDatePicker(
                          //   context: context,
                          //   initialDate: DateTime.now(),
                          //   firstDate: DateTime(DateTime.now().year),
                          //   lastDate: DateTime(DateTime.now().year + 3),
                          // );

                          // if (selectedDate != null) {
                          //   String formatDate = DateFormat('dd.MMM.yyyy')
                          //       .format(selectedDate)
                          //       .toUpperCase();
                          //   _expDateCtrl.text = formatDate;
                          // }
                        },
                      ),
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 24),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: const Text(
                            'Confirm Lot Number and Expiration Date shown match infomation on cartridge pouch.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 24),
                    child: ConfirmButton(
                      onPressed: () {
                        goToCartridgeProcessScreen(context);
                      },
                      label: 'CONFIRM',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showExpiredError(String msg) {
    if (newTestBusy) return;

    setState(() {
      newTestBusy = true;
    });

    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      setState(() {
        newTestBusy = false;
      });
    });
    showDialog(
      routeSettings: const RouteSettings(name: 'dialog'),
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    color: Color.fromRGBO(240, 151, 0, 1),
                    size: 130,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ERROR',
                    style: TextStyle(
                      color: Color(0xffC20018),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    msg,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xffCC6116),
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: FlatConfirmButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                      label: 'Rescan',
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: FlatConfirmButton(
                      onPressed: () async {
                        goBack(context);
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      label: 'Go to Home',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void goToCartridgeProcessScreen(BuildContext context) {
    final device = Provider.of<CleoDevice>(context, listen: false);

    assert(device.state is QrScanState,
        'current state is not QrScanState :: ${device.state.name}');

    final testType = _testTypeCtrl.text;
    final lotNum = _lotNumberCtrl.text;
    final expDate = _expDateCtrl.text;
    final refNo = _refNoCtrl.text;
    final ctValue = _ctValue;

    final cycle = _cycle;
    final isoTemperature = _isoTemperature;
    final current = _current;
    final gainDefault = _gainDefault;
    final gainSelect = _gainSelect;
    final preTestCycle = _preTestCycle;
    final preTestTime = _preTestTime;
    final afterTestCycle = _afterTestCycle;
    final afterTestTime = _afterTestTime;
    final rtTemperature = _rtTemperature;
    final rtTime = _rtTime;

    final cartridge = CartridgeInfo(
        testType,
        lotNum,
        expDate,
        refNo,
        ctValue,

        cycle,
        isoTemperature,
        current,
        gainDefault,
        gainSelect,
        preTestCycle,
        preTestTime,
        afterTestCycle,
        afterTestTime,
        rtTemperature,
        rtTime
    );

    device.setCartridge(cartridge);
    DeviceMem.setDeviceCartridgeInfo(device.device.id.toString(), cartridge);
    final state = (device.state as QrScanState);
    state.sendSetting();
  }

  void goBack(context) {
    final device =
        Provider.of<BluetoothProvider>(context, listen: false).currentDevice!;
    assert(device.state is QrScanState,
        'current state is not QrScanState :: ${device.state.name}');
    (device.state as QrScanState).sendCancel();
  }
}



// import 'dart:io';

// import 'package:assets_audio_player/assets_audio_player.dart';
// import 'package:cleo/cleo_device/cartridge_info.dart';
// import 'package:cleo/cleo_device/cleo_device.dart';
// import 'package:cleo/cleo_device/cleo_state.dart';
// import 'package:cleo/provider/bluetooth.provider.dart';
// import 'package:cleo/screen/common/confirm_button.dart';
// import 'package:cleo/util/device_mem.dart';
// import 'package:flutter/cupertino.dart';

// import 'package:flutter/material.dart';
// import 'package:cleo/constants.dart' as cons;
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';

// class QrScanView extends StatefulWidget {
//   const QrScanView({Key? key}) : super(key: key);

//   @override
//   State<QrScanView> createState() => _QrScanViewState();
// }

// class _QrScanViewState extends State<QrScanView> with TickerProviderStateMixin {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   Barcode? result;
//   QRViewController? _qrViewController;
//   bool showMessage = false;
//   bool newTestBusy = false;

//   final PageController _pageController = PageController(initialPage: 0);

//   final TextEditingController _testTypeCtrl =
//       TextEditingController(text: 'COVID-19');
//   final TextEditingController _refNoCtrl = TextEditingController();
//   final TextEditingController _lotNumberCtrl = TextEditingController();
//   final TextEditingController _expDateCtrl = TextEditingController();
//   String _ctValue = '100';

//   String _cycle = '50'; //50,30sec reference
//   String _isoTemperature = '61'; //61
//   String _current = '2'; //2
//   String _gainDefault = '2'; //2
//   String _gainSelect = '2'; //2
//   String _preTestCycle = '30'; //30,SP
//   String _preTestTime = '10'; //10,SP
//   String _afterTestCycle = '50'; //50,SC
//   String _afterTestTime = '30'; //30,SC
//   String _rtTemperature = '50'; //50
//   String _rtTime = '300'; //300

//   String pageTitle = 'Prepare Test';
//   AssetsAudioPlayer? player;
//   @override
//   void initState() {
//     super.initState();
//     _pageController.addListener(() {
//       if (_pageController.page! >= 1) {
//         setState(() {
//           pageTitle = 'Begin Test';
//         });
//       } else {
//         setState(() {
//           pageTitle = 'Prepare Test';
//         });
//       }
//     });

//     player = AssetsAudioPlayer.newPlayer()
//       ..open(
//         Audio("assets/video/qr.mp3"),
//         autoStart: true,
//       );

//     Future.delayed(const Duration(seconds: 10), () {
//       setState(() {
//         showMessage = true;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     player?.stop();
//     player?.dispose();
//     super.dispose();
//   }

//   @override
//   void reassemble() {
//     super.reassemble();
//     if (Platform.isAndroid) {
//       _qrViewController!.pauseCamera();
//     } else if (Platform.isIOS) {
//       _qrViewController!.resumeCamera();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         goBack(context);
//         return false;
//       },
//       child: Scaffold(
//         appBar: !Platform.isAndroid
//             ? AppBar(
//                 title: Text(
//                   pageTitle,
//                   style: const TextStyle(color: cons.primary),
//                 ),
//                 backgroundColor: Colors.transparent,
//                 elevation: 0,
//                 iconTheme: const IconThemeData(
//                   color: Colors.black, //change your color here
//                 ),
//                 systemOverlayStyle: SystemUiOverlayStyle.dark,
//               )
//             : null,
//         body: SafeArea(
//           child: Column(
//             children: [
//               Expanded(
//                 child: PageView(
//                   controller: _pageController,
//                   pageSnapping: false,
//                   physics: const NeverScrollableScrollPhysics(),
//                   children: [
//                     buildQrView(context),
//                     buildManualForm(),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildQrView(BuildContext context) {
//     // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
//     // var scanArea = (MediaQuery.of(context).size.width < 400 ||
//     //         MediaQuery.of(context).size.height < 400)
//     //     ? 150.0
//     //     : 300.0;
//     var size = MediaQuery.of(context).size;
//     var scanArea = size.width * 0.7;
//     // To ensure the Scanner view is properly sizes after rotation
//     // we need to listen for Flutter SizeChanged notification and update controller
//     return Stack(
//       children: [
//         Column(
//           children: [
//             Expanded(
//               child: QRView(
//                 key: qrKey,
//                 onQRViewCreated: _onQRViewCreated,
//                 overlay: QrScannerOverlayShape(
//                   borderColor: cons.primary,
//                   borderRadius: 10,
//                   borderLength: 30,
//                   borderWidth: 10,
//                   cutOutSize: scanArea,
//                   cutOutBottomOffset: 0,
//                 ),
//                 onPermissionSet: (ctrl, p) =>
//                     _onPermissionSet(context, ctrl, p),
//               ),
//             ),
//           ],
//         ),
//         Positioned(
//           bottom: size.height / 2 + size.width * 0.3,
//           child: Container(
//             width: size.width,
//             padding: EdgeInsets.symmetric(
//                 horizontal: size.width * 0.15, vertical: 24),
//             child: const Text(
//               'Align the code on the CLEO Test Cartridge pouch within the frame to scan.', //2023.10.16_CJH
//               style: TextStyle(
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ),
//         if (showMessage)
//           Positioned(
//             top: size.height / 2 + size.width * 0.3,
//             child: Container(
//               width: size.width,
//               padding: EdgeInsets.symmetric(
//                   horizontal: size.width * 0.15, vertical: 24),
//               child: RichText(
//                 text: const TextSpan(
//                   children: [
//                     TextSpan(
//                       text: 'Please, ',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     TextSpan(
//                       text:
//                           'try moving the code or mobile camera to focus better. The code shouldn’t take up the entire screen.', //2023.10.16_CJH
//                       style: TextStyle(color: Colors.red),
//                     )
//                   ],
//                   style: TextStyle(fontSize: 16),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   void _onQRViewCreated(QRViewController controller) {
//     print('qr view created');

//     _qrViewController = controller;
//     controller.scannedDataStream.listen((Barcode? scanData) {
//       setState(() {
//         if (scanData == null) return;

//         if (scanData.format != BarcodeFormat.dataMatrix) return;

//         if (scanData.code == null) return;

//         String scanCode =
//             scanData.code!.replaceAll(RegExp('[^0-9a-zA-Z-]'), '');

//         String? uniqueKey = scanCode.substring(2, 16);

//         if (uniqueKey == null) return;

//         switch (uniqueKey) {
//           case '08800151200173':
//             _testTypeCtrl.text = 'COVID-19';
//             _refNoCtrl.text = 'CL1101P';
//             _ctValue = '100';

//             _cycle = '50'; //50,30sec reference
//             _isoTemperature = '50'; //61->50
//             _current = '12'; //12
//             _gainDefault = '2'; //2
//             _gainSelect = '2'; //2
//             _preTestCycle = '30'; //30,SP
//             _preTestTime = '10'; //10,SP
//             _afterTestCycle = '50'; //40,SC
//             _afterTestTime = '30'; //30,SC
//             _rtTemperature = '50'; //50
//             _rtTime = '0'; //300
//             break;
//           case '08800151200180':
//             _testTypeCtrl.text = 'COVI-Flu';
//             _refNoCtrl.text = 'CL1102P';
//             _ctValue = '100';

//             _cycle = '50'; //50,30sec reference
//             _isoTemperature = '50'; //61
//             _current = '12'; //12
//             _gainDefault = '2'; //2
//             _gainSelect = '2'; //2
//             _preTestCycle = '30'; //30,SP
//             _preTestTime = '10'; //10,SP
//             _afterTestCycle = '50'; //40,SC
//             _afterTestTime = '30'; //30,SC
//             _rtTemperature = '50'; //50
//             _rtTime = '0'; //300
//             break;
//           case '08800151200197':
//             _testTypeCtrl.text = 'Influenza';
//             _refNoCtrl.text = 'CL1103P';
//             _ctValue = '100';

//             _cycle = '50'; //50,30sec reference
//             _isoTemperature = '50'; //61
//             _current = '12'; //12
//             _gainDefault = '2'; //2
//             _gainSelect = '2'; //2
//             _preTestCycle = '30'; //30,SP
//             _preTestTime = '10'; //10,SP
//             _afterTestCycle = '50'; //40,SC
//             _afterTestTime = '30'; //30,SC
//             _rtTemperature = '50'; //50
//             _rtTime = '0'; //300
//             break;
//           case '08800151200074':
//             _testTypeCtrl.text = 'RSV-MPV';
//             _refNoCtrl.text = 'CL1104P';
//             _ctValue = '100';

//             _cycle = '50'; //50,30sec reference
//             _isoTemperature = '50'; //61
//             _current = '12'; //12
//             _gainDefault = '2'; //2
//             _gainSelect = '2'; //2
//             _preTestCycle = '30'; //30,SP
//             _preTestTime = '10'; //10,SP
//             _afterTestCycle = '50'; //40,SC
//             _afterTestTime = '30'; //30,SC
//             _rtTemperature = '50'; //50
//             _rtTime = '0'; //300
//             break;
//           case '08800151201019':
//             _testTypeCtrl.text = 'CMV';
//             _refNoCtrl.text = 'CL1105P';
//             _ctValue = '100';

//             _cycle = '50'; //50,30sec reference
//             _isoTemperature = '50'; //50
//             _current = '12'; //12
//             _gainDefault = '2'; //2
//             _gainSelect = '2'; //2
//             _preTestCycle = '30'; //30,SP
//             _preTestTime = '10'; //10,SP
//             _afterTestCycle = '50'; //40,SC
//             _afterTestTime = '30'; //30,SC
//             _rtTemperature = '50'; //50
//             _rtTime = '0'; //300
//             break;
//           case '08800151201026':
//             _testTypeCtrl.text = 'RSV';
//             _refNoCtrl.text = 'CL1106P';
//             _ctValue = '100';

//             _cycle = '50'; //50,30sec reference
//             _isoTemperature = '50'; //50
//             _current = '12'; //12
//             _gainDefault = '2'; //2
//             _gainSelect = '2'; //2
//             _preTestCycle = '30'; //30,SP
//             _preTestTime = '10'; //10,SP
//             _afterTestCycle = '50'; //40,SC
//             _afterTestTime = '30'; //30,SC
//             _rtTemperature = '50'; //50
//             _rtTime = '0'; //300
//             break;
//           default:
//             _testTypeCtrl.text = 'Unknown';
//             _refNoCtrl.text = 'CL0000';
//             _ctValue = '100';

//             _cycle = '50'; //50,30sec reference
//             _isoTemperature = '50'; //50
//             _current = '12'; //12
//             _gainDefault = '2'; //2
//             _gainSelect = '2'; //2
//             _preTestCycle = '30'; //30,SP
//             _preTestTime = '10'; //10,SP
//             _afterTestCycle = '50'; //40,SC
//             _afterTestTime = '30'; //30,SC
//             _rtTemperature = '50'; //50
//             _rtTime = '0'; //300
//             break;
//         }
//         // String? expDate = scanCode.substring(18, 24);
//         // String? lotNum = scanCode.substring(26);
//         String divCheck = scanCode.substring(16, 18);
//         String? lotNum, expDate;
//         if (divCheck == '10') {
//           lotNum = scanCode.substring(18, 27);
//           expDate = scanCode.substring(29);
//         } else {
//           expDate = scanCode.substring(18, 24);
//           lotNum = scanCode.substring(26);
//         }

//         if (expDate != null && lotNum != null) {
//           String expString =
//               '20${expDate.substring(0, 2)}-${expDate.substring(2, 4)}-${expDate.substring(4)}';
//           // String expString =
//           //     '20${expDate.substring(0, 2)}-01-${expDate.substring(4)}';
//           if (DateTime.parse(expString).millisecondsSinceEpoch >
//               DateTime.now().millisecondsSinceEpoch) {
//             // 현재 시간보다 미래인지 확인
//             _expDateCtrl.text = DateFormat('dd.MMM.yyy')
//                 .format(DateTime.parse(expString))
//                 .toUpperCase();
//             _lotNumberCtrl.text = lotNum;

//             _pageController.animateToPage(1,
//                 duration: const Duration(milliseconds: 1),
//                 curve: Curves.easeInOut);
//             // _tabController.animateTo(1);
//           } else {
//             showExpiredError(
//                 'The Cartridge is invalid as it’s expired. You should use a valid CLEO ONE TEST Cartridge.');
//             return;
//           }
//         }
//       });
//     });
//   }

//   void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
//     debugPrint('${DateTime.now().toIso8601String()}_onPermissionSet $p');
//     if (!p) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('no Permission')),
//       );
//     }
//   }

//   Widget buildManualForm() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//       child: LayoutBuilder(
//         builder: (context, constraints) => SingleChildScrollView(
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//                 minHeight: constraints.maxHeight,
//                 maxHeight: constraints.maxHeight),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (Platform.isAndroid)
//                   Text(
//                     pageTitle,
//                     style: const TextStyle(
//                       color: cons.primary,
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 Expanded(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       TextField(
//                         controller: _testTypeCtrl,
//                         readOnly: true,
//                         decoration: const InputDecoration(
//                           focusedBorder: OutlineInputBorder(
//                             borderSide: BorderSide(
//                               width: 1.0,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderSide: BorderSide(
//                               width: 1.0,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           hintText: 'Search id or name',
//                           label: Text('TEST TYPE'),
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       TextField(
//                         readOnly: true,
//                         controller: _lotNumberCtrl,
//                         decoration: const InputDecoration(
//                           focusedBorder: OutlineInputBorder(
//                             borderSide: BorderSide(
//                               width: 1.0,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderSide: BorderSide(
//                               width: 1.0,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           // hintText: 'Search id or name',
//                           label: Text('LOT NUMBER'),
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       TextField(
//                         controller: _expDateCtrl,
//                         decoration: const InputDecoration(
//                           focusedBorder: OutlineInputBorder(
//                             borderSide: BorderSide(
//                               width: 1.0,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderSide: BorderSide(
//                               width: 1.0,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           // hintText: 'Search id or name',
//                           label: Text('EXP DATE'),
//                         ),
//                         readOnly: true,
//                         onTap: () async {
//                           // DateTime? selectedDate = await showDatePicker(
//                           //   context: context,
//                           //   initialDate: DateTime.now(),
//                           //   firstDate: DateTime(DateTime.now().year),
//                           //   lastDate: DateTime(DateTime.now().year + 3),
//                           // );

//                           // if (selectedDate != null) {
//                           //   String formatDate = DateFormat('dd.MMM.yyyy')
//                           //       .format(selectedDate)
//                           //       .toUpperCase();
//                           //   _expDateCtrl.text = formatDate;
//                           // }
//                         },
//                       ),
//                       Center(
//                         child: Container(
//                           margin: const EdgeInsets.only(top: 24),
//                           padding: const EdgeInsets.symmetric(horizontal: 8),
//                           child: const Text(
//                             'Confirm Lot Number and Expiration Date shown match infomation on cartridge pouch.',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(fontSize: 17),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//                 Center(
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(vertical: 24),
//                     child: ConfirmButton(
//                       onPressed: () {
//                         goToCartridgeProcessScreen(context);
//                       },
//                       label: 'CONFIRM',
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   showExpiredError(String msg) {
//     if (newTestBusy) return;

//     setState(() {
//       newTestBusy = true;
//     });

//     Future.delayed(const Duration(milliseconds: 1000)).then((value) {
//       setState(() {
//         newTestBusy = false;
//       });
//     });
//     showDialog(
//       routeSettings: const RouteSettings(name: 'dialog'),
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return WillPopScope(
//           onWillPop: () async => false,
//           child: Dialog(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(
//                     CupertinoIcons.exclamationmark_triangle,
//                     color: Color.fromRGBO(240, 151, 0, 1),
//                     size: 130,
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'ERROR',
//                     style: TextStyle(
//                       color: Color(0xffC20018),
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     msg,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       color: Color(0xffCC6116),
//                       fontSize: 16,
//                     ),
//                   ),
//                   Container(
//                     margin: const EdgeInsets.symmetric(vertical: 16),
//                     child: FlatConfirmButton(
//                       onPressed: () async {
//                         Navigator.of(context).pop();
//                       },
//                       label: 'Rescan',
//                     ),
//                   ),
//                   Container(
//                     margin: const EdgeInsets.symmetric(vertical: 16),
//                     child: FlatConfirmButton(
//                       onPressed: () async {
//                         goBack(context);
//                         Navigator.of(context)
//                             .popUntil((route) => route.isFirst);
//                       },
//                       label: 'Go to Home',
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void goToCartridgeProcessScreen(BuildContext context) {
//     final device = Provider.of<CleoDevice>(context, listen: false);

//     assert(device.state is QrScanState,
//         'current state is not QrScanState :: ${device.state.name}');

//     final testType = _testTypeCtrl.text;
//     final lotNum = _lotNumberCtrl.text;
//     final expDate = _expDateCtrl.text;
//     final refNo = _refNoCtrl.text;
//     final ctValue = _ctValue;

//     final cycle = _cycle;
//     final isoTemperature = _isoTemperature;
//     final current = _current;
//     final gainDefault = _gainDefault;
//     final gainSelect = _gainSelect;
//     final preTestCycle = _preTestCycle;
//     final preTestTime = _preTestTime;
//     final afterTestCycle = _afterTestCycle;
//     final afterTestTime = _afterTestTime;
//     final rtTemperature = _rtTemperature;
//     final rtTime = _rtTime;

//     final cartridge = CartridgeInfo(
//         testType,
//         lotNum,
//         expDate,
//         refNo,
//         ctValue,
//         cycle,
//         isoTemperature,
//         current,
//         gainDefault,
//         gainSelect,
//         preTestCycle,
//         preTestTime,
//         afterTestCycle,
//         afterTestTime,
//         rtTemperature,
//         rtTime);

//     device.setCartridge(cartridge);
//     DeviceMem.setDeviceCartridgeInfo(device.device.id.toString(), cartridge);
//     final state = (device.state as QrScanState);
//     state.sendSetting();

//     showCartridgeInsertionPopup(context);
//   }

//   void goBack(context) {
//     final device =
//         Provider.of<BluetoothProvider>(context, listen: false).currentDevice!;
//     assert(device.state is QrScanState,
//         'current state is not QrScanState :: ${device.state.name}');
//     (device.state as QrScanState).sendCancel();
//   }

//   void goBackActionCartridge(BuildContext context) {
//     final device = Provider.of<CleoDevice>(context, listen: false);
//     assert(device.state is CartridgeInsertState);
//     (device.state as CartridgeInsertState).goBack();
//   }

//   void goBackActionClose() {
//     final device = Provider.of<CleoDevice>(context, listen: false);
//     assert(device.state is CloseCoverState);
//     (device.state as CloseCoverState).goBack();
//   }

//   void showCartridgeInsertionPopup(BuildContext context) {
//     final device =
//     Provider.of<BluetoothProvider>(context, listen: false).currentDevice!;
//     final state = device.state;
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Insert the Cartridge'),
//           content: Text('Please insert the cartridge into the device.'),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () {
//                 goBackActionCartridge(context);
//                 Navigator.of(context).pop();
//                 // showLidClosePopup(context);
//               },
//             ),
//           ],
//         );
//       },
//     ).then((_) {
//       if(device.state is CartridgeInsertState){
//         showLidClosePopup(context);
//       }
//     // 카트리지 삽입 상태를 감지하는 로직
//       // showLidClosePopup(context);

//     });
//   }

//   void showLidClosePopup(BuildContext context) {
//     final device =
//     Provider.of<BluetoothProvider>(context, listen: false).currentDevice!;
//     final state = device.state;
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Close the Lid'),
//           content: Text('Please close the lid of the device.'),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () {
//                 // 팝업 닫기
//                 goBackActionClose();
//                 // Navigator.of(context).pop();

//                 // proceedToNextStep(context);
//               },
//             ),
//           ],
//         );
//       },
//     ).then((_) {
//       if(device.state is CloseCoverState){
//         showLidClosePopup(context);
//         Navigator.of(context).pop();
//       }
//     // 카트리지 삽입 상태를 감지하는 로직
//       // showLidClosePopup(context);

//     });
//   }

//   void proceedToNextStep(BuildContext context) {
//     // 다음 단계로 넘어가는 코드를 여기에 작성합니다.
//     // 예를 들어, 다른 화면으로 네비게이션하거나 상태 업데이트 등
//   }
// }
