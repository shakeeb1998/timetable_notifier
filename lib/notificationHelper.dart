
import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

scheduleNotification() async
{

  var initializationSettingsAndroid =
    new AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = new IOSInitializationSettings();
  var initializationSettings = new InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

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

      String notificationTitle = 'In ' + room + " @ " + timing;
      print(dayI);
      print(startTime - 1);

      _showWeeklyAtDayAndTime(new Day(dayI + 2), new Time(startTime-1, 50, 0), notificationTitle, subject, flutterLocalNotificationsPlugin);
    }
  }
}

Future _showWeeklyAtDayAndTime(Day day, Time time, String title, String body, FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'show weekly channel id',
      'show weekly channel name',
      'show weekly description');
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  var platformChannelSpecifics = new NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
      0,
      title,
      body,
      day,
      time,
      platformChannelSpecifics);
}