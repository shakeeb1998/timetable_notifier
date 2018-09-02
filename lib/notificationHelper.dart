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

  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'timetable_channel_0',
      'Timetable Notifier',
      'Notifies about classes');
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  var platformChannelSpecifics = new NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

  FlutterSecureStorage flutterSecureStorage = new FlutterSecureStorage();
  String timetable = await flutterSecureStorage.read(key: 'timetable');
  var jsonTT = json.decode(timetable);

  int notificationId = 0;

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

      await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(notificationId,
          notificationTitle, subject, new Day(dayI + 2),
          new Time(startTime-1, 50, 0), platformChannelSpecifics);

      notificationId++;
    }
  }
}