import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:timetable_notifier/functions.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class friendFinder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new FindFriend(context1: context),
    );
  }
}

class FindFriend extends StatefulWidget {
  BuildContext context1;
  FindFriend({this.context1}) {
    ;
  }

  @override
  _FindFriendState createState() => _FindFriendState(context1: context1);
}

class _FindFriendState extends State<FindFriend> {
  FlutterSecureStorage storage = new FlutterSecureStorage();
  BuildContext context1;
  // TextEditingController controller= new TextEditingController(text: '@nu.edu.pk');

  _FindFriendState({this.context1});

  @override
  Widget build(BuildContext context) {
    // context1=context;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Friends'),
      ),
      body: ListView.builder(
          shrinkWrap: true,
          itemCount: 1,
          itemBuilder: (BuildContext context, int Index) {
            return new Column(
              children: <Widget>[
                new Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SearchBar(
                    context1: context1,
                  ),
                ),
                new FutureBuilder(
                    future: storage.read(key: 'friendStatus'),
                    builder: (context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.data == '0') {
                          print(snapshot.data);
                          return
                              // new SizedBox(height: 100.0,),
                              Center(child: new Text('Add some friends'));
                        } else {
                          return new list(
                            context1: context1,
                          );
                        }
                      } else {
                        return new Center(
                          child: new CircularProgressIndicator(),
                        );
                      }
                    }),
              ],
            );
          }),
    );
  }
}

class SearchBar extends StatefulWidget {
  BuildContext context1;
  SearchBar({this.context1});

  @override
  _SearchBarState createState() => _SearchBarState(context1: context1);
}

class _SearchBarState extends State<SearchBar> {
  TextEditingController controller =
      new TextEditingController(text: '@nu.edu.pk');
  BuildContext context1;
  _SearchBarState({this.context1});

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        Expanded(
          child: new TextField(
            //style: TextStyle(color: Colors.black),
            controller: controller,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)))),
            onSubmitted: (str) => submit(),
          ),
        ),
        InkWell(
            highlightColor: Colors.red,
            borderRadius: BorderRadius.all(Radius.circular(50.0)),
            radius: 12.0,
            //behavior: HitTestBehavior.opaque,
            onTap: () => submit(),
            child: new Icon(
              Icons.search,
              size: 40.0,
            ))
      ],
    );
  }

  submit() async {
    print('in submit');
    String email = controller.text;
    print(email);
    FlutterSecureStorage storage = new FlutterSecureStorage();

    String currentRecord = await storage.read(key: email);
    bool toIncrement = (currentRecord == null);
    bool fetchSuccess = await fetchTimetable(email, context);
    if (fetchSuccess) {
      String response = await storage.read(key: email);
      var responseJson = json.decode(response);
      print(responseJson);

      if (toIncrement) {
        print('new id');
        String st = await storage.read(key: 'friendStatus');
        int friendsCount = int.parse(st);
        print(friendsCount);
        friendsCount++;
        await storage.write(key: "friendStatus", value: friendsCount.toString());
      }

      Map mapper = (await (storage.readAll()));
      print(mapper.keys.toList());
      Navigator.pop(context1, email);
    }
  }
}

class list extends StatefulWidget {
  BuildContext context1;
  list({this.context1});
  @override
  _listState createState() => _listState(context1: context1);
}

class _listState extends State<list> {
  FlutterSecureStorage storage = new FlutterSecureStorage();
  BuildContext context1;
  _listState({this.context1}) {
    print('nav state');
    print(Navigator.canPop(context1));
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: storage.readAll(),
      builder: (context, AsyncSnapshot<Map<String, String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          snapshot.data.remove('status');
          snapshot.data.remove('mainEmail');
          snapshot.data.remove('friends');
          snapshot.data.remove('memes');
          int x = int.parse(snapshot.data["friendStatus"]);
          snapshot.data.remove('friendStatus');

          return new ListView.builder(
              shrinkWrap: true,
              itemCount: x,
              itemBuilder: (context, index) {
                print(snapshot.data.keys.toList()[index]);
                return new ListTile(
                  onTap: () => friendsTable(json.decode(snapshot
                      .data[snapshot.data.keys.toList()[index].toString()])),
                  title: new Text(jsonDecode(snapshot.data[
                      snapshot.data.keys.toList()[index].toString()])['name']),
                );
              });
        } else {
          return new Container();
        }
      },
    );
  }

  friendsTable(var timeTable) {
    print('friend table');
    String email = timeTable['email'];
    Navigator.pop(context1, email);
  }
}
