import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timetable_notifier/functions.dart';
import 'Login.dart';
import 'dart:convert';
import "package:http/http.dart" as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'friendFinder.dart';
import 'package:observable/observable.dart';

//Globals Variables
class app extends StatelessWidget {
  String memes;
  app({this.memes});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: app1(memes: memes,),);
  }
}

class app1 extends StatefulWidget {
  String memes;
  app1({this.memes});
  @override
  _appState createState() => _appState(memes: memes);
}

class _appState extends State<app1>with SingleTickerProviderStateMixin {
  String memes;
  _appState({this.memes});
  ObservableList observableList=new ObservableList(2);
  ValueNotifier memeState;
  bool SwitchVal;
  bool handleSwitch=true;
  String currTable='timetable';
  var timeTable;
  BuildContext context1;
  TabController _tabController;
  //DrawerController drawerController = new DrawerController(child: null, alignment: null)
  String photo1='https://img00.deviantart.net/35f0/i/2015/018/2/6/low_poly_landscape__the_river_cut_by_bv_designs-d8eib00.jpg';
  String photo2='https://images.pexels.com/photos/396547/pexels-photo-396547.jpeg?auto=compress&cs=tinysrgb&h=350';
  String photo3='http://techblogcorner.com/wp-content/uploads/2014/09/jpeg.jpg';
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  FlutterSecureStorage storage=FlutterSecureStorage();
  func( String st)
  {
    if(st=='1')
      {
        SwitchVal=true;

      }
      else
        {
          SwitchVal=false;
        }
  }
  @override
  void initState() {

    memeState=ValueNotifier(0);
    // TODO: implement initState
    super.initState();
    print('heelo');
    if(memes=='1'&& handleSwitch==true)
    {
      SwitchVal=true;
      handleSwitch=false;
    }
    else if(handleSwitch==true)
    {
      SwitchVal=false;
      handleSwitch=false;
    }
    _tabController = new TabController(vsync: this, length: 5);
    _tabController.addListener((){
      print("in controller");
      // photoChanger();
    });

  }

  setter()
  {
    print('setting');
    setState(() {
    });
  }
  remove(){
    storage.delete(key: 'status');
    Navigator.of(context).pushReplacement(
        new MaterialPageRoute(builder: (BuildContext context) => new Login()
        ));

  }
  myTimeTable()
  {
    Navigator.pop(context);
    if (currTable != 'timetable') {
      setState(() {
        currTable='timetable';
      });
    }
  }

  friends(BuildContext context)
  async {
    Navigator.of(context).pop();

    var val=await  Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => new freindFinder()));
    print('valis $val');
    if(val ==null)
    {
      print('eeer');
    }
    else
    {
      print('setting new state');
      setState(() {
        currTable=val;
      });
    }
  }

  fetch()
  async {
    String email=timeTable['email'].toString();
    final response = await http.get(
        "https://tt.saadismail.net/api/fetch.php?email=%22$email%22");
    var responseJson = json.decode(response.body.toString());
    print('saad   ${response.body.toString()}');
    await storage.write(key: "timetable", value: response.body.toString());
    setState(() {
      //
      timeTable=responseJson;
    });
    Navigator.of(context).pop();

  }
  @override
  Widget build(BuildContext context) {
    print('memes  $memes');
    context1=context;
    return Scaffold(
      drawer: new Drawer(
        child:new FutureBuilder(
            future: storage.read(key: 'timetable'),
            builder:(context,AsyncSnapshot<String>snapshot){
              if(snapshot.connectionState==ConnectionState.done)
              {

                  print("switch is $memes");
                var a=json.decode(snapshot.data);
                return new Column(
                  children: <Widget>[
                    new UserAccountsDrawerHeader(
                      accountEmail: new Text(a['name'].toString()),
                      accountName: new Text(a['email'].toString()),
                      decoration: new BoxDecoration(
                          image: new DecorationImage(
                              image: CachedNetworkImageProvider( "https://img00.deviantart.net/35f0/i/2015/018/2/6/low_poly_landscape__the_river_cut_by_bv_designs-d8eib00.jpg"),
                              fit: BoxFit.fill
                          )
                      ),
                    ),
                    //  new ListTile(title:new Text("Register"),onTap: ()=>register(),),
                    //new Divider(),
                    new ListTile(title:new Text("My Time Table"),onTap: ()=>myTimeTable(),),
                    new Divider(color: Colors.lightBlue,),
                    new ListTile(title:new Text("Friends"),onTap: ()=>friends(context),),
                    new Divider(color: Colors.lightBlue,),
                    new ListTile(title:new Text("Remove"),onTap: ()=>remove(),),
                    new Divider(color: Colors.lightBlue,),
                    new ListTile(title:new Text("Fetch"),onTap:()=>fetch()),
                    new Divider(color: Colors.lightBlue,),
                    new ListTile(title:new Text("Memes"),onTap:null,trailing: new Switcher(memeState: memeState,val: SwitchVal,),)
                  ],
                );



              }
              else
              {
                return new Container();
              }

            }
        ),
      ),
      body:  NestedScrollView(

        headerSliverBuilder:
            (BuildContext context, bool innerBoxIsScrolled) {
          print("memesval $memes");
          return <Widget>[
            (memes=='1')?FlexSpace(tabController: _tabController,memeState: memeState,hieght: 200.0,):FlexSpace(tabController: _tabController,memeState: memeState,hieght: 0.0,),
            SliverPersistentHeader(

              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.lime,

                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab( text: "Mon"),
                    Tab( text: "Tue"),
                    Tab(text: "Wed"),
                    Tab( text: "Thurs"),
                    Tab(text: "Fri"),
                  ],
                ),
              ),
              pinned: true,
              floating: false,
            ),
          ];
        },
        body: new FutureBuilder(
            future:storage.read(key: currTable),
            builder:(context,AsyncSnapshot<String>snapshot){

              if(snapshot.connectionState==ConnectionState.done)
              {

                var a=json.decode(snapshot.data);
                timeTable=a;
                // print('saad2');
                //print(a);
                return new TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    Carder(day:timeTable["0"],),
                    Carder(day: timeTable['1'],),
                    Carder(day: timeTable['2'],),
                    Carder(day:timeTable['3'],),
                    Carder(day: timeTable['4'],),


                  ],
                );
              }
              else
              {
                return new Container();
              }

            }
        ),
      ),
    );


  }

  int getWeekDay()
  {
    if(DateTime.now().weekday==6||DateTime.now().weekday==7)
      return 0;
    else
      return DateTime.now().weekday-1;
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
      child: Material(color:Colors.black,child: _tabBar),
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
  void initState() {
    // TODO: implement initState
    super.initState();

    _scrollController.addListener(()=>scrollToView());
  }

  scrollToView()
  {
    print('scroller');
    print(_scrollController.position);
  }

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      itemCount: (day == null) ? 0 : day.length,
      itemBuilder: (context,index){
        return new Card(
          color: new Color(hexToInt("FF" + day[index]['color'])),
          child:new Column(
            children: <Widget>[
              new Row(
                children: <Widget>[
                  new Text(day[index]['subject'],style: TextStyle(fontSize: 24.0),)
                ],
              ),
              new Row(
                children: <Widget>[
                  (day[index]['room']!=null)? new Text(day[index]['room'],style: TextStyle(fontSize: 24.0),):new Container(),
                  (day[index]['timing']!=null)?new Text(day[index]['timing'],style: TextStyle(fontSize: 24.0),):new Container(),
                ],
              )
            ],
          ) ,
        ) ;
      },
    );
  }

}
class FlexSpace extends StatefulWidget {
  TabController tabController;
  String status;
  var memeState;

  FlexSpace({this.tabController,this.hieght,this.memeState});
  double hieght;
  //_FlexSpaceState flex=new _FlexSpaceState(tabController: tabController,hieght: hieght,status:status);
  @override
  _FlexSpaceState createState() => _FlexSpaceState(tabController: tabController,hieght: hieght,memeStatus: memeState);
}

class _FlexSpaceState extends State<FlexSpace> {

  CachedNetworkImageProvider tabImage;
  CachedNetworkImageProvider image1;
  CachedNetworkImageProvider image2;
  CachedNetworkImageProvider image3;
  double hieght;
  String status;
  ValueNotifier memeStatus;
  FlutterSecureStorage storage=FlutterSecureStorage();
  TabController tabController;
  String photo1='https://img00.deviantart.net/35f0/i/2015/018/2/6/low_poly_landscape__the_river_cut_by_bv_designs-d8eib00.jpg';
  String photo2='https://images.pexels.com/photos/396547/pexels-photo-396547.jpeg?auto=compress&cs=tinysrgb&h=350';
  String photo3='http://techblogcorner.com/wp-content/uploads/2014/09/jpeg.jpg';
  _FlexSpaceState({this.tabController,this.hieght,this.memeStatus}){
    print('STatus');
  }

  @override
  void initState() {
    memeStatus.addListener(()async{
      print('toggling');
      String st=await storage.read(key: 'memes');
      print('value for st $st');
      if(st=='1')
      {
        setState(() {
          hieght=200.0;
        });
      }
      else{
        setState(() {
          hieght=0.0;
        });
      }
    });
    tabController.addListener((){


      setState(() {
        photoChanger();
      });
    });
    //String photo3='http://techblogcorner.com/wp-content/uploads/2014/09/jpeg.jpg';

    // TODO: implement initState
    super.initState();
    image1= new CachedNetworkImageProvider(photo1) ;
    image2=new CachedNetworkImageProvider(photo2);
    image3=new CachedNetworkImageProvider(photo3);
    tabImage=image2;
  }
  @override
  Widget build(BuildContext context) {
    print("height is $hieght");
    return SliverAppBar(
      title: new Text("Time Table"),
      expandedHeight: hieght,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: new FittedBox(
          fit: BoxFit.cover,
          child: (tabImage!=null)?new Image(image: tabImage):new Container(),
        ),
      ),
    );


    //add Image here
  }
  photoChanger()
  {
    print("changing photoindex is");
    print(tabController.index);
    setState(() {
      if(tabController.index==3)
      {
        tabImage=image2;
      }
      else if(tabController.index==4)
      {
        tabImage=image3;

      }
      else if(tabController.index==2)
      {
        tabImage=image1;

      }
    });
  }
}

class Switcher extends StatefulWidget {
  bool val;
  ValueNotifier memeState;
  Switcher({this.val,this.memeState});

  @override
  _SwitcherState createState() => _SwitcherState(val:val,memeState:memeState);
}

class _SwitcherState extends State<Switcher> {
  bool val;
  ValueNotifier memeState;
  String st='';
  FlutterSecureStorage storage= new FlutterSecureStorage();

  _SwitcherState({this.val,this.memeState});
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("shala lak");
    print(st);

  }
  @override
  Widget build(BuildContext context) {
    print('val is $val');
    return new FutureBuilder(
        future: storage.read(key: 'memes'),
        builder: (context ,AsyncSnapshot<String>snapshot)
    {
      if(snapshot.connectionState==ConnectionState.done)
        {

          if(snapshot.data=='1')
            {
              return Switch(onChanged:(a)=> memesf(a),value: true,);
            }
            else
              {
                return Switch(onChanged:(a)=> memesf(a),value: false,);

              }
        }
      else
      {
        return new Container();
      }


    });
  }
  Future<bool> memesf(bool a)

  async {
    String val1;
    print('inFunc $a');
    if(a==true)
    {
      val1='1';
      await storage.write(key: 'memes', value: val1);
     st= await storage.read(key: 'memes');
      //memeState.value('0');
      memeState.value+=1;
      setState(() {
        print('changing');
        val=a;
      });

      //  memeState.notifyListeners();
    }
    else
    {
      val1='0';
      await storage.write(key: 'memes', value: val1);
      //memeState.value('1');
      memeState.value+=1;
      //  memeState.notifyListeners();
      setState(() {
        print('changing1');

        val=a;
      });

    }

  }

}