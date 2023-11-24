// *** 
//  check Mobile/cleo/lib/screen/cartridge/cartridge_final.dart for this screen
// ***

// import 'package:cleo/cleo_device/cleo_device.dart';
// import 'package:cleo/cleo_device/cleo_state.dart';
// import 'package:cleo/cleo_device/view/per_state/cartridge_process_base.dart';
// import 'package:cleo/screen/cartridge/cartridge_final.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:video_player/video_player.dart';

// class TestCompleteView extends StatefulWidget {
//   final int reportId;
//   const TestCompleteView({Key? key, required this.reportId}) : super(key: key);

//   @override
//   State<TestCompleteView> createState() => _TestCompleteViewState();
// }

// class _TestCompleteViewState extends State<TestCompleteView> {
//   static const desc =
//       'Place the Test Cartridge, sample tube and swab into the disposable bag. Dispose of the bag as general waste.';
//   static const videoPath = 'assets/video/step_7.mp4';

//   final _videoController = VideoPlayerController.asset(videoPath);
//   late Future<void>? _initializeVideoPlayerFuture;

//   bool videoEnd = false;
//   bool videoBusy = true;

//   @override
//   void initState() {
//     super.initState();
//     _initializeVideoPlayerFuture = _videoController.initialize().then((value) {
//       setState(() {
//         videoBusy = false;
//       });
//       _videoController.play();
//       _videoController.addListener(positionListener);
//     });
//   }

//   @override
//   void dispose() {
//     _videoController.removeListener(positionListener);
//     _videoController.dispose();
//     super.dispose();
//   }

//   void positionListener() {
//     if (!mounted) {
//       return;
//     }
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

//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;
//     final state = Provider.of<CleoDevice>(context).state as CloseCoverState;

//     return WillPopScope(
//       onWillPop: () async {
//         // goBackAction();
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
//             const VideoDescriptionArea(
//               description: desc,
//               hideBack: true,
//             ),
//             Positioned(
//               bottom: 50,
//               child: SizedBox(
//                 width: size.width,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       ElevatedButton(
//                         onPressed: () {
//                           goReportResult();
//                         },
//                         style: ButtonStyle(
//                             shape: MaterialStateProperty.all<
//                                 RoundedRectangleBorder>(
//                               RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(24.0),
//                               ),
//                             ),
//                             backgroundColor:
//                                 MaterialStateProperty.all(Colors.purple[800])),
//                         child: Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           child: const Align(
//                             child: Text(
//                               'VIEW TEST RESULT',
//                               style: TextStyle(fontSize: 18),
//                             ),
//                             alignment: Alignment.center,
//                           ),
//                         ),
//                       ),
//                       ElevatedButton(
//                         onPressed: () {
//                           goHome();
//                         },
//                         style: ButtonStyle(
//                           shape:
//                               MaterialStateProperty.all<RoundedRectangleBorder>(
//                             RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(24.0),
//                             ),
//                           ),
//                         ),
//                         child: Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           child: const Align(
//                             child: Text(
//                               'Home',
//                               style: TextStyle(fontSize: 18),
//                             ),
//                             alignment: Alignment.center,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void goHome() {
//     Navigator.of(context).popUntil((route) => route.isFirst);
//   }

//   void goReportResult() {
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(
//         builder: (context) => CartridgeFinalScreen(
//           reportId: widget.reportId,
//         ),
//       ),
//     );
//   }
// }
