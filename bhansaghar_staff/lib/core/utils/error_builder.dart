import 'package:flutter/material.dart';

void initializeErrorWidget() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 60, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  'Oops! Something went wrong.',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  details.exception.toString(),
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };
}
