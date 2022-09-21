import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter_frontend/main.dart';
import 'common.dart';
import 'dart:math' as math;

class Meteor extends StatefulWidget {
  Meteor({Key? key}) : super(key: key);

  @override
  _MeteorState createState() => _MeteorState();
}

class _MeteorState extends State<Meteor> with Message, Pattern {
  Color color =
      Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  int tick_rate = 100;
  int decay = 128;
  int size = 16;
  bool random_decay = true;

  void changeTickRate(int newTickRate) {
    setState(() {
      tick_rate = newTickRate;
    });
  }

  void changeDecay(int newDecay) {
    setState(() {
      decay = newDecay;
    });
  }

  void changeSize(int newSize) {
    setState(() {
      size = newSize;
    });
  }

  void changeRandomDecay(bool newRandomDecay) {
    setState(() {
      random_decay = newRandomDecay;
    });
  }

  void changeColor(Color newColor) {
    setState(() {
      color = newColor;
    });
  }

  Map<String, dynamic> getData() {
    return {
      "pattern": "meteor",
      "tick_rate": (1000 / tick_rate).floor(),
      "color": [color.blue, color.green, color.red, 0],
      "random_decay": random_decay,
      "decay": decay,
      "size": size
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: PatternDrawer(),
      appBar: AppBar(
        title: Text("Raspberry PI LED - Meteor"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
          child: Column(children: [
        ListTile(
          title: Text("Meteor Color"),
          trailing: ColorIndicator(
              borderRadius: 0,
              color: color,
              elevation: 1,
              onSelectFocus: false,
              onSelect: () async {
                // Wait for the dialog to return color selection result.
                final Color newColor = await showColorPickerDialog(
                  // The dialog needs a context, we pass it in.
                  context,
                  // We use the dialogSelectColor, as its starting color.
                  color,
                  title: Text('ColorPicker',
                      style: Theme.of(context).textTheme.headline6),
                  spacing: 0,
                  runSpacing: 0,
                  borderRadius: 0,
                  wheelDiameter: 165,
                  enableOpacity: false,
                  showColorCode: true,
                  colorCodeHasColor: true,
                  pickersEnabled: <ColorPickerType, bool>{
                    ColorPickerType.primary: true,
                    ColorPickerType.wheel: true
                  },
                  copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                    copyButton: true,
                    pasteButton: true,
                    longPressMenu: true,
                  ),
                  actionButtons: const ColorPickerActionButtons(
                    okButton: true,
                    closeButton: true,
                    dialogActionButtons: true,
                  ),
                  constraints: const BoxConstraints(
                      minHeight: 480, minWidth: 320, maxWidth: 320),
                );
                setState(() {
                  color = newColor;
                });
              }),
        ),
        ListTile(
          title: Text("Tick Rate"),
          subtitle: Slider(
            onChanged: (tr) => changeTickRate(tr.toInt()),
            value: tick_rate.toDouble(),
            min: 1,
            max: 255,
          ),
          trailing: Padding(
              padding: const EdgeInsets.only(right: 12),
              child:
                  Column(children: [
                    Text(tick_rate.toString()), 
                    Text("TPS")])),
        ),
        ListTile(
          title: Text("Decay"),
          subtitle: Slider(
            onChanged: (tr) => changeDecay(tr.toInt()),
            value: decay.toDouble(),
            min: 1,
            max: 255,
          ),
          trailing: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                children: [Text(decay.toString()), Text("255")],
              )),
        ),
        ListTile(
          title: Text("Meteor Size"),
          subtitle: Slider(
            onChanged: (tr) => changeSize(tr.toInt()),
            value: size.toDouble(),
            min: 1,
            max: 255,
          ),
          trailing: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [Text(size.toString()), Text("PXL")])),
        ),
        SwitchListTile(
            title: Text("Random Decay"),
            value: random_decay,
            onChanged: changeRandomDecay),
      ])),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () async {
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
        },
      ),
    );
  }
}
