import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/favorite_outfit.dart';
import '../../models/wear_history.dart';
import '../../providers/wear_history_provider.dart';
import '../../theme/app_theme.dart';

class WearHistoryScreen extends StatefulWidget {
  final WearHistoryProvider wearHistoryProvider;

  const WearHistoryScreen({
    super.key,
    required this.wearHistoryProvider,
  });

  @override
  State<WearHistoryScreen> createState() =>
      _WearHistoryScreenState();
}

class _WearHistoryScreenState
    extends State<WearHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.wearHistoryProvider,
      builder: (context, child) {
        final history =
            widget.wearHistoryProvider.recentHistory;

        final mostWorn =
        widget.wearHistoryProvider
            .getMostWornOutfits();

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Wear History',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: history.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
            onRefresh: () async {
              await widget
                  .wearHistoryProvider
                  .loadHistory();
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSummaryCards(),
                const SizedBox(height: 28),

                if (mostWorn.isNotEmpty) ...[
                  const Text(
                    'Most Worn',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildMostWornSection(
                    mostWorn,
                  ),
                  const SizedBox(height: 30),
                ],

                const Text(
                  'Recently Worn',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 14),

                ...history.map(
                      (entry) =>
                      _buildHistoryCard(entry),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppTheme.lightBrown,
                borderRadius:
                BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.history,
                size: 44,
                color: AppTheme.brown,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Wear History Yet',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'When you wear an outfit, mark it as worn and it will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.grayText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.checkroom,
            value: widget
                .wearHistoryProvider
                .totalWears
                .toString(),
            label: 'Total Wears',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.style,
            value: widget
                .wearHistoryProvider
                .uniqueOutfits
                .toString(),
            label: 'Outfits Worn',
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.lightBrown,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.lightBrown,
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: AppTheme.brown,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.grayText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMostWornSection(
      List<WearHistory> outfits,
      ) {
    final limited = outfits.take(3).toList();

    return SizedBox(
      height: 205,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: limited.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 12);
        },
        itemBuilder: (context, index) {
          final entry = limited[index];

          final count = widget
              .wearHistoryProvider
              .getWearCountForOutfit(
            entry.outfit,
          );

          return _buildMostWornCard(
            entry.outfit,
            count,
          );
        },
      ),
    );
  }

  Widget _buildMostWornCard(
      FavoriteOutfit outfit,
      int count,
      ) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.lightBrown,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildOutfitImage(
                    outfit.items[0],
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildOutfitImage(
                          outfit.items.length > 1
                              ? outfit.items[1]
                              : outfit.items[0],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: _buildOutfitImage(
                          outfit.items.length > 2
                              ? outfit.items[2]
                              : outfit.items[0],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.repeat,
                size: 16,
                color: AppTheme.brown,
              ),
              const SizedBox(width: 5),
              Text(
                '$count ${count == 1 ? 'wear' : 'wears'}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.brown,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
      WearHistory entry,
      ) {
    final outfit = entry.outfit;

    final wearCount = widget
        .wearHistoryProvider
        .getWearCountForOutfit(
      outfit,
    );

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _confirmDelete(entry);
      },
      onDismissed: (direction) async {
        await widget
            .wearHistoryProvider
            .removeHistory(entry.id);
      },
      background: Container(
        margin:
        const EdgeInsets.only(bottom: 12),
        padding:
        const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius:
          BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.delete_outline,
          color: Colors.red.shade700,
        ),
      ),
      child: Container(
        margin:
        const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            _buildHistoryImages(outfit),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Outfit worn',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _formatDate(entry.wornAt),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.grayText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.lightBrown,
                      borderRadius:
                      BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$wearCount ${wearCount == 1 ? 'time' : 'times'} worn',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w600,
                        color: AppTheme.brown,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.check_circle,
              color: AppTheme.brown,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryImages(
      FavoriteOutfit outfit,
      ) {
    final items = outfit.items.take(3).toList();

    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        children: [
          for (int i = 0; i < items.length; i++)
            Positioned(
              left: i * 24,
              top: i * 4,
              child: Container(
                width: 60,
                height: 78,
                decoration: BoxDecoration(
                  color: AppTheme.lightBrown,
                  borderRadius:
                  BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: _buildOutfitImage(
                  items[i],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOutfitImage(
      dynamic item,
      ) {
    final imagePath = item.imagePath;

    if (imagePath != null &&
        imagePath.isNotEmpty &&
        File(imagePath).existsSync()) {
      return ClipRRect(
        borderRadius:
        BorderRadius.circular(12),
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightBrown,
        borderRadius:
        BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.checkroom_outlined,
        color: AppTheme.brown,
        size: 26,
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final minute =
    date.minute.toString().padLeft(2, '0');

    final period =
    date.hour >= 12 ? 'PM' : 'AM';

    return '${months[date.month - 1]} ${date.day}, ${date.year} • $hour:$minute $period';
  }

  Future<bool> _confirmDelete(
      WearHistory entry,
      ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Remove from history?',
          ),
          content: const Text(
            'This wear record will be removed from your history.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Remove',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}