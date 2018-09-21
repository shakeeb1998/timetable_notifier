import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:timetable_notifier/User.dart';
import 'package:timetable_notifier/functions.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class friendFinder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new FindFriend(context1: context);
  }
}

class FindFriend extends StatefulWidget {
  BuildContext context1;
  FindFriend({this.context1});

  @override
  _FindFriendState createState() => _FindFriendState(context1: context1);
}

class _FindFriendState extends State<FindFriend> {
  FlutterSecureStorage storage = new FlutterSecureStorage();
  BuildContext context1;
  _FindFriendState({this.context1});

  @override
  Widget build(BuildContext context) {

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
                    future: storage.read(key: 'friendsList'),
//                    future: storage.read(key: 'friendStatus'),
                    builder: (context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        List friendsList = json.decode(snapshot.data);
                        if (friendsList.length == 0) {
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
            splashColor: Colors.lightBlueAccent,
            highlightColor: Colors.lightBlueAccent,
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
    String email = controller.text;
    FlutterSecureStorage storage = new FlutterSecureStorage();

    String currentRecord = await storage.read(key: email);
    bool isNewFriend = (currentRecord == null); // Check if the new friend or old

    bool fetchSuccess = await fetchTimetable(email, context);
    if (fetchSuccess) {
      String response = await storage.read(key: email);

      if (isNewFriend) {
        List friendsList = json.decode(await storage.read(key: 'friendsList'));
        friendsList.add(response);
        storage.write(key: 'friendsList', value: json.encode(friendsList));
      }

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
  _listState({this.context1});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: storage.read(key: 'friendsList'),
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          List friendsList = json.decode(snapshot.data);

          return new ListView.builder(
              shrinkWrap: true,
              itemCount: friendsList.length,
              itemBuilder: (context, index) {
                User friend = new User.fromJson(json.decode(friendsList[index]));
                return new ListTile(
                  onTap: () => friendsTable(friend.email),
                  title: new Text(friend.name),
                );
              });
        } else {
          return new Container();
        }
      },
    );
  }

  friendsTable(String email) {
    Navigator.pop(context1, email);
  }
}
