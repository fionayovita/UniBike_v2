import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unibike/ui/login_page.dart';
import 'package:unibike/ui/main_page.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash_screen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..forward();

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/unila.png'), fit: BoxFit.cover),
              ),
            ),
            Container(
              decoration: BoxDecoration(color: Color(0xB3191720)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    'assets/logo_text_new.png',
                    width: 300,
                    // height: 00,
                  ),
                ),
                Text('Your campus travel buddy')
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    String routeName() {
      String name;
      FirebaseAuth.instance.currentUser == null
          ? name = LoginPage.routeName
          : name = MainPage.routeName;
      return name;
    }

    Timer(
        Duration(seconds: 5),
        () => Navigator.pushNamedAndRemoveUntil(
              context,
              routeName(),
              (route) => false,
            ));
  }
}
