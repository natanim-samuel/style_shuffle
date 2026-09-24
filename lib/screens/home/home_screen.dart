import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'StyleShuffle',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {},

            icon: const Icon(
              Icons.notifications_none,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Hello, Natanim 👋',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'What are you wearing today?',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF8A817C),
              ),
            ),

            const SizedBox(height: 28),

            // Generate Outfit Card
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: const Color(0xFFE8D8C8),

                borderRadius: BorderRadius.circular(24),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Your daily style ✨',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C4033),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Discover a new outfit combination.',
                    style: TextStyle(
                      color: Color(0xFF6F5B50),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: () {},

                    icon: const Icon(Icons.shuffle),

                    label: const Text('Generate Outfit'),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C4033),

                      foregroundColor: Colors.white,

                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Your Wardrobe',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.checkroom_outlined,
                    number: '0',
                    label: 'Clothes',
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _StatCard(
                    icon: Icons.favorite_outline,
                    number: '0',
                    label: 'Favorites',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Today's Outfit",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(20),

                border: Border.all(
                  color: const Color(0xFFEDE5DE),
                ),
              ),

              child: const Column(
                children: [
                  Icon(
                    Icons.checkroom_outlined,
                    size: 48,
                    color: Color(0xFFB7A69A),
                  ),

                  SizedBox(height: 12),

                  Text(
                    'No outfit planned yet',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    'Create your outfit for today.',
                    style: TextStyle(
                      color: Color(0xFF8A817C),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String number;
  final String label;

  const _StatCard({
    required this.icon,
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: const Color(0xFFEDE5DE),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            color: const Color(0xFF5C4033),
            size: 26,
          ),

          const SizedBox(height: 12),

          Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8A817C),
            ),
          ),
        ],
      ),
    );
  }
}