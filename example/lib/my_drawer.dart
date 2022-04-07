import 'package:example/my_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_drawers/flutter_drawers.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        ListTile(
          leading: const Icon(Icons.new_releases),
          title: const Text('Dummy Item'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.add_box),
          title: const Text('increament'),
          onTap: context.read<MyCounter>().incrementCounter,
        ),
        ListTile(
          leading: const Icon(Icons.close),
          title: const Text('increment and close drawer'),
          onTap: () {
            context.read<MyCounter>().incrementCounter();
            SlideDrawer.of(context)?.close();
          },
        ),
      ],
    );
  }
}
