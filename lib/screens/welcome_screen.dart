import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:friends_chat/components/rounded_button.dart';
import 'package:friends_chat/screens/registration_screen.dart';

import 'login_screen.dart';



class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {

  AnimationController? controller;
  Animation? animation;
  double? controllerValue;

  @override
  void initState() {
    super.initState();
      controller = AnimationController(
        duration: Duration(seconds: 1),
        vsync: this,
      );

      animation = ColorTween(begin: Colors.blueGrey, end: Colors.white).animate(controller!);

      controller!.forward();

      controller!.addListener(() {
        setState(() {});
        // print(animation!.value);
      });
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation!.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: 100.0,
                  ),
                ),
                DefaultTextStyle(
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText('Flash Chat'),
                    ],
                  ),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(colour: Colors.lightBlueAccent, title: 'Log In', onPressed: () => Navigator.pushNamed(context, LoginScreen.id),),
            RoundedButton(colour: Colors.blueAccent, title: 'Register', onPressed: () => Navigator.pushNamed(context, RegistrationScreen.id),),
          ],
        ),
      ),
    );
  }
}

