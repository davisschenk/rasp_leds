import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:http/http.dart' as http;

class Solid extends StatefulWidget {
  Solid({Key? key}) : super(key: key);

  @override
  _SolidState createState() => _SolidState();
}

class _SolidState extends State<Solid> {
  Color color = Color(0xff000000);

  void changeColor(Color newColor) {
    setState(() {
      color = newColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(children: [
      Row(children: [
        Text("Solid Color: "),
        ColorIndicator(
            width: 40,
            height: 40,
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
                width: 40,
                height: 40,
                spacing: 0,
                runSpacing: 0,
                borderRadius: 0,
                wheelDiameter: 165,
                enableOpacity: false,
                showColorCode: true,
                colorCodeHasColor: true,
                pickersEnabled: <ColorPickerType, bool>{
                  ColorPickerType.wheel: true,
                },
                copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                  copyButton: true,
                  pasteButton: true,
                  longPressMenu: true,
                ),
                actionButtons: const ColorPickerActionButtons(
                  okButton: true,
                  closeButton: true,
                  dialogActionButtons: false,
                ),
                constraints: const BoxConstraints(
                    minHeight: 480, minWidth: 320, maxWidth: 320),
              );
              setState(() {
                color = newColor;
              });
            }),
      ]),
      ElevatedButton(
          child: Text("Set Color"),
          onPressed: () async {
            var url = Uri.parse("http://192.168.0.6:8000/api/pattern");

            http
                .post(url, headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                }, body: ''' 
                      {
                        "type": "pattern",
                        "data": {
                          "pattern": "solid",
                          "color": [${color.blue}, ${color.green}, ${color.red}, 0]
                        }
                      }
                    ''')
                .then((resp) => {
                      if (resp.statusCode != 200)
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Error setting pattern!"),
                                content: Text(resp.body),
                              );
                            })
                    })
                .catchError((e) => print(e));
          })
    ]));
  }
}
