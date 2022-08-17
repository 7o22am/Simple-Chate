
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:simple_chat/screens/welcome_screen.dart';
import 'package:intl/intl.dart';
import '../constants.dart';

final _firestore = FirebaseFirestore.instance;
final user = FirebaseAuth.instance.currentUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  void tost(String wrong) {
    Fluttertoast.showToast(
        msg: wrong,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  final messageTextControllar = TextEditingController();

  String userlogin = 'null';
  String messagetext = 'null';

  final _auth = FirebaseAuth.instance;


  void getuser() async {
    final user = await FirebaseAuth.instance.currentUser;

  }

  void initState() {
    super.initState();
    getuser();
  }

 // void getMessagesStream() async {
   // await for (var snapshot in _firestore.collection('messages').snapshots())
   //   for (var massage in snapshot.docs) {
   //     print(massage.data());
    //  }
  //}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () async {
             await FirebaseAuth.instance.signOut();

                tost('Signed Out ..');
                Navigator.pushNamed(context, WelcomeScreen.id);
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
            MessagesStrame(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextControllar,
                      onChanged: (value) {
                        messagetext = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextControllar.clear();
                      final user2 = FirebaseAuth.instance.currentUser;
                      DateTime current_date = DateTime.now();
                      _firestore
                          .collection('messages').doc('$current_date')
                          .set({'text': messagetext, 'sender': user2?.email});
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

class Messagebubble extends StatelessWidget {
  Messagebubble({required this.sender, required this.text , required this.isme});
  final String sender;
  final String text;
   bool isme = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:isme? CrossAxisAlignment.end :CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(fontSize: 15.0, color: Colors.black54),
          ),
          Material(
            elevation: 5.0,
            borderRadius:isme ? BorderRadius.only(
                topLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0)) :
            BorderRadius.only(
                topRight: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0))
            ,
            color:isme ?  Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text('$text',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: isme ?Colors.white :Colors.black54
                  )),
            ),
          ),
        ],
      ),
    );
    ;
  }
}

class MessagesStrame extends StatelessWidget {
  const MessagesStrame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.blue,
            ),
          );
        }
        final messages = snapshot.data?.docs.reversed ;
        List<Messagebubble> messagebubbles = [];
        for (var message in messages!) {
          final messagetext = message.get('text');
          final messagesender = message.get('sender');
          final user2 = FirebaseAuth.instance.currentUser;
       final currentuser = user2?.email;

          final messagebubble =
              Messagebubble(sender: messagesender, text: messagetext ,
              isme: currentuser == messagesender,);
               messagebubbles.add(messagebubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messagebubbles,
          ),
        );
      },
    );
  }
}
