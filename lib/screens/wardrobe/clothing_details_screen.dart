import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/clothing_item.dart';
import '../../providers/wardrobe_provider.dart';
import '../../providers/wear_history_provider.dart';

class ClothingDetailsScreen extends StatelessWidget {
  final ClothingItem item;
  final WardrobeProvider wardrobeProvider;
  final WearHistoryProvider wearHistoryProvider;

  const ClothingDetailsScreen({
    super.key,
    required this.item,
    required this.wardrobeProvider,
    required this.wearHistoryProvider,
  });

  @override
  Widget build(BuildContext context) {
    final wearCount =
    wearHistoryProvider.getWearCountForItem(item);

    final costPerWear =
    wearHistoryProvider.getCostPerWear(item);

    final lastWorn =
    wearHistoryProvider.getLastWornForItem(item);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clothing Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
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

                  // COST PER WEAR CARD
                  _buildCostCard(
                    wearCount: wearCount,
                    costPerWear: costPerWear,
                  ),

                  const SizedBox(height: 24),

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

                  _InfoRow(
                    icon: Icons.payments_outlined,
                    title: 'Purchase Price',
                    value:
                    '${item.price.toStringAsFixed(2)} ETB',
                  ),

                  _InfoRow(
                    icon: Icons.checkroom_outlined,
                    title: 'Times Worn',
                    value: wearCount == 1
                        ? '1 time'
                        : '$wearCount times',
                  ),

                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    title: 'Last Worn',
                    value: lastWorn == null
                        ? 'Not worn yet'
                        : _formatDate(lastWorn),
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
                      style:
                      OutlinedButton.styleFrom(
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

  Widget _buildCostCard({
    required int wearCount,
    required double costPerWear,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF4ECE6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE4D7CD),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.trending_down_rounded,
                color: Color(0xFF5C4033),
              ),
              SizedBox(width: 10),
              Text(
                'Cost Per Wear',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5C4033),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _CostStat(
                  title: 'Price',
                  value:
                  '${item.price.toStringAsFixed(0)} ETB',
                ),
              ),
              Expanded(
                child: _CostStat(
                  title: 'Worn',
                  value: '$wearCount',
                ),
              ),
              Expanded(
                child: _CostStat(
                  title: 'Per Wear',
                  value:
                  '${costPerWear.toStringAsFixed(0)} ETB',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            wearCount == 0
                ? 'Wear this item more to lower its cost per wear.'
                : 'The more you wear it, the lower your cost per wear becomes.',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF8A817C),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final year = date.year.toString();

    return '$day/$month/$year';
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
      child: const Icon(
        Icons.checkroom_outlined,
        size: 100,
        color: Color(0xFFB7A69A),
      ),
    );
  }
}

class _CostStat extends StatelessWidget {
  final String title;
  final String value;

  const _CostStat({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2521),
          ),
        ),
      ],
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