import 'package:floating_bar/floating_bar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          backgroundColor: Colors.red,
          body: Center(
            child: Container(
              color: Colors.blue,
              width: 500,
              height: 500,
              child: FloatingBar(
                isOnLeft: false,
                collapsedBackgroundColor: Colors.green,
                expandedBackgroundColor: Colors.black,
                collapsedOpacity: 1,
                expansionWidthPercentage: 0.5,
                floatingBarSize: 100,
                children: [
                  Container(
                      color: Colors.red,
                      width: 400,
                      child: const Center(child: Text('Hello'))),
                  const Center(child: Text('World')),
                  const Center(child: Text('Flutter')),
                ],
              ),
            ),
          )),
    );
  }
}
