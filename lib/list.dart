import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
Future<bool> isInternetWorking() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on SocketException catch (_) {
    return false;
  }
}
