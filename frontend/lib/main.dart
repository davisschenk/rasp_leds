import 'package:flutter/material.dart';
import 'package:flutter_frontend/patterns/meteor.dart';
import 'package:flutter_frontend/patterns/rainbow.dart';
import 'patterns/solid.dart';
import 'patterns/common.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider<PageController>(create: (_) => PageController(initialPage: 0))
      ],
      child: MaterialApp(
        title: 'Raspberry PI Leds',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: "Raspberry PI Leds"),
      ),
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
  
  @override
  Widget build(BuildContext context) {
    return Consumer<PageController>(
          builder: (BuildContext context, PageController c, _) => PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: c,
            onPageChanged: (p) => setState((){}),
            children: [Solid(), Meteor(), Rainbow()],
          ),
    );
  }
}

class PatternDrawer extends StatelessWidget {
  const PatternDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PageController>(
          builder: (BuildContext context, PageController p, _) => Drawer(
            child: ListView(
              children: [
                DrawerHeader(
                  decoration:
                      BoxDecoration(color: Theme.of(context).primaryColor),
                  child: Column(children: [
                    Text("LED Commands"),
                    Row(
                      children: [
                        ElevatedButton.icon(
                            label: Text("Power"),
                            onPressed: () {
                              Power()
                                  .sendMessage(SERVER_URL)
                                  .then((resp) => {
                                        if (resp.statusCode != 200)
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text(
                                                      "Error toggling on/off!"),
                                                  content: Text(resp.body),
                                                );
                                              })
                                      })
                                  .catchError((e) => print(e));
                            },
                            icon: Icon(Icons.power))
                      ],
                    )
                  ]),
                ),
                ExpansionTile(
                  title: Text("Patterns"),
                  children: [
                    ListTile(
                      title: Text("Solid"),
                      onTap: () {
                        p.jumpToPage(0);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: Text("Meteor"),
                      onTap: () {
                        p.jumpToPage(1);
                        Navigator.pop(context);
                      },
                    ),
                                        ListTile(
                      title: Text("Rainbow"),
                      onTap: () {
                        p.jumpToPage(2);
                        Navigator.pop(context);
                      },
                    )
                  ],
                )
              ],
            ),
          )
    );
  }
}