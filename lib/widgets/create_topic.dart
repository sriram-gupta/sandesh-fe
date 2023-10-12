import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CreateTopicWidget extends StatefulWidget {
  final IO.Socket socket;

  const CreateTopicWidget({super.key, required this.socket});

  @override
  _CreateTopicWidgetState createState() => _CreateTopicWidgetState();
}

class _CreateTopicWidgetState extends State<CreateTopicWidget> {
  late TextEditingController _topicController;

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController();
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('विषय का नाम'),
        TextFormField(
          controller: _topicController,
          decoration: const InputDecoration(
            hintText: 'Enter topic name',
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final roomName = _topicController.text;
            if (roomName.isNotEmpty) {
              widget.socket.emit('create_room',
                  {'roomName': roomName}); // Emit the "create room" event
              _topicController.clear();
            }
          },
          child: const Text('विषय बनाएं'),
        ),
      ],
    );
  }
}
