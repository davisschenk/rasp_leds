import 'package:flutter/material.dart';
import 'package:flutter_frontend/patterns/meteor.dart';
import 'patterns/solid.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raspberry PI Leds',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: "Raspberry PI Leds"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PageController _pageController = PageController(initialPage: 0);
  int _page = 0;

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                  decoration:
                      BoxDecoration(color: Theme.of(context).primaryColor),
                  child: Text("LED Commands")),
              ExpansionTile(
                title: Text("Patterns"),
                children: [
                  ListTile(
                    title: Text("Solid"),
                    onTap: () => navigationTapped(0),
                  ),
                  ListTile(
                    title: Text("Meteor"),
                    onTap: () => navigationTapped(1),
                  )
                ],
              )
            ],
          ),
        ),
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: onPageChanged,
          children: [Solid(), Meteor()],
        ));
  }
}
