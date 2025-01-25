import 'package:flutter/material.dart';

import '../controller/home_controller.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = HomeController();

  @override
  void initState() {
    super.initState();
    _controller.getLocation();
    _controller.getFCMToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_controller.userName != null && _controller.userEmail != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${_controller.userName}',
                        style: TextStyle(fontSize: 18)),
                    Text('Email: ${_controller.userEmail}',
                        style: TextStyle(fontSize: 18)),
                    Text('Location: ${_controller.currentAddress}',
                        style: TextStyle(fontSize: 18)),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await _controller.handleSignOut();
                        setState(() {});
                      },
                      child: Text('Sign Out'),
                    ),
                  ],
                ),
              )
            else
              ElevatedButton(
                onPressed: () async {
                  await _controller.handleSignIn();
                  setState(() {});
                },
                child: Text('Login with Google'),
              ),
          ],
        ),
      ),
    );
  }
}
