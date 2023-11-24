// import 'package:cleo/cleo_device/cleo_device.dart';
// import 'package:cleo/cleo_device/cleo_state.dart';
// import 'package:cleo/cleo_device/view/per_state/cartridge_process_base.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:video_player/video_player.dart';

// class CartridgeTubeInsertView extends StatefulWidget {
//   const CartridgeTubeInsertView({Key? key}) : super(key: key);

//   @override
//   State<CartridgeTubeInsertView> createState() =>
//       _CartridgeTubeInsertViewState();
// }

// class _CartridgeTubeInsertViewState extends State<CartridgeTubeInsertView> {
//   static const desc =
//       'Close the tube firmly with its cap and shake it at least 10 times.';
//   static const videoPath = 'assets/video/step_6.mp4';

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
//     final state =
//         Provider.of<CleoDevice>(context).state as CartridgeSampleMixState;

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
//             VideoDescriptionArea(
//               description: desc,
//               onPressBack: () {
//                 if (videoBusy) {
//                   return;
//                 }
//                 goBackAction();
//               },
//             ),
//             Positioned(
//               bottom: 50,
//               child: Container(
//                 width: size.width,
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: BottomButtonRow(
//                   enableReplay: videoEnd,
//                   onPressReplay: () {
//                     if (videoEnd) {
//                       setState(() {
//                         videoEnd = false;
//                       });
//                       _videoController.play();
//                     }
//                   },
//                   enableNext: videoEnd,
//                   onPressNext: () {
//                     goNextAction();
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void goBackAction() {
//     final device = Provider.of<CleoDevice>(context);
//     assert(device.state is CartridgeSampleMixState);
//     (device.state as CartridgeSampleMixState).goBack();
//   }

//   void goNextAction() {
//     final device = Provider.of<CleoDevice>(context);
//     assert(device.state is CartridgeSampleMixState);
//     (device.state as CartridgeSampleMixState).goNext();
//   }
// }
