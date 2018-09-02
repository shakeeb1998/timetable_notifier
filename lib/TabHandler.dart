import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'Login.dart';
import 'dart:convert';
import "package:http/http.dart" as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'freindFinder.dart';

//Globals Variables

class app extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: app1(),);
  }
}

class app1 extends StatefulWidget {
  @override
  _appState createState() => _appState();
}

class _appState extends State<app1>with SingleTickerProviderStateMixin {
  CachedNetworkImageProvider tabImage;
  CachedNetworkImageProvider image1;
  CachedNetworkImageProvider image2;
  CachedNetworkImageProvider image3;
  String CurrentTimeTable="Mine";
  String name='';
  String email='';
  String rollNo;
  String name1='';
  String email1='';
  String currTable='timetable';
  String freindsTable='';
  var timeTable;
  BuildContext context1;
  TabController _tabController;
  String photo1='https://img00.deviantart.net/35f0/i/2015/018/2/6/low_poly_landscape__the_river_cut_by_bv_designs-d8eib00.jpg';
  String photo2='https://images.pexels.com/photos/396547/pexels-photo-396547.jpeg?auto=compress&cs=tinysrgb&h=350';

  String photo3='http://techblogcorner.com/wp-content/uploads/2014/09/jpeg.jpg';
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  FlutterSecureStorage storage=FlutterSecureStorage();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _tabController = new TabController(vsync: this, length: 5);
    _tabController.addListener((){
      print("in controller");
      photoChanger();
    });

  }
  photoChanger()
  {
    print("changing photoindex is");
    print(_tabController.index);
    setState(() {
      if(_tabController.index==3)
        {
          tabImage=image2;
        }
        else if(_tabController.index==4)
          {
            tabImage=image3;

          }
          else if(_tabController.index==2)
            {
              tabImage=image1;

            }
    });
  }
  setter()
  {
    print('setting');
    print(name1);
    print(name);
    setState(() {
      name=name1;
      email=email1;
    });
  }
  remove(){
    storage.delete(key: 'status');
    Navigator.of(context).pushReplacement(
        new MaterialPageRoute(builder: (BuildContext context) => new Login()
        ));

  }
  register()
  {

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
    context1=context;
    return Scaffold(
      drawer: new Drawer(
        child:new FutureBuilder(
            future: storage.read(key: 'timetable'),
            builder:(context,AsyncSnapshot<String>snapshot){
              if(snapshot.connectionState==ConnectionState.done)
              {

             //   print(tabImage);
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
                    new ListTile(title:new Text("My Time Table"),onTap: null,),
                    new Divider(color: Colors.lightBlue,),
                    new ListTile(title:new Text("Friends"),onTap: ()=>friends(context),),
                    new Divider(color: Colors.lightBlue,),
                    new ListTile(title:new Text("Remove"),onTap: ()=>remove(),),
                    new Divider(color: Colors.lightBlue,),
                    new ListTile(title:new Text("Fetch"),onTap:()=>fetch())
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
              return <Widget>[
                SliverAppBar(
                  title: new Text("Time Table"),
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      /*title: Text("Timetable Notifier",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ))*/
                      background:new FittedBox(
                        fit: BoxFit.cover,
                        child: (tabImage!=null)?new Image(image: tabImage):new Container(),
                      )//add Image here
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
                  image1= new CachedNetworkImageProvider(photo1) ;
                  image2=new CachedNetworkImageProvider(photo2);
                  image3=new CachedNetworkImageProvider(photo3);

                  tabImage=image2;
                  if(snapshot.connectionState==ConnectionState.done)
                  {

                    var a=json.decode(snapshot.data);
                    timeTable=a;
                    print('saad2');
                    print(a);
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

    final textStyle = const TextStyle(fontSize: 20.0);
    final text = "DB-G Shoaib Rauf";
    return new ListView.builder(
      

              itemCount: (day == null) ? 0 : day.length,
              itemBuilder: (context,index){
                return new Card(
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
