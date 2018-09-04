import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


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

bool isValidEmail(String email) {
  RegExp _email = new RegExp(r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$");
  return _email.hasMatch(email.toLowerCase());
}

void cancelAllScheduledNotifications() {
  var initializationSettingsAndroid =
    new AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = new IOSInitializationSettings();
  var initializationSettings = new InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
  flutterLocalNotificationsPlugin.cancelAll();
}

List<String> getStartTimeAndEndTime(String time)
{
  var timer=time.split('-');
  timer[0]=timer[0]+':00';
  if (timer[0].split(':')[0].length == 1) timer[0] = "0" + timer[0]; // Add leading zero for consistency
  if (timer[1].split(':')[0].length == 1) timer[1] = "0" + timer[1]; // Add leading zero for consistency
  return timer;
}

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
      'timetable_channel_0', 'Timetable Notifier', 'Notifies about classes',
      importance: Importance.Max, priority: Priority.Max);

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

      await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(notificationId,
          notificationTitle, subject, new Day(dayI + 2),
          new Time(startTime-1, 50, 0), platformChannelSpecifics);

      notificationId++;
    }
  }
}