// // ignore_for_file: use_full_hex_values_for_flutter_colors

// import 'dart:convert';
// import 'dart:io';

// import 'package:cleo/cleo_device/cleo_device.dart';
// import 'package:cleo/cleo_device/cleo_state.dart';
// import 'package:cleo/constants.dart' as cons;
// import 'package:cleo/model/test_report.dart';
// import 'package:cleo/provider/auth.dart';
// import 'package:cleo/provider/bluetooth.provider.dart';
// import 'package:cleo/screen/home/tester_manage.dart';
// import 'package:cleo/util/notification.dart';
// import 'package:cleo/util/sql_helper.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:video_player/video_player.dart';

// import 'result_progress.dart';

// class CartridgeProcessScreenArgs {
//   final int initStep;

//   CartridgeProcessScreenArgs(this.initStep);
// }

// class CartridgeProcessScreen extends StatefulWidget {
//   static const routeName = '/cartridgeProcess';
//   final int initStep;
//   const CartridgeProcessScreen({Key? key, this.initStep = 0}) : super(key: key);

//   @override
//   State<CartridgeProcessScreen> createState() => _CartridgeProcessScreenState();
// }

// class _CartridgeProcessScreenState extends State<CartridgeProcessScreen> {
//   List<Map> stepInfo = [
//     {
//       'msg':
//           'Press the round button on your CLEO ONE to open. Open the wrapped Test Cartridge and insert Test Cartridge into the cartridge slot of CLEO ONE.',
//       'path': 'assets/video/step_0.mp4'
//     }, // 0. 카트리지 삽입확인
//     {
//       'msg':
//           'Unpack the sample test tube. Peel off the tube sealer and set the sample tube into the tube stand in the kit box.',
//       'path': 'assets/video/step_1.mp4'
//     }, // 1. 튜브 개봉
//     {
//       'msg':
//           'Open the nasal swab packaging at stick end and take out the swab.',
//       'path': 'assets/video/step_2.mp4'
//     }, // 2. 면봉 개봉
//     {
//       'msg':
//           'Insert the swab tip into one nostril about 3/4 inches (for an adult) or 1/2 inches (for a child). Keep gentle pressure on the outer wall of the nostril and rotate the swab against the wall 5 times.',
//       'path': 'assets/video/step_3.mp4'
//     }, // 3. 시료 채취
//     {
//       'msg':
//           'Place the swab tip down in the tube. Find the break-point on the swab stick and snap it carefully back and forth against the internal side of the tube.',
//       'path': 'assets/video/step_4.mp4'
//     }, // 4. 시료 봉합
//     {
//       'msg':
//           'Close the tube firmly with its cap and shake it at least 10 times.',
//       'path': 'assets/video/step_5.mp4'
//     }, // 5. 시료 믹스
//     {
//       'msg':
//           'Insert the sample tube into the hole of the Test Cartridge until the “click” sound occurs. Step 7-1 Close the cover of the CLEO ONE until the “click” sound occurs.',
//       'path': 'assets/video/step_6.mp4'
//     }, // 6. 튜브 결합
//   ];

//   bool waiting = false;
//   bool showControl = true;
//   bool init = false;
//   bool videoEnd = false;
//   bool cartridgeReady = false;
//   int currentStep = 0;
//   bool get ableSkip =>
//       (1 <= currentStep && currentStep <= 5) ||
//       (currentStep == 0 && cartridgeReady);
//   // bool get ableNext =>
//   //     videoEnd && ((currentStep == 0 && cartridgeReady) || (currentStep != 0));
//   bool get ableNext =>
//       ((currentStep == 0 && cartridgeReady) || (currentStep != 0));

//   bool changeVideoBusy = false;

//   // ignore: prefer_typing_uninitialized_variables
//   var deviceStateListner;

//   late VideoPlayerController _videoController;
//   late Future<void>? _initializeVideoPlayerFuture;

//   @override
//   void initState() {
//     super.initState();
//     currentStep = widget.initStep;
//     _videoController =
//         VideoPlayerController.asset(stepInfo[currentStep]['path']);
//     _initializeVideoPlayerFuture = _videoController.initialize().then((value) {
//       _videoController.play();

//       _videoController.addListener(positionListener);
//     });
//   }

//   @override
//   void dispose() {
//     _initializeVideoPlayerFuture = null;
//     _videoController.pause().then((_) {
//       _videoController.dispose();
//     });
//     super.dispose();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     initDeviceStateListener();
//   }

//   @override
//   Widget build(BuildContext context) {
//     initDeviceStateListener();
//     final Size size = MediaQuery.of(context).size;
//     return WillPopScope(
//       onWillPop: () async {
//         goBackAction();
//         return false;
//       },
//       child: Scaffold(
//         body: Stack(
//           children: [
//             FutureBuilder(
//               future: _initializeVideoPlayerFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done) {
//                   return SizedBox(
//                     width: size.width,
//                     height: size.height,
//                     child: VideoPlayer(_videoController),
//                   );
//                 } else {
//                   return const Center(child: CupertinoActivityIndicator());
//                 }
//               },
//             ),
//             SafeArea(
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.black.withOpacity(0.6),
//                       Colors.black.withOpacity(0.5),
//                       Colors.black.withOpacity(0),
//                     ],
//                     stops: const [0, 0.5, 1],
//                   ),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(top: 16, left: 16),
//                       child: Align(
//                         alignment: Alignment.topLeft,
//                         child: IconButton(
//                           onPressed: () async {
//                             if (changeVideoBusy) {
//                               return;
//                             }
//                             goBackAction();
//                           },
//                           icon: const Icon(Icons.arrow_back_ios,
//                               color: Colors.white),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(32, 8, 32, 48),
//                       child: Text(
//                         stepInfo[currentStep]['msg'],
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: currentStep == 6 ? 100 : 50,
//               child: Container(
//                 width: size.width,
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: currentStep == 6
//                     ? RichText(
//                         textAlign: TextAlign.center,
//                         text: const TextSpan(
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                           ),
//                           children: [
//                             TextSpan(text: 'If the lid close\n'),
//                             TextSpan(text: 'then the Test start automatically'),
//                           ],
//                         ),
//                       )
//                     // ? const Text(
//                     //     'If the lid closed, then the Test start automatically',
//                     //     style: TextStyle(
//                     //       color: Colors.black,
//                     //       fontSize: 20,
//                     //     ),
//                     //   )
//                     : Row(
//                         children: [
//                           Expanded(
//                             child: InkWell(
//                               onTap: () {
//                                 if (videoEnd) {
//                                   setState(() {
//                                     videoEnd = false;
//                                   });
//                                   _videoController.play();
//                                 }
//                               },
//                               child: Container(
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 16),
//                                 decoration: BoxDecoration(
//                                   color: videoEnd
//                                       ? const Color(0xff6D53D7)
//                                       : Colors.grey,
//                                   borderRadius: BorderRadius.circular(40),
//                                 ),
//                                 child: const Center(
//                                   child: Text(
//                                     'REPLAY',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 20,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 24),
//                           Expanded(
//                             child: !showControl || changeVideoBusy
//                                 ? const SizedBox()
//                                 : InkWell(
//                                     onTap: () {
//                                       ableNext ? nextStep(context) : null;
//                                     },
//                                     child: Container(
//                                       padding: const EdgeInsets.symmetric(
//                                           vertical: 16),
//                                       decoration: BoxDecoration(
//                                         color: ableNext
//                                             ? cons.primary
//                                             : Colors.grey,
//                                         borderRadius: BorderRadius.circular(40),
//                                       ),
//                                       child: const Center(
//                                         child: Text(
//                                           'NEXT',
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 20,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                           ),

//                           // Expanded(
//                           //   child: !ableSkip || changeVideoBusy
//                           //       ? const SizedBox()
//                           //       : InkWell(
//                           //           onTap: () {
//                           //             nextStep(context);
//                           //           },
//                           //           child: Container(
//                           //             padding: const EdgeInsets.symmetric(
//                           //                 vertical: 16),
//                           //             decoration: BoxDecoration(
//                           //               color: cons.primary,
//                           //               borderRadius: BorderRadius.circular(40),
//                           //             ),
//                           //             child: const Center(
//                           //               child: Text(
//                           //                 'SKIP',
//                           //                 style: TextStyle(
//                           //                   color: Colors.white,
//                           //                   fontSize: 20,
//                           //                 ),
//                           //               ),
//                           //             ),
//                           //           ),
//                           //         ),
//                           // ),
//                         ],
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   initDeviceStateListener() {
//     if (deviceStateListner != null) {
//       return;
//     }
//     final provider = Provider.of<BluetoothProvider>(context, listen: false);

//     debugPrint('initDeviceStateListener...');
//     final device = provider.currentDevice!;

//     deviceStateListner = () async {
//       debugPrint('CartridgetProcess :: listener working....');
//       if (!mounted) {
//         debugPrint('CartridgetProcess :: deviceStateListner removed ');
//         device.removeListener(deviceStateListner);
//         return;
//       } else if (device.state is UserTubeCheckState) {
//         debugPrint('cartridge ready');
//         setState(() {
//           cartridgeReady = true;
//         });
//         return;
//       } else if (device.state is CloseCoverState) {
//         debugPrint('close cover state');
//         return;
//       } else if (device.state is ErrorState) {
//         debugPrint('CartridgetProcess :: deviceStateListner removed ');
//         device.removeListener(deviceStateListner);
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           routeSettings: const RouteSettings(name: 'dialog'),
//           builder: (context) => AlertDialog(
//             content: Text((device.state as ErrorState).errorMsg),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   device.updateState(IdleState(device, ''));
//                   Navigator.of(context).popUntil((route) => route.isFirst);
//                 },
//                 child: const Text('CONFIRM'),
//               )
//             ],
//           ),
//         );
//         return;
//       } else if (device.state is TestProgressState) {
//         debugPrint('CartridgetProcess :: deviceStateListner removed ');
//         device.removeListener(deviceStateListner);
//         await goProgress(context, device);
//         return;
//       } else if (device.state is CartridgeState) {
//         // ??
//       } else {
//         device.removeListener(deviceStateListner);
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           routeSettings: const RouteSettings(name: 'dialog'),
//           builder: (context) => AlertDialog(
//             content: const Text('Unexpected Error'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   device.updateState(IdleState(device, ''));
//                   Navigator.of(context).popUntil((route) => route.isFirst);
//                 },
//                 child: const Text('HOME'),
//               )
//             ],
//           ),
//         );
//         return;
//       }
//     };
//     device.addListener(deviceStateListner);
//   }

//   void nextStep(BuildContext context) async {
//     if (waiting) {
//       return;
//     }

//     switch (currentStep) {
//       case 0:
//       case 1:
//       case 2:
//       case 3:
//       case 4:
//       case 5:
//         goToStep(currentStep + 1);
//         break;
//     }
//     setState(() {});
//   }

//   goToStep(int newStep) {
//     assert(0 <= newStep && newStep <= 6, 'invalid newStep');
//     if (changeVideoBusy) {
//       return;
//     }

//     setState(() {
//       currentStep = newStep;
//     });
//     switch (newStep) {
//       case 0:
//       case 1:
//       case 2:
//       case 3:
//       case 4:
//       case 5:
//         setState(() {
//           showControl = true;
//         });
//         changeVideo(stepInfo[newStep]['path']);
//         break;
//       case 6:
//         setState(() {
//           showControl = false;
//         });
//         sendReadySignal();
//         changeVideo(stepInfo[newStep]['path']);

//         break;
//     }
//   }

//   sendReadySignal() {
//     final provider = Provider.of<BluetoothProvider>(context, listen: false);
//     final state = provider.currentDevice!.state;

//     assert(state is UserTubeCheckState);
//     (state as UserTubeCheckState).requestNext();
//   }

//   void skipStep(BuildContext context) {
//     goToStep(currentStep + 1);
//   }

//   Future<void> goProgress(BuildContext context, CleoDevice device) async {
//     final auth = Provider.of<AuthProvider>(context, listen: false);
//     final userName = auth.displayName;
//     final crntTester = auth.currentTester!;
//     final crntCartridge = device.crntCartridge!;
//     final deviceInfo = DeviceInfoPlugin();
//     String? deviceName;
//     if (Platform.isIOS) {
//       deviceName = (await deviceInfo.iosInfo).utsname.machine.toString();
//     } else if (Platform.isAndroid) {
//       deviceName = (await deviceInfo.androidInfo).model.toString();
//     }

//     final initReport = TestReport(
//       userId: crntTester.id,
//       name: crntTester.name,
//       testType: crntCartridge.testType,
//       birthday: crntTester.birthday,
//       gender: crntTester.gender,
//       macAddress: device.device.id.toString(),
//       expire: crntCartridge.expDate,
//       lotNum: crntCartridge.lotNum,
//       reportStatus: ReportStatus.running,
//     );

//     initReport.deviceName = deviceName;
//     initReport.startAt = DateTime.now().toIso8601String();
//     final reportId = await SqlReport.insertReport(initReport);
//     initReport.id = reportId;
//     // device.crntReport = initReport;

//     final testInfo = initReport.toJson();

//     LocalNotification.sendScheduleMsg(
//       title: 'Test Complete',
//       body: '${crntTester.name}`s Test Complete',
//       id: crntTester.id,
//       payload: jsonEncode(testInfo),
//       duration: const Duration(minutes: 30),
//     );

//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(
//         builder: (context) => ResultProgressScreen(reportId: reportId),
//       ),
//       (route) => route.isFirst,
//     );
//   }

//   Future<int> selectTester(BuildContext context) async {
//     // await Navigator.of(context).push(MaterialPageRoute(
//     //   builder: (context) => const TesterMangeScreen(),
//     //   fullscreenDialog: true,
//     //   settings: const RouteSettings(name: TesterMangeScreen.routeName),
//     // ));

//     final crntTester =
//         Provider.of<AuthProvider>(context, listen: false).currentTester;
//     if (crntTester == null) {
//       await Navigator.of(context).push(MaterialPageRoute(
//         builder: (context) => const TesterMangeScreen(),
//         fullscreenDialog: true,
//         settings: const RouteSettings(name: TesterMangeScreen.routeName),
//       ));
//     }
//     if (crntTester?.id == null) {
//       throw 'Tester not selected';
//     }
//     return crntTester!.id;
//   }

//   goToMain() {
//     debugPrint('goToMain');
//     final device =
//         Provider.of<BluetoothProvider>(context, listen: false).currentDevice!;
//     device.sendMsg('P');
//     device.updateState(IdleState(device, 'P'));
//     Navigator.popUntil(context, (route) => route.isFirst);
//   }

//   int goBackAction() {
//     if (currentStep == 0) {
//       goToMain();
//       return -1;
//     }
//     final targetStep = currentStep - 1;
//     if (currentStep == 1) {
//       deviceGoBack();
//     }
//     if (currentStep == 6) {
//       deviceGoBack();
//     }
//     goToStep(targetStep);
//     return targetStep;
//   }

//   deviceGoBack() {
//     final device =
//         Provider.of<BluetoothProvider>(context, listen: false).currentDevice!;

//     final state = device.state;
//     if (state is CloseCoverState) {
//       state.goBack();
//       return;
//     }
//     if (state is UserTubeCheckState) {
//       state.goBack();
//       return;
//     }
//     if (state is CartridgeState) {
//       // state.goBack();
//       state.sendCancel();
//       return;
//     }
//     debugPrint('unexpected go back called @ ${state.toString()}');
//   }

//   changeVideo(String videoPath) async {
//     if (changeVideoBusy) {
//       return;
//     }
//     setState(() {
//       changeVideoBusy = true;
//     });

//     await _videoController.pause();
//     _videoController.removeListener(positionListener);

//     setState(() {
//       _initializeVideoPlayerFuture = null;
//     });

//     Future.delayed(const Duration(milliseconds: 1000)).then((value) {
//       _videoController = VideoPlayerController.asset(videoPath);

//       _initializeVideoPlayerFuture = _videoController.initialize().then((_) {
//         _videoController.play();
//         _videoController.addListener(positionListener);

//         setState(() {
//           videoEnd = false;
//           changeVideoBusy = false;
//         });
//       });
//     });
//   }

//   positionListener() {
//     _videoController.position.then((Duration? value) {
//       if (value != null &&
//           _videoController.value.duration.inMilliseconds > 0 &&
//           value.inMilliseconds >=
//               _videoController.value.duration.inMilliseconds) {
//         setState(() {
//           videoEnd = true;
//         });
//       }
//     });
//   }

//   // noCartridge = true 카트리지 없을때 경고  noCartridge = false 블루투스 연결 유실
//   Future showWarningDialog(
//     BuildContext context, {
//     bool noCartridge = true,
//   }) async {
//     return await showDialog(
//       context: context,
//       builder: (context) {
//         return Dialog(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(
//                   CupertinoIcons.exclamationmark_triangle,
//                   color: Color.fromRGBO(240, 151, 0, 1),
//                   size: 130,
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'WARNING',
//                   style: TextStyle(
//                     color: Color(0xffC20018),
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   noCartridge
//                       ? 'KEEP YOUR TEST CARTRIDGE INSERTED.'
//                       : 'Bluetooth connection lost !',
//                   style: const TextStyle(
//                     color: Color(0xffCC6116),
//                     fontSize: 16,
//                   ),
//                 ),
//                 noCartridge
//                     ? Container(
//                         margin: const EdgeInsets.symmetric(vertical: 24),
//                         child: ElevatedButton(
//                           style: ButtonStyle(
//                             shape: MaterialStateProperty.all(
//                               RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(24.0),
//                               ),
//                             ),
//                           ),
//                           onPressed: () {},
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             width: double.infinity,
//                             child: const Center(
//                               child: Text(
//                                 'BACK TO TEST',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       )
//                     : const SizedBox(),
//                 !noCartridge
//                     ? Container(
//                         margin: const EdgeInsets.symmetric(vertical: 16),
//                         child: ElevatedButton(
//                           style: ButtonStyle(
//                             shape: MaterialStateProperty.all(
//                               RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(24.0),
//                               ),
//                             ),
//                             backgroundColor:
//                                 MaterialStateProperty.all(Color(0xffDA930F)),
//                           ),
//                           onPressed: () {},
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             width: double.infinity,
//                             child: const Center(
//                               child: Text(
//                                 'CANCEL TEST',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       )
//                     : const SizedBox(),
//                 !noCartridge
//                     ? Container(
//                         margin: const EdgeInsets.only(bottom: 16),
//                         child: ElevatedButton(
//                           style: ButtonStyle(
//                             shape: MaterialStateProperty.all(
//                               RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(24.0),
//                               ),
//                             ),
//                           ),
//                           onPressed: () {},
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             width: double.infinity,
//                             child: const Center(
//                               child: Text(
//                                 'BACK TO RECONNECTION',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       )
//                     : const SizedBox(),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
