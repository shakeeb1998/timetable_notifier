import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timetable_notifier/functions.dart';
import 'Login.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'friendFinder.dart';

//Globals Variables
class TabHandler extends StatelessWidget {
  TabHandler();

  @override
  Widget build(BuildContext context) {
    return TabHandlerStateful();
  }
}

class TabHandlerStateful extends StatefulWidget {
  TabHandlerStateful();
  @override
  _TabHandlerState createState() => _TabHandlerState();
}

class _TabHandlerState extends State<TabHandlerStateful> with SingleTickerProviderStateMixin {
  _TabHandlerState();

  String currTable = 'mainEmail';
  var timeTable;
  TabController _tabController;
  int tabToShow;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  FlutterSecureStorage storage = FlutterSecureStorage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tabToShow = (DateTime.now().weekday - 1);
    tabToShow = (tabToShow >= 0 && tabToShow <= 4) ? tabToShow : 0;

    _tabController =
        new TabController(vsync: this, length: 5, initialIndex: tabToShow);
  }

  remove() {
    cancelAllScheduledNotifications();
    storage.delete(key: 'mainEmail');
    Navigator.of(context).pushReplacement(
        new MaterialPageRoute(builder: (BuildContext context) => new Login()));
  }

  myTimeTable() {
    Navigator.pop(context);
    if (currTable != 'mainEmail') {
      setState(() {
        currTable = 'mainEmail';
        _tabController.animateTo(tabToShow);
      });
    }
  }

  friends(BuildContext context) async {
    Navigator.of(context).pop();

    var val = await Navigator.push(context,
        new MaterialPageRoute(builder: (context) => new friendFinder()));
    if (val != null) {
      setState(() {
        currTable = val;
        _tabController.animateTo(tabToShow);
      });
    }
  }

  fetch() async {
    String email = timeTable['email'].toString();
    bool fetchSuccess = await fetchTimetable(email, context);
    if (fetchSuccess) {
      var responseJson = json.decode(await storage.read(key: email));
      setState(() {
        timeTable = responseJson;
        _tabController.animateTo(tabToShow);
      });

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: new Drawer(
        child: new FutureBuilder(
            future: _getMainEmailTimetable(),
            builder: (context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                var timetableJson = json.decode(snapshot.data);
                return new ListView(
                  children: <Widget>[
                    new UserAccountsDrawerHeader(
                      accountEmail: new Text(timetableJson['name'].toString()),
                      accountName: new Text(timetableJson['email'].toString()),
                      decoration: new BoxDecoration(
                          image: new DecorationImage(
                              image: CachedNetworkImageProvider(
                                  "https://img00.deviantart.net/35f0/i/2015/018/2/6/low_poly_landscape__the_river_cut_by_bv_designs-d8eib00.jpg"),
                              fit: BoxFit.fill)),
                    ),
                    new ListTile(
                      title: new Text("My Timetable"),
                      onTap: () => myTimeTable(),
                    ),
                    new Divider(
                      color: Colors.lightBlue,
                    ),
                    new ListTile(
                      title: new Text("Friends"),
                      onTap: () => friends(context),
                    ),
                    new Divider(
                      color: Colors.lightBlue,
                    ),
                    new ListTile(
                      title: new Text("Remove"),
                      onTap: () => remove(),
                    ),
                    new Divider(
                      color: Colors.lightBlue,
                    ),
                    new ListTile(
                        title: new Text("Fetch"), onTap: () => fetch()),
                  ],
                );
              } else {
                return new Container();
              }
            }),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            new SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              child: FlexSpace(
                      tabController: _tabController,
                      height: 0.0,
                    )
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.lime,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(text: "Mon"),
                    Tab(text: "Tue"),
                    Tab(text: "Wed"),
                    Tab(text: "Thu"),
                    Tab(text: "Fri"),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: new FutureBuilder(
            future: (currTable == "mainEmail") ? _getMainEmailTimetable() : storage.read(key: currTable),
            builder: (context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                timeTable = json.decode(snapshot.data);
                return new TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    Carder(
                      day: timeTable['0'],
                    ),
                    Carder(
                      day: timeTable['1'],
                    ),
                    Carder(
                      day: timeTable['2'],
                    ),
                    Carder(
                      day: timeTable['3'],
                    ),
                    Carder(
                      day: timeTable['4'],
                    ),
                  ],
                );
              } else {
                return new Container();
              }
            }),
      ),
    );
  }

  Future<String> _getMainEmailTimetable() async {
    String mainEmail = await storage.read(key: 'mainEmail');
    return storage.read(key: mainEmail);
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: Material(color: Colors.black, child: _tabBar),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class Carder extends StatefulWidget {
  List day;
  Carder({this.day});
  @override
  _CarderState createState() => _CarderState(day: day);
}

class _CarderState extends State<Carder> {
  ScrollController _scrollController = new ScrollController();

  List day;
  _CarderState({this.day});

  @override
  Widget build(BuildContext context) {
    return new SafeArea(
      top: false,
      bottom: false,
      child: new Builder(
        builder: (BuildContext context) {
          return new CustomScrollView(
            //key: new PageStorageKey<_Page>(page),
            slivers: <Widget>[
              new SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              new SliverPadding(
                padding: const EdgeInsets.symmetric(
                  vertical: 0.0,
                  horizontal: 0.0,
                ),
                sliver: new SliverList(
                  delegate: new SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      // final _CardData data = _allPages[page][index];
                      return new Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 0.0,
                        ),
                        child: new Card(

                              //  new Text('hehhe'),
                           child:    Column(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[


                                              (day[index]['timing'] != null)
                                                  ?
                                              new Padding(padding:EdgeInsets.all(10.0),
                                                  child: new Text(
                                                      day[index]['subject'],
                                                      style: TextStyle(fontSize: 24.0),
                           )
                                              )
                                                  : new Container(),
                                    ],
                                  ),
                                  new Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      (day[index]['room'] != null)
                                          ? new Padding(padding: EdgeInsets.all(20.0),
                                      child: new Text(
                                        day[index]['room'],
                                        style: TextStyle(fontSize: 24.0),
                                      ),)
                                          : new Container(),
                                      new Padding(padding:EdgeInsets.all(20.0) ,child: new Text(getStartTimeAndEndTime(day[index]['timing'])[0]+"-"+getStartTimeAndEndTime(day[index]['timing'])[1],
                                        style: TextStyle(fontSize: 24.0),
                                      ),),
                            ],
                                  ),
                                ],
                              ),

                        ),
                      );
                    },
                    childCount: day.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class FlexSpace extends StatefulWidget {
  TabController tabController;

  FlexSpace({this.tabController, this.height});
  double height;
  //_FlexSpaceState flex=new _FlexSpaceState(tabController: tabController,hieght: hieght,status:status);
  @override
  _FlexSpaceState createState() => _FlexSpaceState(
      tabController: tabController, height: height);
}

class _FlexSpaceState extends State<FlexSpace> {
  double height;
  FlutterSecureStorage storage = FlutterSecureStorage();
  TabController tabController;
  _FlexSpaceState({this.tabController, this.height}) {
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: new Text("Timetable Notifier"),
      expandedHeight: height,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: new FittedBox(
          fit: BoxFit.cover,
          child: new Container(),
        ),
      ),
    );

    //add Image here
  }

}

class VerticalDivider1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 30.0,
      width: 1.0,
      color: Colors.black,
      margin: const EdgeInsets.only(left: 10.0, right: 10.0),
    );
  }
}
