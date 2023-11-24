import 'package:flutter/material.dart';
import 'package:cleo/constants.dart' as cons;

class VideoDescriptionArea extends StatelessWidget {
  final String description;
  final void Function()? onPressBack;
  final bool hideBack;
  const VideoDescriptionArea(
      {Key? key,
      this.description = '',
      this.onPressBack,
      this.hideBack = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            // Colors.black.withOpacity(0.2),
            // Colors.black.withOpacity(0.2),
            // Colors.black.withOpacity(0.2),
            Colors.grey.withOpacity(1),
            Colors.grey.withOpacity(1),
            Colors.grey.withOpacity(1),
          ],
          stops: const [0, 0.5, 1],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16),
              child: Align(
                alignment: Alignment.topLeft,
                child: hideBack
                    ? const SizedBox()
                    : IconButton(
                        onPressed: onPressBack,
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 48),
              child: Text(
                description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BottomButtonRow extends StatelessWidget {
  final bool enableReplay;
  final bool enableNext;
  final bool hideNext;
  final void Function()? onPressReplay;
  final void Function()? onPressNext;

  const BottomButtonRow({
    Key? key,
    this.enableReplay = true,
    this.enableNext = true,
    this.hideNext = false,
    this.onPressReplay,
    this.onPressNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: enableReplay ? onPressReplay : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                // color: enableReplay ? const Color(0xff6D53D7) : Colors.grey,
                color: enableReplay
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: enableReplay
                      ? Colors.transparent
                      : Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  'REPLAY',
                  style: TextStyle(
                    color: enableReplay
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: hideNext
              ? const SizedBox()
              : InkWell(
                  onTap: enableNext ? onPressNext : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      // color: enableNext ? cons.primary : Colors.grey,
                      color: enableNext
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: enableNext
                            ? Colors.transparent
                            : Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'NEXT',
                        style: TextStyle(
                          color: enableNext
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
