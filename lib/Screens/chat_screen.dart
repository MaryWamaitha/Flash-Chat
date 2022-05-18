import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
final _firestore = FirebaseFirestore.instance;
User loggedInUser;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //create an instance of firebase auth that we will use out all through out the page
  final _auth = FirebaseAuth.instance;
  //the text controller helps us in managing the text field eg clearing it when the send button is clicked
  final messageTextController = TextEditingController();
  String email;
  String messageText;

  //this initiliazes the get user method when screen is started
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  //this method returns a future
  void getCurrentUser() {
    //once a user is registered or logged in then this current user will have  a variable
    //the current user will be null if nobody is signed in
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  // void getMessages () async {
  //   final messages = await _firestore.collection('messages').get();
  //   //this method loops through all the documents in the collection and prints them
  //   for (var message in messages.docs) {
  //     print(message.data());
  //   }
  //
  // }

  // void messagesStream() async {
  //   //snapshot messages sends a list of futures
  //   //the stream listens to all the changes that happen in that particular collection
  //   //think of the result as a list
  //   //we are saving the result of the stream in the snapshot
  //   await for (var snapshot in _firestore.collection('messages').snapshots()) {
  //     for (var message in snapshot.docs) {
  //       print(message.data());
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                // the firebase signout method
                _auth.signOut();
                Navigator.pop(context);
                // messagesStream();
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
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      //this tells the message controller to clear when the button is pressed
                      messageTextController.clear();
                      //messageText + loggedInUser.email
                      //the add method in firestore expects a map that has string as key
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
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
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        //this runs when there is no data available
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlue,
            ),
          );
        }
        //this reverses the order of the list
        //makes the last thing sent appear at the very bottom
        //initially it showed up at the top
        final messages = snapshot.data.docs.reversed;

        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message['text'];
          final messageSender = message['sender'];
          final currentUser = loggedInUser.email;
          if(currentUser == messageSender){

          }
          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUser == messageSender,
          );
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          //A list view allows the subsequent data to be scrollable
          child: ListView(
            //reverse makes the list view sticky to the last item on the list
            //makes the bottom of the list view showing
            reverse: true,
            padding:
            EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
      // builder: (BuildContext context, AsyncSnapshot snapshot) {
      //   QuerySnapshot querySnapshot = snapshot.requireData;
      //   final messages = snapshot.data.docs;
      //   return ListView.builder(
      //       itemCount: messages.length,
      //       itemBuilder: (context,index) {
      //         String message =messages[index]['sender'];
      //         return Text(message);
      //       }
      //   );
      // }
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.isMe});
  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontSize: 12.0,
            ),
          ),
          Material(
            elevation: 10.0,
            color: isMe?Colors.lightBlueAccent: Colors.grey,
            borderRadius: isMe? BorderRadius.only(topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)): 
                BorderRadius.only(  bottomLeft: Radius.circular(30), 
                bottomRight: Radius.circular(30), topRight: Radius.circular(30)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                '$text ',
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
