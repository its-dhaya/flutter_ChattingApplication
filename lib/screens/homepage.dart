import 'dart:developer';
import 'package:chattify/api/apis.dart';
import 'package:chattify/helper/dialog.dart';
import 'package:chattify/screens/profilescreen.dart';
import 'package:chattify/widgets/chat_user.dart';
import 'package:chattify/widgets/chat_user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<ChatUserData> _list = [];

  final List<ChatUserData> _searchList = [];

  bool _isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getselfInfo();
     
    SystemChannels.lifecycle.setMessageHandler((message){
      log('Message:$message');
      if(APIs.auth.currentUser!=null){
      if(message.toString().contains('resume')){ APIs.updateActiveStatus(true);}
      if(message.toString().contains('pause')) {APIs.updateActiveStatus(false);}
      }

      return Future.value(message);


    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: Icon(Icons.home),
            title: _isSearching
                ? TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Name..',
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                    autofocus: true,
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                    onChanged: (val) {
                      _searchList.clear();

                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchList.add(i);
                        }
                      }
                      setState(() {});
                    },
                  )
                : Text('CHATTIFY'),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(_isSearching ? Icons.clear_rounded : Icons.search),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => Profilescreen(user: APIs.me)));
                },
                icon: Icon(Icons.more_vert),
              )
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () async {
               _showuserexists();
              },
              backgroundColor: Colors.tealAccent.shade700,
              child: Icon(Icons.add_comment_rounded, color: Colors.white),
            ),
          ),
          body:  StreamBuilder<QuerySnapshot>(stream: APIs.getMyusers(), builder: (context,snapshot){
                switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  // return const Center(child: CircularProgressIndicator(),);

                case ConnectionState.active:
                case ConnectionState.done:
           return StreamBuilder(
            stream: APIs.getAllusers(
              snapshot.data?.docs.map((e)=>e.id).toList()?? []
            ),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  // return const Center(child: CircularProgressIndicator(),);

                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;
                  _list = data?.map((e) => ChatUserData.fromJson(e.data())).toList() ?? [];

                  if (_list.isNotEmpty) {
                    return ListView.builder(
                      itemCount: _isSearching ? _searchList.length : _list.length,
                      itemBuilder: (context, index) {
                        return ChatUser(user: _isSearching ? _searchList[index] : _list[index]);
                      },
                    );
                  } else {
                    return Center(
                      child: Text(
                        'No connection found',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
              }
            },
          );
            }

          })
        ),
      ),
    );
  }
  void _showuserexists(){
    String email ='';

    showDialog(context: context, builder: (_)=>AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),

        
      ),
      title: Row(
        children: [
          Icon(Icons.message,
          color: Colors.blue,
          size: 20,),
          Text('Add user')
        ],
      ),
      content: TextFormField(
      maxLines: null,
      onChanged: (value)=>email = value,
      decoration: InputDecoration(
        hintText: 'Enter user mail',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
      ),
      actions: [
        MaterialButton(onPressed: (){
          Navigator.pop(context);
        },
        child: Text('Cancel',style:TextStyle(color: Colors.blue),)
        ,),
        MaterialButton(onPressed: (){
          Navigator.pop(context);
          if(email.isNotEmpty){
          APIs.showuserExists(email).then((value){
            if(!value){
              Dialogs.showSnackbar(context, 'user does not exists');
            }
          });
          }
        },
        child: Text('Add',style:TextStyle(color: Colors.blue),)
        ,)
      ],
    ));
    
  }
}
