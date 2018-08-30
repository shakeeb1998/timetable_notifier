import 'dart:async';
import 'TabHandler.dart';
import 'package:flutter/material.dart';
import 'Login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class _SplashScreenState extends State<SplashScreen1>
    with SingleTickerProviderStateMixin {
  FlutterSecureStorage storage=new FlutterSecureStorage();

  var _iconAnimation;
AnimationController _iconAnimationController;

   handleTimeout() async {


  }


  startTimeout() async {
    var duration = const Duration(seconds: 1);
    return new Timer(duration, handleTimeout);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _iconAnimationController = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 2000));

     _iconAnimation = new CurvedAnimation(
        parent: _iconAnimationController, curve: Curves.easeInOut);
    _iconAnimation.addListener(() => this.setState(() {}));

    _iconAnimationController.forward();
    _iconAnimationController.addStatusListener((status) {
      if(status == AnimationStatus.completed) {
        // custom code here
      }
    });

    startTimeout();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Scaffold(
        backgroundColor: Colors.lightBlueAccent,
        body:Center(
          child: new FutureBuilder(
              future: storage.read(key: 'status'),
              builder: (context,AsyncSnapshot<String>snapshot){
                if(snapshot.connectionState==ConnectionState.done) {
                  print(snapshot.data);
                  if (snapshot.data==null||snapshot.data=='0')
                    {
                      return new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image(
                            image: new AssetImage("assets/logo.png"),
                            width: _iconAnimation.value * 200,
                            height: _iconAnimation.value * 200,
                          ),
                          new dummy1(),
                        ],
                      );
                    }
                  else
                    {
                      return new Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: <Widget>[
                          Image(
                            image: new AssetImage("assets/logo.png"),
                            width: _iconAnimation.value * 200,
                            height: _iconAnimation.value * 200,
                          ),
                          new dummy(),
                        ],
                      );
                    }
                }
                else{
                  return new Image(
                    image: new AssetImage("assets/logo.png"),
                    width: _iconAnimation.value * 200,
                    height: _iconAnimation.value * 200,
                  );
                }

          }),
        )

            ),
    );
  }
}


class SplashScreen1 extends StatefulWidget{
  _SplashScreenState createState() => _SplashScreenState();



}
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new SplashScreen1(),
    );
  }
}


class dummy extends StatefulWidget {
  @override
  _dummyState createState() => new _dummyState();
}

class _dummyState extends State<dummy> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTime();
  }

  startTime() async {
    var _duration = new Duration(seconds: 1);
    return new Timer(_duration, () => gotoOrder(context));
  }

  gotoOrder(BuildContext context) {
    Navigator.of(context).pushReplacement(
        new MaterialPageRoute(builder: (BuildContext context) => new app()));
  }

  @override
  Widget build(BuildContext context) {
    return new Container();
  }
}

class dummy1 extends StatefulWidget {
  @override
  _dummy1State createState() => new _dummy1State();
}

class _dummy1State extends State<dummy1> {
  void initState() {
    // TODO: implement initState
    super.initState();
    startTime();
  }

  startTime() async {
    var _duration = new Duration(seconds: 1);
    return new Timer(_duration, () => gotoLogin(context));
  }

  gotoLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
        new MaterialPageRoute(builder: (BuildContext context) => new Login()
        ));
  }

  @override
  Widget build(BuildContext context) {
    return new Container();
  }
}



