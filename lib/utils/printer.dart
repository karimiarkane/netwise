import 'package:flutter/foundation.dart';

void printDebug(String message) {
  if (kDebugMode) {
    print('DEBUG: $message');
  }
}