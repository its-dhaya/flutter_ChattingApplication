import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattify/api/apis.dart';
import 'package:chattify/helper/date_util.dart';
import 'package:chattify/helper/dialog.dart';
import 'package:chattify/main.dart'; // Assuming this is where `flutterLocalNotificationsPlugin` is initialized
import 'package:chattify/widgets/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import local notifications

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Messages message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromid;
    return InkWell(
      onLongPress: () {
        _showBottomsheet(isMe);
      },
      child: isMe ? _tealMessage() : _blueMessage(),
    );
  }

  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageStatus(widget.message);

      // Show a notification for the received message
      _showNotification(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .02, vertical: mq.height * .01),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 57, 154, 196),
              borderRadius: BorderRadius.circular(25),
            ),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.image, size: 70),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            DateUtil.getformatted(context: context, time: widget.message.sent),
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _tealMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: mq.width * .04),
            if (widget.message.read.isNotEmpty)
              Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 20,
              ),
            SizedBox(width: 2),
            Text(
              DateUtil.getformatted(
                  context: context, time: widget.message.sent),
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .02, vertical: mq.height * .01),
            decoration: BoxDecoration(
              color: Colors.tealAccent.shade700,
              borderRadius: BorderRadius.circular(25),
            ),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.image, size: 70),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // Show notification for the new message
  Future<void> _showNotification(Messages message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'chat_channel', // Channel ID
      'Chat Notifications', // Channel name
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Show notification
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'New Message', // Notification title
      message.type == Type.text
          ? message.msg
          : 'You received a new image', // Notification body
      platformChannelSpecifics,
    );
  }

  void _showBottomsheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8)),
              ),
              widget.message.type == Type.text
                  ? _OptionItem(
                      icon: Icon(
                        Icons.copy_all_outlined,
                        color: Colors.tealAccent.shade700,
                        size: 30,
                      ),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          Navigator.pop(context);
                          Dialogs.showSnackbar(context, 'Copied');
                        });
                      })
                  : _OptionItem(
                      icon: Icon(
                        Icons.download_rounded,
                        color: Colors.tealAccent.shade700,
                        size: 30,
                      ),
                      name: 'Save Image',
                      onTap: () async {
                        try {
                          log('Image url:${widget.message.msg}');
                          await GallerySaver.saveImage(widget.message.msg,
                                  albumName: 'chattify')
                              .then((success) {
                            if (success != null && success) {
                              Dialogs.showSnackbar(context, 'Image saved');
                            }
                          });
                        } catch (e) {
                          log('Error:$e');
                        }
                      }),
              if (isMe)
                Divider(
                  color: Colors.black,
                  endIndent: mq.width * .08,
                  indent: mq.width * .08,
                ),
              if (widget.message.type == Type.text && isMe)
                _OptionItem(
                    icon: Icon(
                      Icons.edit_square,
                      color: Colors.blue,
                      size: 30,
                    ),
                    name: 'Edit Message',
                    onTap: () {
                      _showupdatemsg();
                    }),
              if (isMe)
                _OptionItem(
                    icon: Icon(
                      Icons.delete_sharp,
                      color: Colors.red,
                      size: 30,
                    ),
                    name: 'Delete Message',
                    onTap: () async {
                      await APIs.deleteMessage(widget.message).then((value) {
                        Navigator.pop(context);
                      });
                    }),
              Divider(
                color: Colors.black,
                endIndent: mq.width * .08,
                indent: mq.width * .08,
              ),
              _OptionItem(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: Colors.blue,
                    size: 30,
                  ),
                  name:
                      'Sent at ${DateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                  onTap: () {}),
              _OptionItem(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: Colors.green,
                    size: 30,
                  ),
                  name: widget.message.read.isEmpty
                      ? 'Read at Not seen'
                      : 'Read at ${DateUtil.getMessageTime(context: context, time: widget.message.read)}',
                  onTap: () {}),
            ],
          );
        });
  }

  void _showupdatemsg() {
    String updatemsg = widget.message.msg;

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.message,
                    color: Colors.blue,
                    size: 20,
                  ),
                  Text('Edit')
                ],
              ),
              content: TextFormField(
                initialValue: updatemsg,
                maxLines: null,
                onChanged: (value) => updatemsg = value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel',
                      style: TextStyle(color: Colors.blue, fontSize: 16)),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    APIs.updateMessage(widget.message, updatemsg);
                  },
                  child: Text('Update',
                      style: TextStyle(color: Colors.blue, fontSize: 16)),
                ),
              ],
            ));
  }
}

class _OptionItem extends StatelessWidget {
  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  final Icon icon;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * .05,
            top: mq.height * .015,
            bottom: mq.height * .015),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              '   $name',
              style: TextStyle(
                  fontSize: 16, color: Colors.black87, letterSpacing: 0.5),
            ))
          ],
        ),
      ),
    );
  }
}
