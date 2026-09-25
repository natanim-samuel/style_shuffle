import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Outfits'),
      ),

      body: const Center(
        child: Text(
          'Your favorite outfits will appear here ❤️',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}