import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cleo/constants.dart' as cons;

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;
  final String title;
  final bool useBack;
  final Widget? reading;

  CustomAppBar({
    this.title = '',
    this.useBack = false,
    Key? key,
    this.reading,
  })  : preferredSize = const Size.fromHeight(80.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 32, right: 16, top: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                if (useBack)
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const SizedBox(
                      width: 40,
                      height: 50,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          CupertinoIcons.arrow_left,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                Text(
                  title,
                  style: const TextStyle(
                    color: cons.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            if (reading != null) reading!,
          ],
        ),
      ),
    );
  }
}
