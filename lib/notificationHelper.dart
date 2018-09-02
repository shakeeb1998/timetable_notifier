
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import 'package:path/path.dart';

scheduleNotification(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async
{

  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'timetable channel id', 'timetable channel name', 'timetable channel description',
      importance: Importance.Max,
      priority: Priority.High,
      icon: 'ic_launcher',
      onlyAlertOnce: true);
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  var platformChannelSpecifics = new NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

  FlutterSecureStorage flutterSecureStorage = new FlutterSecureStorage();
  String timetable = await flutterSecureStorage.read(key: 'timetable');
  var jsonTT = json.decode(timetable);

  for (int dayI = 0; dayI < 5; dayI++) {
    var classes = jsonTT[dayI.toString()];

    for (var dayClass in classes) {
      String subject = dayClass['subject'].toString().trim();
      String timing = dayClass['timing'].toString().trim();
      String room = dayClass['room'].toString().trim();

      int startTime = int.parse(timing.split('-')[0]);
      if (startTime < 8) startTime += 12;

      print('In ' + room + " @ " + timing + " " + subject);

      await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
          0, 'In ' + room + " @ " + timing, subject, new Day(dayI + 2),
          new Time(startTime - 1, 50, 0), platformChannelSpecifics);

    }
  }
}
