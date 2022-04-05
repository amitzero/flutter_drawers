import 'package:example/my_counter.dart';
import 'package:example/my_drawer.dart';
import 'package:example/my_home_page.dart';
import 'package:flutter/material.dart';

import 'package:flutter_drawers/flutter_drawers.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyCounter(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BoxDrawer(
          drawer: MyDrawer(),
          animatedHeader: Text(
            'Hello Flutter',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          headerHeight: 50,
          child: MyHomePage(),
        ),
      ),
    );
  }
}
