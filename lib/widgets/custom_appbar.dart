import 'package:flag/flag.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isOnline;

  const CustomAppBar({
    required this.isOnline,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 50,
      // toolbarHeight: 60,
      leading: Flag.fromCode(
        FlagsCode.IN,
        height: 30, // Set the flag icon's height
        width: 30, // Set the flag icon's width
      ),
      title: const Column(
        children: [
          Text(
            'भारत का संदेश',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto'),
          ),
          Text(
            'अब करो जी भर के बात ! (जय श्री राम)',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                fontFamily: 'Roboto'),
          ),
        ],
      ),
      actions: [
        Icon(
          Icons.circle,
          color: isOnline ? Colors.green : Colors.red,
        ),
        (isOnline
            ? const Text('Online')
            : IconButton(
                onPressed: () {
                  final snackBar = SnackBar(
                    content: const Text('Reconnecting ...'),
                    action: SnackBarAction(
                      label: 'ok',
                      onPressed: () {
                        // Some code to undo the change.
                      },
                    ),
                  );

                  // Find the ScaffoldMessenger in the widget tree
                  // and use it to show a SnackBar.
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                icon: const Icon(Icons.refresh)))
      ],
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(100);
}
