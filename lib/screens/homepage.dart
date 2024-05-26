import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

import 'package:chattify/api/apis.dart';
import 'package:chattify/auth/loginscreen.dart';
import 'package:chattify/screens/profilescreen.dart';
import 'package:chattify/widgets/chat_user.dart';
import 'package:chattify/widgets/chat_user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
                await APIs.auth.signOut();
                await GoogleSignIn().signOut();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => Loginscreen()));
              },
              backgroundColor: Colors.tealAccent.shade700,
              child: Icon(Icons.add_comment_rounded, color: Colors.white),
            ),
          ),
          body: StreamBuilder(
            stream: APIs.getAllusers(),
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
          ),
        ),
      ),
    );
  }
}
