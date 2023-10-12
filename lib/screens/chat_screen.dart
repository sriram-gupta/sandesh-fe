import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final IO.Socket socket;
  final Map<dynamic, dynamic> roomData;
  final LobbyData;

  const ChatScreen(
      {Key? key,
      required this.socket,
      required this.roomData,
      required this.LobbyData})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<String> messages = [];

  @override
  Widget build(BuildContext context) {
    final chatData =
        widget.LobbyData.where((e) => e['id'] == widget.roomData['id']);
    final chatMessages = chatData.isNotEmpty ? chatData.first['messages'] : [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.roomData['name']), // Set the title using widget.roomData
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(chatMessages[index]['msg']),
                        Text(chatMessages[index]['sender'])
                      ]),
                );
              },
            ),
          ),
          // Column(
          //   children: [Text(chatData['messages'][0].toString())],
          // ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration:
                        const InputDecoration(labelText: 'Enter your message'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    String message = _messageController.text;
                    if (message.isNotEmpty) {
                      // Send the message to the server or handle it as needed
                      messages
                          .add(message); // Add the message to the local list
                      widget.socket.emit("new_message_to_room", {
                        "roomID": widget.roomData['id'],
                        "msg": message.toString()
                      });
                      _messageController.clear(); // Clear the text field
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
