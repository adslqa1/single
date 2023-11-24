import 'package:cleo/screen/cartridge/test_result.dart';
import 'package:cleo/screen/common/confirm_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CartridgeFinalScreen extends StatefulWidget {
  static const routeName = '/cartirdgeFinal';

  final int reportId;

  const CartridgeFinalScreen({Key? key, required this.reportId})
      : super(key: key);

  @override
  State<CartridgeFinalScreen> createState() => _CartridgeFinalScreenState();
}

class _CartridgeFinalScreenState extends State<CartridgeFinalScreen> {
  late VideoPlayerController _videoController;
  late Future<void>? _initializeVideoPlayerFuture;

  bool videoEnd = false;
  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/video/step_7.mp4');
    _initializeVideoPlayerFuture = _videoController.initialize();
    _videoController.play();
    _videoController.addListener(positionListener);
  }

  @override
  void dispose() {
    _initializeVideoPlayerFuture = null;
    _videoController.pause().then((_) {
      _videoController.removeListener(positionListener);
      _videoController.dispose();
    });
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
    return Scaffold(
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
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0),
                  ],
                  stops: const [0, 0.5, 1],
                ),
              ),
              child: const Text(
                'Take out the Test Cartridge and tube from the CLEO ONE. Place them into the disposable bag together with the swab. Dispose of the bag as general waste.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            child: SizedBox(
              width: size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FlatConfirmButton(
                      reversal: videoEnd,
                      onPressed: () {
                        if (!videoEnd) {
                          return;
                        }
                        replayVideo();
                      },
                      label: 'REPLAY',
                    ),
                    const SizedBox(height: 16),
                    FlatConfirmButton(
                      reversal: videoEnd,
                      onPressed: () {
                        if (!videoEnd) {
                          return;
                        }
                        goReportResult();
                      },
                      label: 'VIEW TEST RESULT',
                    ),
                    const SizedBox(height: 16),
                    FlatConfirmButton(
                      onPressed: () {
                        if (!videoEnd) {
                          return;
                        }
                        goHome();
                      },
                      label: 'HOME',
                      reversal: videoEnd,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void goReportResult() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TestResultScreen(reportId: widget.reportId),
      ),
    );
  }

  replayVideo() {
    _videoController.seekTo(const Duration(seconds: 0));
    _videoController.play();
  }
}
