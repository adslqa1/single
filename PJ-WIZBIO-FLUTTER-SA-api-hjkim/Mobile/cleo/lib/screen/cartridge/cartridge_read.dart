// import 'dart:io';

// import 'package:assets_audio_player/assets_audio_player.dart';
// import 'package:cleo/cleo_device/cartridge_info.dart';
// import 'package:cleo/cleo_device/cleo_state.dart';
// import 'package:cleo/provider/bluetooth.provider.dart';
// import 'package:cleo/screen/common/confirm_button.dart';

// import 'package:flutter/material.dart';
// import 'package:cleo/constants.dart' as cons;
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';

// import 'cartridge_process.dart';

// class CartridgeReadScreen extends StatefulWidget {
//   static const routeName = '/cartridgeRead';

//   const CartridgeReadScreen({Key? key}) : super(key: key);

//   @override
//   State<CartridgeReadScreen> createState() => _CartridgeReadScreenState();
// }

// class _CartridgeReadScreenState extends State<CartridgeReadScreen>
//     with TickerProviderStateMixin {
//   // late TabController _tabController;
//   late PageController _pageController;

//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   Barcode? result;
//   QRViewController? _qrViewController;

//   late TextEditingController _testTypeCtrl;
//   late TextEditingController _lotNumberCtrl;
//   late TextEditingController _expDateCtrl;

//   String pageTitle = 'Prepare Test';

//   @override
//   void initState() {
//     super.initState();
//     // _tabController = TabController(length: 2, vsync: this);

//     _pageController = PageController(initialPage: 0);
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
//     _testTypeCtrl = TextEditingController(text: 'COVID-19');
//     _lotNumberCtrl = TextEditingController();
//     _expDateCtrl = TextEditingController();

//     AssetsAudioPlayer.newPlayer().open(
//       Audio("assets/video/qr.mp3"),
//       autoStart: true,
//     );
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
//   void dispose() {
//     // _tabController.dispose();
//     _pageController.dispose();
//     _testTypeCtrl.dispose();
//     _lotNumberCtrl.dispose();
//     _expDateCtrl.dispose();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;
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
//                     borderColor: cons.primary,
//                     borderRadius: 10,
//                     borderLength: 30,
//                     borderWidth: 10,
//                     cutOutSize: scanArea),
//                 onPermissionSet: (ctrl, p) =>
//                     _onPermissionSet(context, ctrl, p),
//               ),
//             ),
//           ],
//         ),
//         Positioned(
//           top: 0,
//           child: Container(
//             width: size.width,
//             padding: const EdgeInsets.all(24.0),
//             child: const Text(
//               'Align the QR code on the CLEO COVID-19 Test cartridge pouch within the  frame to scan.',
//               style: TextStyle(
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   void _onQRViewCreated(QRViewController controller) {
//     _qrViewController = controller;
//     controller.scannedDataStream.listen((Barcode? scanData) {
//       setState(() {
//         if (scanData == null) return;

//         if (scanData.format != BarcodeFormat.dataMatrix) return;

//         if (scanData.code == null) return;

//         String scanCode =
//             scanData.code!.replaceAll(RegExp('[^0-9a-zA-Z-]'), '');

//         String? uniqueKey = scanCode.substring(0, 17);

//         if (uniqueKey == null) return;

//         // if (uniqueKey != '0108800151200005') return;

//         String? expDate = scanCode.substring(18, 24);
//         String? lotNum = scanCode.substring(26);

//         if (expDate != null && lotNum != null) {
//           String expString =
//               '20${expDate.substring(1, 3)}-${expDate.substring(2, 4)}-${expDate.substring(4)}';

//           _expDateCtrl.text = DateFormat('dd.MMM.yyyy')
//               .format(DateTime.parse(expString))
//               .toUpperCase();
//           _lotNumberCtrl.text = lotNum;

//           _pageController.animateToPage(1,
//               duration: const Duration(milliseconds: 1),
//               curve: Curves.easeInOut);
//           // _tabController.animateTo(1);
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
//                           label: Text('LOT. NUMBER'),
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
//                           label: Text('EXP. DATE'),
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
//                           padding: const EdgeInsets.symmetric(horizontal: 48),
//                           child: const Text(
//                             'Confirm lot. number and expiration date shown match infomation on cartridge pouch',
//                             style: TextStyle(fontSize: 18),
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

//   void goToCartridgeProcessScreen(BuildContext context) {
//     final device =
//         Provider.of<BluetoothProvider>(context, listen: false).currentDevice!;

//     final testType = _testTypeCtrl.text;
//     final lotNum = _lotNumberCtrl.text;
//     final expDate = _expDateCtrl.text;

//     final cartridge = CartridgeInfo(testType, lotNum, expDate);

//     device.setCartridge(cartridge);

//     assert(device.state is QrScanState,
//         'current state is not QrScanState :: ${device.state.name}');

//     (device.state as QrScanState).sendSetting();
//     late void Function() waiter;
//     waiter = () async {
//       if (!mounted) {
//         device.removeListener(waiter);
//         return;
//       }
//       if (device.state is CartridgeState) {
//         device.removeListener(waiter);
//         // print('to cartridge');
//         Navigator.of(context)
//             .pushReplacementNamed(CartridgeProcessScreen.routeName);
//         return;
//       }
//     };
//     device.addListener(waiter);
//   }

//   void goBack(context) {
//     final device =
//         Provider.of<BluetoothProvider>(context, listen: false).currentDevice!;
//     assert(device.state is QrScanState,
//         'current state is not QrScanState :: ${device.state.name}');
//     (device.state as QrScanState).sendCancel();
//     device.updateState(IdleState(device, ''));
//     Navigator.of(context).pop();
//     // late void Function() waiter;
//     // waiter = () async {
//     //   if (!mounted) {
//     //     device.removeListener(waiter);
//     //     return;
//     //   }
//     //   if (device.state is IdleState) {
//     //     device.removeListener(waiter);
//     //     print('go back');
//     //     Navigator.of(context).pop();
//     //     return;
//     //   }
//     // };
//     // device.addListener(waiter);
//   }
// }
