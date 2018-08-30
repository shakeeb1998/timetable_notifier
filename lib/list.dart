import 'package:flutter/material.dart';

class List extends StatefulWidget {
  @override
  ListState createState() => ListState();
}

class ListState extends State<List>  {
  @override
  Widget build(BuildContext context) {
     return new Scaffold(
        body: new CustomScrollView(

          slivers: <Widget>[
            new SliverAppBar(
              expandedHeight: 150.0,
              floating: false,
              pinned: true,
              flexibleSpace: new FlexibleSpaceBar(
                title: new Text("Sliver App Bar"),
              ),
            ),
            new SliverList(

              delegate:
              new SliverChildBuilderDelegate((context, index) => new ListTile(
                title: new Text("List item $index"),
              ), childCount: 4),
            )
          ],


      ),


    );

  }
}
