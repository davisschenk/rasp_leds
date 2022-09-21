import 'package:flutter/material.dart';
import 'package:flutter_frontend/patterns/common.dart';

import '../main.dart';

class Rainbow extends StatefulWidget {
  Rainbow({Key? key}) : super(key: key);

  @override
  _RainbowState createState() => _RainbowState();
}

Function callback = () {};

class _RainbowState extends State<Rainbow> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 1,
        child: Scaffold(
          drawer: PatternDrawer(),
          appBar: AppBar(
            title: Text("Raspberry PI LED - Rainbow"),
            bottom: TabBar(
              tabs: [Icon(Icons.repeat)],
            ),
          ),
          body: TabBarView(
            children: [RainbowCycle()],
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.save),
            onPressed: () {
              callback();
            },
          ),
        ));
  }
}

class RainbowCycle extends StatefulWidget {
  RainbowCycle({Key? key}) : super(key: key);

  @override
  _RainbowCycleState createState() => _RainbowCycleState();
}

class _RainbowCycleState extends State<RainbowCycle> with Message, Pattern {
  int tickRate = 0;

  Map<String, dynamic> getData() {
    return {"pattern": "rainbow_cycle", "tick_rate": tickRate};
  }

  @override
  Widget build(BuildContext context) {
    callback = () {
      sendMessage(SERVER_URL).then((resp) => {
            if (resp.statusCode != 200)
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Error setting pattern!"),
                      content: Text(resp.body),
                    );
                  })
          });
    };

    return Column(children: [
      ListTile(
        title: Text("Tick Rate"),
        subtitle: Slider(
          value: tickRate.toDouble(),
          onChanged: (double newTickRate) => setState(() {
            tickRate = newTickRate.toInt();
          }),
          min: 0,
          max: 255,
        ),
        trailing: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [Text(tickRate.toString()), Text("TPS")])),
      )
    ]);
  }
}
