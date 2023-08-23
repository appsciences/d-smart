import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safe/flutter_icons_null_safe.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      theme: new ThemeData(scaffoldBackgroundColor: Colors.black),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _buttonBarHeight = 0;

  void _toggleButtonBar() {
    setState(() {
      _buttonBarHeight = _buttonBarHeight == 0 ? 100 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
            backgroundColor: Colors.black, // Set the background color to black
appBar: AppBar(
        title: Text('Drink Smart'),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'whatDidIDo') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WhatDidIDoScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'whatDidIDo',
                  child: Text('What did I do!'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          Container(
            color: Colors.white,
            child: Center(
              child: Text('Your main content here'),
            ),
          ),
          // Slide-up button bar
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            bottom: _buttonBarHeight,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.grey,
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ClipOval(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(15),
                      ),
                      child: Icon(MaterialCommunityIcons.beer),
                    ),
                  ),
                  ClipOval(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(15),
                      ),
                      child: Icon(MaterialCommunityIcons.glass_wine),
                    ),
                  ),
                  ClipOval(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(15),
                      ),
                      child: const Icon(MaterialCommunityIcons.glass_cocktail),
                    ),
                  ),
                  ClipOval(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(15),
                      ),
                      child: Icon(MaterialCommunityIcons.water),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleButtonBar,
        child: Icon(Icons.keyboard_arrow_up),
      ),
    );
  }
}

class WhatDidIDoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('What Did I Do!'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      backgroundColor: Colors.black, // Set the background color to black
      
      body: Center(
        child: Text('This is the "What Did I Do!" screen'),
      ),
    );
  }
}
