import 'dart:developer';

import 'package:cleo/cleo_device/cleo_device.dart';
import 'package:cleo/cleo_device/cleo_state.dart';
import 'package:cleo/cleo_device/view/per_state/cartridge_process_base.dart';
import 'package:cleo/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class CartridgeSampleCloseView extends StatefulWidget {
  const CartridgeSampleCloseView({Key? key}) : super(key: key);

  @override
  State<CartridgeSampleCloseView> createState() =>
      _CartridgeSampleCloseViewState();
}

class _CartridgeSampleCloseViewState extends State<CartridgeSampleCloseView> {
  static const desc =
      'Place the swab tip down in the tube and locate the break point. Snap the swab handle at the break point. Leave the swab in the tube and discard stick.';
  static const endDesc = 'Close the cap firmly.';
  static const videoPath = 'assets/video/step_4.mp4';

  final _videoController = VideoPlayerController.asset(videoPath);
  late Future<void>? _initializeVideoPlayerFuture;

  bool videoEnd = false;
  bool videoBusy = true;
  bool captionEnd = false;

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
    _videoController.position.then((Duration? value) {
      if (value != null &&
          _videoController.value.duration.inMilliseconds > 0 &&
          value.inMilliseconds >=
              _videoController.value.duration.inMilliseconds - 2550 &&
          value.inMilliseconds <=
              _videoController.value.duration.inMilliseconds - 2540) {
        setState(() {
          captionEnd = true;
        });
      }
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
        Provider.of<CleoDevice>(context).state as CartridgeSampleCloseState;

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
              description: captionEnd ? endDesc : desc,
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
                    setState(() {
                      videoEnd = false;
                      captionEnd = false;
                    });
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
    assert(device.state is CartridgeSampleCloseState);
    (device.state as CartridgeSampleCloseState).goBack();
  }

  void goNextAction() {
    final device = Provider.of<CleoDevice>(context, listen: false);
    assert(device.state is CartridgeSampleCloseState);
    (device.state as CartridgeSampleCloseState).goNext();
  }
}
