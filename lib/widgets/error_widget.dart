import 'package:flutter/material.dart';

/// Displays an error message in the UI.
///
/// This function creates a [Text] widget that shows the given [message] and
/// can be used anywhere in your app.
Widget buildErrorMessage(String message) {
  return Container(
    padding: const EdgeInsets.all(16.0),
    child: Text(
      message,
      style: const TextStyle(
        color: Colors.red,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
