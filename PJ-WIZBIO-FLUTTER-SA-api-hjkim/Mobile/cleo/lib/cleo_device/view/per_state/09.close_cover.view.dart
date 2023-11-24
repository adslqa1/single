// import 'package:cleo/cleo_device/cleo_device.dart';
// import 'package:cleo/cleo_device/cleo_state.dart';
// import 'package:cleo/cleo_device/view/per_state/cartridge_process_base.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:video_player/video_player.dart';

// class CloseCoverView extends StatefulWidget {
//   const CloseCoverView({Key? key}) : super(key: key);

//   @override
//   State<CloseCoverView> createState() => _CloseCoverViewState();
// }

// class _CloseCoverViewState extends State<CloseCoverView> {
//   static const desc =
//       'Push the tube firmly down into the cartridge. Make sure that the tube is pressed in all the way.\nClose the lid of the CLEO ONE until it clicks.';
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
//     // _videoController.position.then((Duration? value) {
//     //   if (value != null &&
//     //       _videoController.value.duration.inMilliseconds > 0 &&
//     //       value.inMilliseconds >=
//     //           _videoController.value.duration.inMilliseconds) {
//     //     setState(() {
//     //       videoEnd = true;
//     //     });
//     //   }
//     // });
//     _videoController.position.then((Duration? value) {
//       if (value != null &&
//           _videoController.value.duration.inMilliseconds > 0 &&
//           value.inMilliseconds >= 2000) {
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
//               bottom: 100,
//               child: Container(
//                 width: size.width,
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: RichText(
//                   textAlign: TextAlign.center,
//                   text: const TextSpan(
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                     ),
//                     children: [
//                       TextSpan(
//                           text:
//                               'When the lid is closed properly, the test starts automatically.'),
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

//   void goBackAction() {
//     final device = Provider.of<CleoDevice>(context, listen: false);
//     assert(device.state is CloseCoverState);
//     (device.state as CloseCoverState).goBack();
//   }
// }








import 'package:cleo/cleo_device/cleo_device.dart';
import 'package:cleo/cleo_device/cleo_state.dart';
import 'package:cleo/cleo_device/view/per_state/cartridge_process_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class CloseCoverView extends StatefulWidget {
  const CloseCoverView({Key? key}) : super(key: key);

  @override
  State<CloseCoverView> createState() => _CloseCoverViewState();
}

class _CloseCoverViewState extends State<CloseCoverView> {
  static const desc =
      'Close the lid of the CLEO ONE until it clicks.\n'
      'When the lid is closed properly, the test starts automatically.';
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final state = Provider.of<CleoDevice>(context).state as CloseCoverState;

    return WillPopScope(
      onWillPop: () async {
        goBackAction();
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [


            Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'assets/step/7.png',
                width: size.width,
              ),
            ),



            VideoDescriptionArea(
              description: desc,
              onPressBack: () {
                // if (videoBusy) {
                //   return;
                // }
                goBackAction();
              },
            ),
            // Positioned(
            //   bottom: 100,
            //   child: Container(
            //     width: size.width,
            //     padding: const EdgeInsets.symmetric(horizontal: 24),
            //     child: RichText(
            //       textAlign: TextAlign.center,
            //       text: const TextSpan(
            //         style: TextStyle(
            //           color: Colors.white,
            //           fontSize: 20,
            //         ),
            //         children: [
            //           TextSpan(
            //               text:
            //                   'When the lid is closed properly, the test starts automatically.'),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void goBackAction() {
    final device = Provider.of<CleoDevice>(context, listen: false);
    assert(device.state is CloseCoverState);
    (device.state as CloseCoverState).goBack();
  }
}
