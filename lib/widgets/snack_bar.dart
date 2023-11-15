import 'package:flutter/material.dart';

void showRedSnackBar(BuildContext context, String message, {Color backgroundColor = Colors.red, int duration = 3}) {
  final snackBar = SnackBar(
    content: Text(message, textAlign: TextAlign.center),
    duration: Duration(seconds: duration),
    backgroundColor: backgroundColor,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
void showGreenSnackBar(BuildContext context, String message, {Color backgroundColor = Colors.green, int duration = 3}) {
  final snackBar = SnackBar(
    content: Text(message, textAlign: TextAlign.center),
    duration: Duration(seconds: duration),
    backgroundColor: backgroundColor,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
void showDarkSnackBar(BuildContext context, String message, {Color backgroundColor = Colors.grey, int duration = 5}) {
  final snackBar = SnackBar(
    content: Text(message, textAlign: TextAlign.center),
    duration: Duration(seconds: duration),
    backgroundColor: backgroundColor,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}