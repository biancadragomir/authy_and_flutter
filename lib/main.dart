import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'User.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authy & Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Authy & Flutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _tokenInputController = TextEditingController();
  final _emailInputController = TextEditingController();
  final _phoneNumberInputController = TextEditingController();

  bool _wasTokenSent = false;

  Future<TwilioNewUserResponse> _createTwilioUser() async {
    // Create the Twilio user
    final userToSend = User(
        _emailInputController.text, _phoneNumberInputController.text, '+4');
    final http.Response response = await http.post(
      'https://api.authy.com/protected/json/users/new',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Authy-API-Key': 'TODO-ADD-AUTHY-API-KEY',
      },
      body: jsonEncode(<String, dynamic>{'user': userToSend.toJson()}),
    );

    if (response.statusCode == 200) {
      return TwilioNewUserResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create Twilio user!');
    }
  }

  int userId;

  void _sendSms() async {
    _createTwilioUser().then((createdUser) async {
      final http.Response response = await http.get(
          'https://api.authy.com/protected/json/sms/${createdUser.user.id}',
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'X-Authy-API-Key': 'TODO-ADD-AUTHY-API-KEY',
          });
      if (response.statusCode == 200) {
        print("_sendSms: $response");
        userId = createdUser.user.id;
      } else {
        throw Exception('Failed to create Twilio user!');
      }
    });
  }

  void _verifyToken() async {
    final http.Response response = await http.get(
        'https://api.authy.com/protected/json/verify/${_tokenInputController.text}/$userId',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'X-Authy-API-Key': 'TODO-ADD-AUTHY-API-KEY',
        });
    if (response.statusCode == 200) {
      print('Success verifying token!');
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text('Success verifying token!')));
    } else {
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text('The token is incorrect')));
      throw Exception('The token is incorrect.');
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _tokenInputController.dispose();
    _emailInputController.dispose();
    _phoneNumberInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
            margin: EdgeInsets.only(left: 32.0, right: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                    'First send yourself an SMS, then click the OK button to verify the received token.'),
                TextField(
                  controller: _emailInputController,
                  decoration:
                      InputDecoration(hintText: 'something@something.com'),
                ),
                TextField(
                  controller: _phoneNumberInputController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: '07xxxxxxxx'),
                ),
                RaisedButton(
                    child: Text('Send SMS'),
                    onPressed: () {
                      _sendSms();
                      _wasTokenSent = true;
                    }),
                TextField(
                  controller: _tokenInputController,
                  decoration: InputDecoration(hintText: 'Enter your token'),
                ),
                RaisedButton(
                  child: Text('OK'),
                  onPressed: () {
                    if (_wasTokenSent)
                      _verifyToken();
                    else {
                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                          content: Text('Send yourself the SMS first!')));
                      return null;
                    }
                  },
                )
              ],
            )),
      ),
    );
  }
}
