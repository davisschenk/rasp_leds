import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/main.dart';
import 'common.dart';
import 'dart:math' as math;

class Solid extends StatefulWidget {
  Solid({Key? key}) : super(key: key);

  @override
  _SolidState createState() => _SolidState();
}

Function save_callback = () {};

class _SolidState extends State<Solid> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          drawer: PatternDrawer(),
          appBar: AppBar(
            title: Text("Raspberry PI LED - Solid"),
            bottom: TabBar(
              tabs: [Icon(Icons.crop_square), Icon(Icons.line_style)],
            ),
          ),
          body: TabBarView(
            children: [SolidPattern(), AlternatingPattern()],
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: () => save_callback(), child: Icon(Icons.save)),
        ));
  }
}

class SolidPattern extends StatefulWidget {
  SolidPattern({Key? key}) : super(key: key);

  @override
  _SolidPatternState createState() => _SolidPatternState();
}

class _SolidPatternState extends State<SolidPattern> with Message, Pattern {
  Color color =
      Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);

  void changeColor(Color newColor) {
    setState(() {
      color = newColor;
    });
  }

  Map<String, dynamic> getData() {
    return {
      "pattern": "solid",
      "color": [color.blue, color.green, color.red, 0],
    };
  }

  @override
  Widget build(BuildContext context) {
    save_callback = () => sendMessage(SERVER_URL).then((resp) => {
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
    return Center(
        child: Column(children: [
      ListTile(
        title: Text("Primary Color"),
        trailing: ColorIndicator(
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
                  dialogActionButtons: false,
                ),
                constraints: const BoxConstraints(
                    minHeight: 480, minWidth: 320, maxWidth: 320),
              );
              setState(() {
                color = newColor;
              });
            }),
      ),
    ]));
  }
}

class AlternatingPattern extends StatefulWidget {
  AlternatingPattern({Key? key}) : super(key: key);

  @override
  _AlternatingPatternState createState() => _AlternatingPatternState();
}

class AlterColor {
  int count;
  Color color;

  AlterColor({required this.count, required this.color});

  Map<String, dynamic> toJson() {
    return {
      "count": count,
      "color": [color.blue, color.green, color.red, 0],
    };
  }
}

class _AlternatingPatternState extends State<AlternatingPattern>
    with Message, Pattern {
  List<AlterColor> colors = [];
  List<TextEditingController> controllers = [];

  Map<String, dynamic> getData() {
    return {
      "pattern": "alternating",
      "colors": colors.map((element) => element.toJson()).toList()
    };
  }

  @override
  void dispose() {
    controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    save_callback = () => sendMessage(SERVER_URL).then((resp) => {
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

    return Column(mainAxisSize: MainAxisSize.max, children: [
      ListTile(
        title: Text("Add new color"),
        leading: Icon(Icons.add),
        onTap: () {
          setState(() {
            colors.add(AlterColor(
                color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
                    .withOpacity(1.0),
                count: 1));
            controllers.add(TextEditingController(text: "1"));
          });
        },
      ),
      Expanded(
        child: ListView.builder(
          itemCount: colors.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              key: Key('$index'),
              title: TextField(
                controller: controllers[index],
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (String newText) {
                  setState(() {
                    colors[index].count = int.parse(newText);
                  });
                },
              ),
              leading: ColorIndicator(
                  width: 40,
                  height: 40,
                  borderRadius: 0,
                  color: colors[index].color,
                  elevation: 1,
                  onSelectFocus: false,
                  onSelect: () async {
                    // Wait for the dialog to return color selection result.
                    final Color newColor = await showColorPickerDialog(
                      // The dialog needs a context, we pass it in.
                      context,
                      // We use the dialogSelectColor, as its starting color.
                      colors[index].color,
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
                        dialogActionButtons: false,
                      ),
                      constraints: const BoxConstraints(
                          minHeight: 480, minWidth: 320, maxWidth: 320),
                    );
                    setState(() {
                      colors[index].color = newColor;
                    });
                  }),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    colors.removeAt(index);
                    controllers.removeAt(index);
                  });
                },
              ),
            );
          },
        ),
      ),
    ]);
  }
}
