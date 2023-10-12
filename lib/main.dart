import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'widgets/widgets.dart';

void main() {
  runApp(const SandeshApp());
}

class SandeshApp extends StatefulWidget {
  const SandeshApp({super.key});

  @override
  State<SandeshApp> createState() => _SandeshAppState();
}

class _SandeshAppState extends State<SandeshApp> {
  bool isOnline = false;
  late IO.Socket _socket;

  // [{id: room_1, members: [LQMLxFdKOvkgE-wxAAAX]}, {id: room_2, members: [LQMLxFdKOvkgE-wxAAAX]}, {id: room_3, members: [LQMLxFdKOvkgE-wxAAAX]}]
  var LobbyData = [];

  late final inMemoryChat = {'rooms': {}, 'trending': {}, 'personal': {}};

  _connectSocket() {
    _socket.onConnect((data) {
      setState(() {
        isOnline = true;
      });
    });

    _socket.onDisconnect((data) {
      setState(() {
        isOnline = false;
      });
    });
    // Register event handlers
    _socket.on('lobby_update', (data) {
      print(data);
      setState(() {
        LobbyData = data;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _socket = IO.io("http://ramdipali.in", {
      "transports": ["websocket"],
      "autoconnect": true,
    });
    _connectSocket();
    _socket.connect;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: CustomAppBar(isOnline: isOnline),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('हरि ॐ !'),
              const Text(
                  'आप किसी भी विषय से जुड़ सकते हैं और अपने विचार व्यक्त कर सकते हैं ! कृपया सभी का सम्मान करें और अभद्र शब्दों का प्रयोग न करें'),
              // Removed the Container that was wrapping the Expanded
              Expanded(
                child: DefaultTabController(
                  initialIndex: 1,
                  length: 3,
                  child: Scaffold(
                    appBar: AppBar(
                      bottom: const TabBar(
                        indicatorWeight: 5,
                        tabs: [
                          Tab(
                              icon: Icon(
                            Icons.add_box,
                          )),
                          Tab(icon: Icon(Icons.home)),
                          Tab(icon: Icon(Icons.person)),
                        ],
                      ),
                      title: const Text('संदेश मेनू'),
                    ),
                    body: TabBarView(
                      children: [
                        Container(
                          child: CreateTopicWidget(socket: _socket),
                        ),
                        Container(
                          child: SingleChildScrollView(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('name'),
                                      Text('id'),
                                      Text('members Count')
                                    ],
                                  ),
                                  ..._buildLobby()
                                ]),
                          ),
                        ),
                        const Icon(Icons.person),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLobby() {
    return List.generate(
        LobbyData.length,
        (index) => InkWell(
              onTap: () => print(LobbyData[index]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(LobbyData[index]['name']),
                  Text(LobbyData[index]['id']),
                  Text(LobbyData[index]['members'].length.toString())
                ],
              ),
            ));
  }
}
