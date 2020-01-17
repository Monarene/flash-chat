import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

Firestore _firestore = Firestore.instance;
FirebaseUser loggedin;

class ChatScreen extends StatefulWidget {
  static const String id = "chat_screen";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String messageText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedin = user;
      }
    } catch (e) {
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
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(firestore: _firestore),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageController.clear();
                      //Implement send functionality.
                      _firestore
                          .collection('messages')
                          .add({'text': messageText, 'sender': loggedin.email});
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
  const MessageStream({
    Key key,
    @required Firestore firestore,
  })  : _firestore = firestore,
        super(key: key);

  final Firestore _firestore;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        final messages = snapshot.data.documents.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.data["text"];
          final messageSender = message.data['sender'];

          final currentuser = loggedin.email;

          if (currentuser == messageSender) {
            // the message from the loggedin user

          }

          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentuser == messageSender,
          );

          messageBubbles.add(messageBubble);
        }

        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.text, this.sender, this.isMe});

  final String text;
  final String sender;
  bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe == true ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "$sender",
            style: TextStyle(fontSize: 12.0, color: Colors.black54),
          ),
          Material(
            borderRadius: isMe == true
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)),
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Text(
                '$text',
                style: TextStyle(
                    color: isMe == true ? Colors.white : Colors.black54,
                    fontSize: 15),
              ),
            ),
            color: isMe == true ? Colors.lightBlueAccent : Colors.white,
          ),
        ],
      ),
    );
  }
}
