import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';
import "package:http/http.dart" as http;
import "dart:async";
import "dart:convert";
import 'TabHandler.dart';
import 'SplashScreen.dart';
import 'Login.dart';

void main() => runApp(new SplashScreen(
   // theme: new ThemeData(
     // brightness: Brightness.light,
      //primaryColor: Colors.black, //Changing this will change the color of the TabBar
      //accentColor: Colors.cyan[600],
    ),

    );

class Cards extends StatefulWidget {
  @override
  _CardsState createState() => _CardsState();
}

class _CardsState extends State<Cards> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   // WidgetsBinding.instance.addPostFrameCallback((_)=>getTable());
  }
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Center(
        child: new RaisedButton(onPressed: ()=>getTable(),child: new Text("pressed"),),
      ),

    );
  }

  getTable()
  async
  {
    print('hello');
    final response = await http.get("https://tt.saadismail.net/api/fetch.php?email=%22k164060%40nu.edu.pk%22");
   // print(response.body)
    var responseJson = json.decode(response.body.toString());
    List a =responseJson['0'];
    print(a[0]['subject']);
  }

}
