import 'package:flutter/material.dart';

class WardrobeScreen extends StatelessWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wardrobe'),
      ),

      body: const Center(
        child: Text(
          'Your clothes will appear here 👕',
          style: TextStyle(fontSize: 18),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},

        backgroundColor: const Color(0xFF5C4033),

        foregroundColor: Colors.white,

        child: const Icon(Icons.add),
      ),
    );
  }
}