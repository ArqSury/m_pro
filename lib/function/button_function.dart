import 'package:flutter/material.dart';

class ButtonFunction extends StatefulWidget {
  const ButtonFunction({
    super.key,
    this.text,
    this.onPressed,
    this.width,
    this.height,
    this.backgroundColor,
    this.color,
    this.fontSize,
  });
  final String? text;
  final void Function()? onPressed;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? color;
  final double? fontSize;

  @override
  State<ButtonFunction> createState() => _ButtonFunctionState();
}

class _ButtonFunctionState extends State<ButtonFunction> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          widget.text!,
          style: TextStyle(
            fontSize: widget.fontSize,
            color: widget.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
