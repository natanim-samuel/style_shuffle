import 'package:flutter/material.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Planner'),
      ),

      body: const Center(
        child: Text(
          'Plan your outfits here 📅',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}