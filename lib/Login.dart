import "dart:convert";

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import "package:http/http.dart" as http;

import 'TabHandler.dart';
import 'notificationHelper.dart';
import 'package:validator/validator.dart';
class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new Scaffold(
        body: new Login1(),
      ),
    );
  }
}

class Login1 extends StatefulWidget {
  @override
  _Login1State createState() => _Login1State();
}

class _Login1State extends State<Login1> {
  FlutterSecureStorage storage = new FlutterSecureStorage();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  BuildContext context1;
  GlobalKey key = GlobalKey();
  TextEditingController controller = new TextEditingController(text: '@nu.edu.pk');
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    controller.addListener(() => listener());
  }

  @override
  Widget build(BuildContext context) {
    context1 = context;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Image(
            image: new AssetImage("assets/logo.png"),
            width: 150.0,
            height: 150.0,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: new TextField(

            controller: controller,
            decoration: InputDecoration(

                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                hintText: "---@---.com",
                icon: Icon(Icons.people)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: new RaisedButton(
            onPressed: () => submit(),
            child: new Text("Submit"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          ),
        ),
      ],
    );
  }

  bool isValidEmail(String email) {
    return isEmail(email);
  }

  listener() {}
  submit() async {
    String email = controller.text;
    if (!isValidEmail(email)) {
      Scaffold
          .of(context1)
          .showSnackBar(new SnackBar(content: new Text("Invalid Email Address")));
    } else {
      print('fetching');
      final response = await http.get(
          "https://tt.saadismail.net/api/fetch.php?email=\"EMAIL_HERE\"".replaceAll("EMAIL_HERE", email));
      var responseJson = json.decode(response.body.toString());
      print('fetched');

      if (responseJson['success'] == null || responseJson['success'] == 0) {
        Scaffold
            .of(context1)
            .showSnackBar(new SnackBar(content: new Text("Invalid User")));
      } else {
        print('writing');
        String fStatus=await storage.read(key: "friendStatus");

          if(fStatus==null)
            {
              await storage.write(key: 'friendStatus', value: '0');
            //  await storage.write(key: 'freinds', value: '[{"a":"b"}]');
            }



        await storage.write(key: 'status', value: '1');
        await storage.write(key: 'timetable', value:response.body.toString() );
        print('writen');

        scheduleNotification(flutterLocalNotificationsPlugin);
        print(responseJson);
        Navigator.of(context).pushReplacement(
            new MaterialPageRoute(builder: (BuildContext context) => new app()));
      }
    }
  }
}
