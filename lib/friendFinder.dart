import 'dart:async';
import 'dart:convert';
import 'dart:convert' show JSON;

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:validator/validator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timetable_notifier/TabHandler.dart';
import "package:http/http.dart" as http;

class freindFinder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(home: new FindFriend(context1: context),);
  }
}

class FindFriend extends StatefulWidget {
 BuildContext context1;
  FindFriend( {this.context1}){
    ;
  }

 @override
  _FindFriendState createState() => _FindFriendState(context1: context1);
}

class _FindFriendState extends State<FindFriend> {


  FlutterSecureStorage storage = new FlutterSecureStorage();
  BuildContext context1;
 // TextEditingController controller= new TextEditingController(text: '@nu.edu.pk');

  _FindFriendState({this.context1})
  {
  }


  @override
  Widget build(BuildContext context) {
   // context1=context;

    return
     new Scaffold(
        appBar: new AppBar(
          title: new Text('Friends'),

        ),
        body:ListView.builder(
          shrinkWrap: true,
        itemCount: 1,
        itemBuilder: (BuildContext context, int Index) {
          return new Column(
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.all(8.0),
                child: SearchBar(context1: context1,),
              ),
              new FutureBuilder(
                  future: storage.read(key: 'friendStatus'),
                  builder: (context,AsyncSnapshot<String>snapshot){
                    if(snapshot.connectionState==ConnectionState.done)
                    {
                      if(snapshot.data=='0' )
                      {
                        print(snapshot.data);
                        return
                            // new SizedBox(height: 100.0,),
                            Center(child :new Text('Add some friends'));

                      }
                      else
                        {
                          var response=json.decode(snapshot.data);
                          return new list(context1: context1,);
                        }

                    }
                    else
                    {
                      return new Center(
                        child: new CircularProgressIndicator(),
                      );
                    }

                  }),
            ],
          );
        }
      ),

    );

  }
  
  
}


class SearchBar extends StatefulWidget {
  BuildContext context1;
  SearchBar({this.context1})
  {

  }

  @override
  _SearchBarState createState() => _SearchBarState(context1: context1);
}

class _SearchBarState extends State<SearchBar> {
  TextEditingController controller= new TextEditingController(text: '@nu.edu.pk');
  BuildContext context1;
  _SearchBarState({this.context1})
  {

  }


  @override


  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        Expanded(child: new TextField(
          //style: TextStyle(color: Colors.black),
          controller: controller,
          decoration: InputDecoration(

              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0)))),
         // onSubmitted:(str)=>submit1(),
        ),
        )
        ,
        GestureDetector(
          behavior: HitTestBehavior.opaque,
            onTap:()=>  submit1(),
            child: new Icon(Icons.search,size: 40.0,))

      ],

    );
  }
  submit() async {
    print('in submit');
    String email = controller.text;
    print(email);
    FlutterSecureStorage storage=new FlutterSecureStorage();
    if (!isValidEmail(email)) {
      Scaffold
          .of(context)
          .showSnackBar(new SnackBar(content: new Text("Invalid Email Address")));
    } else {
      print('fetching');
      final response = await http.get(
          "https://tt.saadismail.net/api/fetch.php?email=\"EMAIL_HERE\"".replaceAll("EMAIL_HERE", email));
      var responseJson = json.decode(response.body.toString());
      print('fetched');
      print(responseJson);

      if (responseJson['success'] == null || responseJson['success'] == 0) {
        Scaffold
            .of(context)
            .showSnackBar(new SnackBar(content: new Text("Invalid User")));
      } else {
        String name=responseJson['email'];

        print('writing');
        String stpo=await storage.read(key: name);
        if(stpo==null)
          {
            print('new id');
            String st= await storage.read(key: 'friendStatus');
            int a=int.parse(st);
            print(a);
            int b=a+1;
            print(b);
            await storage.write(key: "friendStatus", value:b.toString() );
          }
          Map mapper=(await (storage.readAll()));
        print(mapper.keys.toList());
        await storage.write(key: name, value: response.body.toString());
        //print(json.decode(await storage.read(key: name))['name']);
        /*String num=await storage.read(key: "friendStatus");
        int b=int.parse(num);
        b=b-2;
        print(b);
        await storage.write(key:"friendStatus" , value: b.toString());*/
        Scaffold
            .of(context)
            .showSnackBar(new SnackBar(content: new Text("puttinng done")));

        print('here');

      //  print(bc);
        print('writen');
        Navigator.pop(context1,email);
        // scheduleNotification();
        /*Navigator.of(context1).pushReplacement(
           new MaterialPageRoute(builder: (BuildContext context) => new app()));*/
      }
    }
  }

  bool isValidEmail(String email) {
    return isEmail(email);
  }

  submit1()
  {
    print('SahKEEB');
    submit();
  }
}

class list extends StatefulWidget {
  BuildContext context1;
  list({this.context1})
  {

  }
  @override
  _listState createState() => _listState(context1:context1);
}

class _listState extends State<list> {
  FlutterSecureStorage storage=new FlutterSecureStorage();
  BuildContext context1;
  _listState({this.context1}){
    print('nav state');
    print(Navigator.canPop(context1));
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(

      future: storage.readAll(),
      builder: (context,AsyncSnapshot<Map<String,String>>snapshot)
    {

    if(snapshot.connectionState==ConnectionState.done)
    {
      print('shala');
      snapshot.data.remove('s');
      snapshot.data.remove('freinds');
      snapshot.data.remove('status');
      snapshot.data.remove('0');
      snapshot.data.remove('timetable');
      snapshot.data.remove('friends');
      int x=int.parse(snapshot.data["friendStatus"]);
      snapshot.data.remove('friendStatus');


      print( x );
      return new ListView.builder(
        shrinkWrap: true,
          itemCount: x,
          itemBuilder: (context,index){
          print(snapshot.data.keys.toList()[index]);
            return new ListTile(onTap: ()=>freindsTable(json.decode(snapshot.data[snapshot.data.keys.toList()[index].toString()])),title: new Text(jsonDecode(snapshot.data[snapshot.data.keys.toList()[index].toString()])['name']),);
          }
      );
    }
    else
    {
      return new Container();
    }
    },
    );

  }
  freindsTable(var timeTable)
  {
    print('friend table');
    String email=timeTable['email'];
    Navigator.pop(context1,email);
  }
}

