import 'dart:convert';
import 'package:http/http.dart' as http;

var  SERVER_URL = Uri.parse("http://192.168.0.6:8000/api/pattern");

mixin Message {
  String get type;
  Map<String, dynamic> getData();
  Map<String, dynamic> toJson() {
    return {"type": this.type, "data": getData()};
  }

  Future<http.Response> sendMessage(Uri url) {
    var encoded_message = json.encode(this.toJson());
    var headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    return http.post(url, body: encoded_message, headers: headers);
  }
}

mixin Pattern on Message {
  String get type => "pattern";
}

class Power with Message {
  String get type => "power";
  String mode;

  Power({this.mode = "toggle"});

  Map<String, dynamic> getData() {
    return {
      "mode": this.mode
    };
  }
}
