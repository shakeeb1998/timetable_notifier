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
  String memes;
  TabHandler({this.memes});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TabHandlerStateful(
        memes: memes,
      ),
    );
  }
}

class TabHandlerStateful extends StatefulWidget {
  String memes;
  TabHandlerStateful({this.memes});
  @override
  _TabHandlerState createState() => _TabHandlerState(memes: memes);
}

class _TabHandlerState extends State<TabHandlerStateful> with SingleTickerProviderStateMixin {
  _TabHandlerState({this.memes});
  String memes;

  ValueNotifier memeState;
  bool SwitchVal;
  String currTable = 'mainEmail';
  var timeTable;
  TabController _tabController;
  int tabToShow;
  String photo1 =
      'https://img00.deviantart.net/35f0/i/2015/018/2/6/low_poly_landscape__the_river_cut_by_bv_designs-d8eib00.jpg';
  String photo2 =
      'https://images.pexels.com/photos/396547/pexels-photo-396547.jpeg?auto=compress&cs=tinysrgb&h=350';
  String photo3 =
      'http://techblogcorner.com/wp-content/uploads/2014/09/jpeg.jpg';
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  FlutterSecureStorage storage = FlutterSecureStorage();

  @override
  void initState() {
    memeState = ValueNotifier(0);
    // TODO: implement initState
    super.initState();

    SwitchVal = (memes == '1') ? true : false;

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
                    new Divider(
                      color: Colors.lightBlue,
                    ),
                    //new ListTile(title:new Text("Memes"),onTap:null,trailing: new Switcher(memeState: memeState,val: SwitchVal,),)
                    new Container(
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Expanded(
                            child: new Container(
                              // constraints: BoxConstraints.tightForFinite(width: 5000.0),
                              child: new ListTile(
                                title: new Text("Memes"),
                              ),
                            ),
                          ),
                          // new Text("dfg"),
                          new Switcher(
                            memeState: memeState,
                            val: SwitchVal,
                          ),
                        ],
                      ),
                    ),
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
              child: (memes == '1')
                  ? FlexSpace(
                      tabController: _tabController,
                      memeState: memeState,
                      height: 200.0,
                    )
                  : FlexSpace(
                      tabController: _tabController,
                      memeState: memeState,
                      height: 0.0,
                    ),
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
                          child: new Stack(
                            overflow: Overflow.visible,
                            fit: StackFit.passthrough,
                            alignment: Alignment(-1.0, 0.0),
                            children: <Widget>[
                              new Opacity(
                                opacity: 1.0,
                                child: new Card(
                                  elevation: 15.0,
                                  color: Color(int.parse(day[index]['color'])),
                                  child: Row(
                                    // mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new Row(
                                        children: <Widget>[
                                          new Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              new Opacity(
                                                opacity: 0.0,
                                                child: new Text(
                                                  (getStartTimeAndEndTime(
                                                      day[index]['timing'])[0]),
                                                  style:
                                                      TextStyle(fontSize: 24.0),
                                                ),
                                              ),
                                              new Opacity(
                                                opacity: 0.0,
                                                child: new Text(
                                                  (getStartTimeAndEndTime(
                                                      day[index]['timing'])[1]),
                                                  style:
                                                      TextStyle(fontSize: 24.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                          //  new VerticalDivider1(),
                                        ],
                                      ),
                                      new Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          new Opacity(
                                            opacity: 0.0,
                                            child: day[index]['timing'] != null
                                                ? new Text(
                                                    day[index]['subject'],
                                                    style: TextStyle(
                                                      fontSize: 24.0,
                                                    ))
                                                : new Container(),
                                          ),
                                          new Opacity(
                                              opacity: 0.0,
                                              child: (day[index]['room'] !=
                                                      null)
                                                  ? new Text(day[index]['room'],
                                                      style: TextStyle(
                                                        fontSize: 24.0,
                                                      ))
                                                  : new Container()),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),

                              //  new Text('hehhe'),
                              Row(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  new Row(
                                    children: <Widget>[
                                      new Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          new Text(
                                            (getStartTimeAndEndTime(
                                                day[index]['timing'])[0]),
                                            style: TextStyle(fontSize: 24.0),
                                          ),
                                          new Text(
                                            (getStartTimeAndEndTime(
                                                day[index]['timing'])[1]),
                                            style: TextStyle(fontSize: 24.0),
                                          ),
                                        ],
                                      ),
                                      new VerticalDivider1(),
                                    ],
                                  ),
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      (day[index]['timing'] != null)
                                          ? new Text(
                                              day[index]['subject'],
                                              style: TextStyle(fontSize: 24.0),
                                            )
                                          : new Container(),
                                      (day[index]['room'] != null)
                                          ? new Text(
                                              day[index]['room'],
                                              style: TextStyle(fontSize: 24.0),
                                            )
                                          : new Container(),
                                    ],
                                  )
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
  var memeState;

  FlexSpace({this.tabController, this.height, this.memeState});
  double height;
  //_FlexSpaceState flex=new _FlexSpaceState(tabController: tabController,hieght: hieght,status:status);
  @override
  _FlexSpaceState createState() => _FlexSpaceState(
      tabController: tabController, height: height, memeStatus: memeState);
}

class _FlexSpaceState extends State<FlexSpace> {
  CachedNetworkImageProvider tabImage;
  CachedNetworkImageProvider image1;
  CachedNetworkImageProvider image2;
  CachedNetworkImageProvider image3;
  double height;
  ValueNotifier memeStatus;
  FlutterSecureStorage storage = FlutterSecureStorage();
  TabController tabController;
  String photo1 =
      'https://img00.deviantart.net/35f0/i/2015/018/2/6/low_poly_landscape__the_river_cut_by_bv_designs-d8eib00.jpg';
  String photo2 =
      'https://images.pexels.com/photos/396547/pexels-photo-396547.jpeg?auto=compress&cs=tinysrgb&h=350';
  String photo3 =
      'http://techblogcorner.com/wp-content/uploads/2014/09/jpeg.jpg';
  _FlexSpaceState({this.tabController, this.height, this.memeStatus}) {
  }

  @override
  void initState() {
    memeStatus.addListener(() async {
      String st = await storage.read(key: 'memes');
      if (st == '1') {
        setState(() {
          height = 200.0;
        });
      } else {
        setState(() {
          height = 0.0;
        });
      }
    });
    tabController.addListener(() {
      setState(() {
        photoChanger();
      });
    });
    //String photo3='http://techblogcorner.com/wp-content/uploads/2014/09/jpeg.jpg';

    // TODO: implement initState
    super.initState();
    image1 = new CachedNetworkImageProvider(photo1);
    image2 = new CachedNetworkImageProvider(photo2);
    image3 = new CachedNetworkImageProvider(photo3);
    tabImage = image2;
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
          child:
              (tabImage != null) ? new Image(image: tabImage) : new Container(),
        ),
      ),
    );

    //add Image here
  }

  photoChanger() {
    setState(() {
      if (tabController.index == 3) {
        tabImage = image2;
      } else if (tabController.index == 4) {
        tabImage = image3;
      } else if (tabController.index == 2) {
        tabImage = image1;
      }
    });
  }
}

class Switcher extends StatefulWidget {
  bool val;
  ValueNotifier memeState;
  Switcher({this.val, this.memeState});

  @override
  _SwitcherState createState() =>
      _SwitcherState(val: val, memeState: memeState);
}

class _SwitcherState extends State<Switcher> {
  bool val;
  ValueNotifier memeState;
  FlutterSecureStorage storage = new FlutterSecureStorage();
  _SwitcherState({this.val, this.memeState});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
        future: storage.read(key: 'memes'),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            bool isMemesEnabled = (snapshot.data == '1') ? true : false;

            return Switch (
              onChanged: (a) => updateMemeState(a),
              value: isMemesEnabled,
            );

          } else {
            return new Container();
          }
        });
  }

  Future<bool> updateMemeState(bool a) async {
    await storage.write(key: 'memes', value: (a) ? '1' : '0');
    memeState.value += 1;
    setState(() {
      val = a;
    });
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
