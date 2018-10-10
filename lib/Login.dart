import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timetable_notifier/functions.dart';
import 'TabHandler.dart';

class Login extends StatelessWidget {
  Login();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new LoginStateful(),

    );
  }
}

class LoginStateful extends StatefulWidget {
  LoginStateful();
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginStateful> {
  bool progressDialogStatus = false;
  _LoginState();
  FlutterSecureStorage storage = new FlutterSecureStorage();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  BuildContext context;
  TextEditingController textEditingController =
      new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
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
            controller: textEditingController,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                icon: Icon(Icons.people)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: new RaisedButton(
            onPressed: () => submit(),
            child: (!progressDialogStatus)
                ? new Text("Submit")
                : new Padding(
                    padding: EdgeInsets.all(2.0),
                    child: new CircularProgressIndicator(
                      strokeWidth: 1.0,
                    ),
                  ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          ),
        ),
      ],
    );
  }

  submit() async {
    setState(() {
      progressDialogStatus = true;
    });

    String email = textEditingController.text;
    bool fetchSuccess = await fetchTimetable(email, context);
    if (fetchSuccess) {
      String friendsList = await storage.read(key: "friendsList");

      if (friendsList == null) {
        await storage.write(key: 'friendsList', value: '[]'); // Initialize with blank List
      }

      await storage.write(key: 'mainEmail', value: email);
      scheduleNotification();
      Navigator.of(context).pushReplacement(new MaterialPageRoute(
          builder: (BuildContext context) => new TabHandler()));
    } else {
      await storage.delete(key: 'mainEmail');
      setState(() {
        progressDialogStatus = false;
      });
    }
  }
}
