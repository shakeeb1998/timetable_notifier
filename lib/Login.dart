import "dart:convert";

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import "package:http/http.dart" as http;
import 'package:timetable_notifier/functions.dart';
import 'TabHandler.dart';

class Login extends StatelessWidget {
 String memes="";
  Login({this.memes});
  @override
  Widget build(BuildContext context) {
    //print("shakku $memes");
    return MaterialApp(
      home: new Scaffold(
        body: new Login1(memes: memes,),
      ),
    );
  }
}

class Login1 extends StatefulWidget {
  String memes="";
  Login1({this.memes});
  @override
  _Login1State createState() => _Login1State(memes: memes);
}

class _Login1State extends State<Login1> {
  String memes='';
  _Login1State({this.memes});
  FlutterSecureStorage storage = new FlutterSecureStorage();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  BuildContext context1;
  GlobalKey key = GlobalKey();
  TextEditingController controller = new TextEditingController(text: 'k164060@nu.edu.pk');
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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

  listener() {}
  submit() async {
    String email = controller.text;
    if (!isValidEmail(email)) {
      Scaffold
          .of(context1)
          .showSnackBar(new SnackBar(content: new Text("Invalid Email Address")));
    } else if (! await isInternetWorking()) {
      Scaffold
          .of(context1)
          .showSnackBar(new SnackBar(content: new Text("Needs Internet Connectivity")));
    } else {
      try {
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
          }

          await storage.write(key: 'status', value: '1');
          await storage.write(key: 'timetable', value:response.body.toString() );
          scheduleNotification();
          print(responseJson);
          Navigator.of(context).pushReplacement(

              new MaterialPageRoute(builder: (BuildContext context) => new app(memes: memes,)));
        }
      } catch (e) {
        print(e);
        Scaffold
            .of(context1)
            .showSnackBar(new SnackBar(content: new Text("Could not fetch timetable")));
      }
    }
  }
}
