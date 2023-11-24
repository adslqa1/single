import 'package:cleo/cleo_device/cleo_device.dart';
import 'package:cleo/cleo_device/cleo_state.dart';
import 'package:cleo/cleo_device/view/per_state/cartridge_process_base.dart';
import 'package:cleo/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class CartridgeSampleGetView extends StatefulWidget {
  const CartridgeSampleGetView({Key? key}) : super(key: key);

  @override
  State<CartridgeSampleGetView> createState() => _CartridgeSampleGetViewState();
}

class _CartridgeSampleGetViewState extends State<CartridgeSampleGetView> {
  static const desc =
      'Insert the swab tip into one nostril about 3/4 inches (for an adult) or 1/2 inches (for a child).\nSlowly roll the swab at least 5 times over the surface of the nostril. Using the same swab, repeat swabbing in the other nostril, making at least 5 circles.';
  static const videoPath = 'assets/video/step_3.mp4';

  final _videoController = VideoPlayerController.asset(videoPath);
  late Future<void>? _initializeVideoPlayerFuture;

  bool videoEnd = false;
  bool videoBusy = true;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayerFuture = _videoController.initialize().then((value) {
      setState(() {
        videoBusy = false;
      });
      _videoController.play();
      _videoController.addListener(positionListener);
    });
  }

  @override
  void dispose() {
    _videoController.removeListener(positionListener);
    _videoController.dispose();
    super.dispose();
  }

  void positionListener() {
    if (!mounted) {
      return;
    }
    // _videoController.position.then((Duration? value) {
    //   if (value != null &&
    //       _videoController.value.duration.inMilliseconds > 0 &&
    //       value.inMilliseconds >=
    //           _videoController.value.duration.inMilliseconds) {
    //     setState(() {
    //       videoEnd = true;
    //     });
    //   }
    // });
    _videoController.position.then((Duration? value) {
      if (value != null &&
          _videoController.value.duration.inMilliseconds > 0 &&
          value.inMilliseconds >= 2000) {
        setState(() {
          videoEnd = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final state =
        Provider.of<CleoDevice>(context).state as CartridgeSampleGetState;

    return WillPopScope(
      onWillPop: () async {
        goBackAction();
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return SizedBox(
                    width: size.width,
                    height: size.height,
                    child: VideoPlayer(_videoController),
                  );
                } else {
                  return const Center(child: CupertinoActivityIndicator());
                }
              },
            ),
            VideoDescriptionArea(
              description: desc,
              onPressBack: () {
                if (videoBusy) {
                  return;
                }
                goBackAction();
              },
            ),
            Positioned(
              bottom: 50,
              child: Container(
                width: size.width,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: BottomButtonRow(
                  enableReplay: videoEnd,
                  onPressReplay: () {
                    // if (videoEnd) {
                    //   setState(() {
                    //     videoEnd = false;
                    //   });
                    _videoController.seekTo(const Duration(seconds: 0));
                    _videoController.play();
                    // }
                  },
                  enableNext: videoEnd || MyApp.isDebug,
                  onPressNext: () {
                    goNextAction();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void goBackAction() {
    final device = Provider.of<CleoDevice>(context, listen: false);
    assert(device.state is CartridgeSampleGetState);
    (device.state as CartridgeSampleGetState).goBack();
  }

  void goNextAction() {
    final device = Provider.of<CleoDevice>(context, listen: false);
    assert(device.state is CartridgeSampleGetState);
    (device.state as CartridgeSampleGetState).goNext();
  }
}
