import 'dart:async';
import 'package:timetable_notifier/functions.dart';

import 'TabHandler.dart';
import 'package:flutter/material.dart';
import 'Login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class _SplashScreenState extends State<SplashScreenStateful>
    with SingleTickerProviderStateMixin {
  FlutterSecureStorage storage = new FlutterSecureStorage();

  var _iconAnimation;
  AnimationController _iconAnimationController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _iconAnimationController = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 1500));

    _iconAnimation = new CurvedAnimation(
        parent: _iconAnimationController, curve: Curves.easeInOut);
    _iconAnimation.addListener(() => this.setState(() {}));

    _iconAnimationController.forward();
    _iconAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // custom code here
      }
    });

    initializeMeme();
  }

  initializeMeme() async {
    FlutterSecureStorage storage = new FlutterSecureStorage();
    String memes = await storage.read(key: "memes");
    if (memes == null) {
      await storage.write(key: 'memes', value: "1");
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Scaffold(
          backgroundColor: Colors.lightBlueAccent,
          body: Center(
            child: new FutureBuilder(
                future: storage.read(key: 'mainEmail'),
                builder: (context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data == null) {
                      return new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image(
                            image: new AssetImage("assets/logo.png"),
                            width: _iconAnimation.value * 200,
                            height: _iconAnimation.value * 200,
                          ),
                          new LoginActivity(),
                        ],
                      );
                    } else {
                      return new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image(
                            image: new AssetImage("assets/logo.png"),
                            width: _iconAnimation.value * 200,
                            height: _iconAnimation.value * 200,
                          ),
                          new TabHandlerActivity(),
                        ],
                      );
                    }
                  } else {
                    return new Image(
                      image: new AssetImage("assets/logo.png"),
                      width: _iconAnimation.value * 200,
                      height: _iconAnimation.value * 200,
                    );
                  }
                }),
          )),
    );
  }

  Future<String> _updateTimetableIfInternet() async {
    if (await isInternetWorking()) {
      String mainEmail = await storage.read(key: 'mainEmail');
      bool fetchSuccess = await fetchTimetable(mainEmail, context);
      return storage.read(key: mainEmail);
    }
  }
}

class SplashScreenStateful extends StatefulWidget {
  _SplashScreenState createState() => _SplashScreenState();
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  new SplashScreenStateful()
    ;
  }
}

class TabHandlerActivity extends StatefulWidget {
  @override
  _TabHandlerActivityState createState() => new _TabHandlerActivityState();
}

class _TabHandlerActivityState extends State<TabHandlerActivity> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gotoOrder(context);
  }

  gotoOrder(BuildContext context) async {
    FlutterSecureStorage storage = new FlutterSecureStorage();
    String memes = await storage.read(key: "memes");

    Navigator.of(context).pushReplacement(new MaterialPageRoute(
        builder: (BuildContext context) => new TabHandler(memes: memes)));
  }

  @override
  Widget build(BuildContext context) {
    return new Container();
  }
}

class LoginActivity extends StatefulWidget {
  @override
  _LoginActivityState createState() => new _LoginActivityState();
}

class _LoginActivityState extends State<LoginActivity> {
  FlutterSecureStorage storage = FlutterSecureStorage();

  void initState() {
    // TODO: implement initState
    super.initState();
    sleepForSplashScreen();
  }

  sleepForSplashScreen() async {
    var _duration = new Duration(seconds: 1);
    return new Timer(_duration, () => gotoLogin(context));
  }

  gotoLogin(BuildContext context) async {
    String memes = await storage.read(key: "memes");

    Navigator.of(context).pushReplacement(new MaterialPageRoute(
        builder: (BuildContext context) => new Login(
              memes: memes,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return new Container();
  }
}
