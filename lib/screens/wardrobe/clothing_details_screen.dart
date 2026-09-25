import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/clothing_item.dart';
import '../../providers/wardrobe_provider.dart';

class ClothingDetailsScreen extends StatelessWidget {
  final ClothingItem item;
  final WardrobeProvider wardrobeProvider;

  const ClothingDetailsScreen({
    super.key,
    required this.item,
    required this.wardrobeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clothing Details'),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),

            Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Text(
                    item.name,

                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _InfoRow(
                    icon: Icons.category_outlined,
                    title: 'Category',
                    value: item.category,
                  ),

                  _InfoRow(
                    icon: Icons.palette_outlined,
                    title: 'Color',
                    value: item.color,
                  ),

                  _InfoRow(
                    icon: Icons.style_outlined,
                    title: 'Style',
                    value: item.style,
                  ),

                  _InfoRow(
                    icon: Icons.wb_sunny_outlined,
                    title: 'Season',
                    value: item.season,
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await wardrobeProvider
                            .deleteItem(item.id);

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },

                      icon: const Icon(
                        Icons.delete_outline,
                      ),

                      label: const Text(
                        'Remove from Wardrobe',
                      ),

                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                        Colors.redAccent,

                        side: const BorderSide(
                          color: Colors.redAccent,
                        ),

                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                        ),
                      ),
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

  Widget _buildImage() {
    if (item.imagePath != null) {
      return SizedBox(
        width: double.infinity,
        height: 360,

        child: Image.file(
          File(item.imagePath!),
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 360,

      color: const Color(0xFFF4ECE6),

      child: Icon(
        Icons.checkroom_outlined,
        size: 100,
        color: const Color(0xFFB7A69A),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: const Color(0xFFF4ECE6),
              borderRadius:
              BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: const Color(0xFF5C4033),
            ),
          ),

          const SizedBox(width: 14),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              Text(
                title,

                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8A817C),
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,

                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}