import 'package:flutter/material.dart';

class WhatDidIDoScreen extends StatelessWidget {
  const WhatDidIDoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('What Did I Do!'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: const Center(
        child: Text('This is the "What Did I Do!" screen'),
      ),
    );
  }
}
