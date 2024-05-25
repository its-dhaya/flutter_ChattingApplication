import 'package:chattify/main.dart';
import 'package:chattify/widgets/chat_user_data.dart';
import 'package:flutter/material.dart';

class Profiledialog extends StatelessWidget {
  const Profiledialog({super.key,required this.user});

final ChatUserData user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      content: SizedBox(width: mq.width *.6,height: mq.height *.35,
      child: Stack(children: [],),),
    );
  }
}