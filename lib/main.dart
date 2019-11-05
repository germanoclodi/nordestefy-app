import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:dart_amqp/dart_amqp.dart';

void main() => runApp(MainPage());

class MainPage extends StatefulWidget {
  @override
  MyApp createState()=> MyApp();
}

class MyApp extends State<MainPage> {

  Location location = Location();
  Map<String, double> userLocation;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        body: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            userLocation == null
                ? CircularProgressIndicator()
                : Text("Localização: " +
                    userLocation["latitude"].toString() +
                    " " +
                    userLocation["longitude"].toString()),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                disabledColor: Colors.grey,
                disabledTextColor: Colors.black,
                padding: EdgeInsets.all(8.0),
                splashColor: Colors.redAccent,
                onPressed: () {
                  _getLocation().then((value) {
                    setState(() {
                      userLocation = value;
                    });
                  });
                  _getLocation().then((value) {
                    setState(() {
                      userLocation = value;
                    });
                  });
                  
                  String message_payload = "";
                  var now = new DateTime.now().toIso8601String();
                  now = now.substring(0, now.length - 7);
                  message_payload = userLocation['latitude'].toString() + "|||" + userLocation['longitude'].toString() + "|||" + now;

                  ConnectionSettings settings = new ConnectionSettings(
                    host: "prawn.rmq.cloudamqp.com",
                    authProvider: new PlainAuthenticator("yibeuqjs", "K_HEZUkbNeFcsrLJbC5XWgpglEUkx0-V"),
                    virtualHost: "yibeuqjs"
                  );

                  Client client = new Client(settings: settings);
                  client
                  .channel()
                  .then((Channel channel) => channel.queue("nordestefy"))
                  .then((Queue queue) {
                    queue.publish(message_payload);
                    return client.close();
                  });

                  print("Enviado: " + message_payload);

                },
                child: Text(
                  "Encontrada mancha de óleo!",
                  style: TextStyle(fontSize: 20.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  Future<Map<String, double>> _getLocation() async {
    var currentLocation = <String, double>{};
    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

}