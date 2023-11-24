import 'package:flutter/material.dart';

class ConfirmButton extends StatelessWidget {
  final Function onPressed;
  final String label;
  final MaterialStateProperty<Color?>? backgroundColor;
  final double? width;
  final Widget? child;
  const ConfirmButton({
    Key? key,
    required this.onPressed,
    required this.label,
    this.backgroundColor,
    this.width,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return ElevatedButton(
      onPressed: () => onPressed(),
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(0),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
        ),
        backgroundColor: backgroundColor,
      ),
      child: Container(
        width: width ?? size.width * 0.6,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Align(
          child: child ??
              Text(
                label,
                style: const TextStyle(fontSize: 18),
              ),
          alignment: Alignment.center,
        ),
      ),
    );
  }
}

class FlatConfirmButton extends StatelessWidget {
  final Function onPressed;
  final String label;
  final double? width;
  final bool reversal;

  const FlatConfirmButton({
    Key? key,
    required this.onPressed,
    required this.label,
    this.reversal = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return InkWell(
      onTap: () => onPressed(),
      child: Container(
        width: width ?? size.width * 0.6,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
            color: reversal ? Theme.of(context).primaryColor : null),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: reversal ? Colors.white : Theme.of(context).primaryColor,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
