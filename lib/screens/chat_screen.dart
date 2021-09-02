import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;

User?  loggedInUser;
Map<String, dynamic> data = {};

int? messageTimeHour;
int? messageTimeMinute;

class ChatScreen extends StatefulWidget {

  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final textEditingController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String? messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();

  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      loggedInUser = user;
    }catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      textEditingController.clear();
                      //Implement send functionality.
                      _firestore.collection("messages").add({
                        'text' : messageText,
                        'sender' : loggedInUser!.email,
                        'date' : DateTime.now(),
                      });
                      setState(() {
                        messageTimeHour = DateTime.now().hour;
                        messageTimeMinute = DateTime.now().minute;
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').orderBy("date", descending: false).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }
        if(!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final currentUser = loggedInUser!.email;

        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: snapshot.data!.docs.reversed.map((DocumentSnapshot document) {
              data = document.data()! as Map<String, dynamic>;
              return MessageBubble(
                sender: data['sender'],
                text: data['text'],
                isMe: currentUser == data['sender'],
              );
            }).toList(),
          ),
        );
        // }
      },
    );
  }
}


class MessageBubble extends StatelessWidget {

  MessageBubble({this.sender, this.text, this.isMe});

  final String? sender;
  final String? text;
  final bool? isMe;

  String? getMessageTime() {
    if(messageTimeHour! >= 13) {
      return '$messageTimeHour:$messageTimeMinute PM';
    }else {
      return '$messageTimeHour:$messageTimeMinute AM';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children : [
          Text(sender!,style: TextStyle(fontSize: 12.0, color: Colors.black54),),
          Material(
            borderRadius: isMe!
                ? BorderRadius.only(
                topLeft: Radius.circular(30.0), 
                bottomLeft: Radius.circular(30.0), 
                bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
                topRight: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)),
            elevation: 5.0,
            color: isMe! ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal:20.0 , vertical: 10.0),
              child: Text(
                text!,
                style: TextStyle(
                  color: isMe! ? Colors.white : Colors.black,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal:10.0 , vertical: 5.0),
            child: Text('${getMessageTime()!}', style: TextStyle(fontSize: 12.0, color: Colors.black54),),
          ),
        ],
      ),
    );
  }
}

//Text('${getMessageTime()}', style: TextStyle(fontSize: 10.0),),
// messageTimeHour! >= 13 ? print('$messageTimeHour:$messageTimeMinute PM') : print('$messageTimeHour:$messageTimeMinute AM')