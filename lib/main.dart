import 'package:flutter/material.dart';
import 'package:sandesh_app_fe/screens/screens.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'widgets/widgets.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData.dark(useMaterial3: true),
    debugShowCheckedModeBanner: false,
    home: const SandeshApp(),
  ));
}

class SandeshApp extends StatefulWidget {
  const SandeshApp({super.key});

  @override
  State<SandeshApp> createState() => _SandeshAppState();
}

class _SandeshAppState extends State<SandeshApp> {
  int tabIndex = 1;

  bool isOnline = false;
  late IO.Socket _socket;
  late String userId = 'DISCONNECTED';
  final String serverUrl = 'http://ramdipali.in'; //'http://192.168.1.4:5000';
  late int chatRoomIndex = 0;
  // [{id: room_1, members: [LQMLxFdKOvkgE-wxAAAX]}, {id: room_2, members: [LQMLxFdKOvkgE-wxAAAX]}, {id: room_3, members: [LQMLxFdKOvkgE-wxAAAX]}]
  var LobbyData = [];

  late final inMemoryChat = {'rooms': {}, 'trending': {}, 'personal': {}};

  _connectSocket() {
    _socket.onConnect((data) {
      setState(() {
        isOnline = true;
      });
    });

    _socket.on('getId', (socketId) {
      setState(() {
        userId = socketId;
      });
    });

    _socket.onDisconnect((data) {
      setState(() {
        isOnline = false;
        userId = 'DISCONNECTED';
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
    _socket = IO.io(serverUrl, {
      "transports": ["websocket"],
      "autoconnect": true,
    });
    _connectSocket();
    _socket.connect;
  }

  @override
  Widget build(BuildContext context) {
    print("BUILDING  MAIN SCREEN ");
    print("TABiNDEX $tabIndex");

    return Scaffold(
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
                initialIndex: tabIndex,
                length: 3,
                child: Scaffold(
                  appBar: AppBar(
                    bottom: const TabBar(
                      indicatorWeight: 5,
                      tabs: [
                        Tab(icon: Icon(Icons.add_box)),
                        Tab(icon: Icon(Icons.home)),
                        Tab(icon: Icon(Icons.person)),
                      ],
                    ),
                    title: Column(
                      children: [
                        Text("संदेश मेनू ID: $userId"),
                        Text("SERVER: $serverUrl")
                      ],
                    ),
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
                                    Text('members Count'),
                                    Text('Actions')
                                  ],
                                ),
                                ...List.generate(
                                    LobbyData.length,
                                    (index) => Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 8,
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    chatRoomIndex = index;
                                                    tabIndex = 0;
                                                  });
                                                },
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(LobbyData[index]
                                                          ['name']),
                                                      Text(LobbyData[index]
                                                          ['id']),
                                                      Text(LobbyData[index]
                                                              ['members']
                                                          .length
                                                          .toString()),
                                                    ]),
                                              ),
                                            ),
                                            const Spacer(),
                                            Expanded(
                                              flex: 6,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      _socket.emit(
                                                          'join_room', {
                                                        'roomID':
                                                            LobbyData[index]
                                                                ['id']
                                                      });
                                                    },
                                                    icon: const Icon(Icons.add),
                                                  ),
                                                  IconButton(
                                                      iconSize: 18,
                                                      onPressed: () {},
                                                      icon: const Icon(
                                                          Icons.remove)),
                                                  IconButton(
                                                      iconSize: 18,
                                                      onPressed: () {
                                                        _socket.emit(
                                                            'delete_room', {
                                                          'roomID':
                                                              LobbyData[index]
                                                                  ['id']
                                                        });
                                                      },
                                                      icon: const Icon(
                                                          Icons.delete))
                                                ],
                                              ),
                                            )
                                          ],
                                        )).toList()
                              ]),
                        ),
                      ),
                      ChatScreen(
                          socket: _socket,
                          roomData: LobbyData[chatRoomIndex],
                          LobbyData: LobbyData),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
