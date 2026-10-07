import 'package:flutter/material.dart';

import '../../models/clothing_item.dart';
import '../../providers/wardrobe_provider.dart';
import '../../theme/app_theme.dart';

class InsightsScreen extends StatelessWidget {
  final WardrobeProvider wardrobeProvider;

  const InsightsScreen({
    super.key,
    required this.wardrobeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: wardrobeProvider,
      builder: (context, child) {
        final items = wardrobeProvider.items;

        final totalItems = items.length;
        final totalValue = items.fold<double>(
          0,
              (sum, item) => sum + item.price,
        );

        final categoryCounts = _countValues(
          items.map((item) => item.category),
        );

        final colorCounts = _countValues(
          items.map((item) => item.color),
        );

        final styleCounts = _countValues(
          items.map((item) => item.style),
        );

        final seasonCounts = _countValues(
          items.map((item) => item.season),
        );

        final mostCommonCategory =
        _mostCommon(categoryCounts);

        final mostCommonColor =
        _mostCommon(colorCounts);

        final mostCommonStyle =
        _mostCommon(styleCounts);

        final mostCommonSeason =
        _mostCommon(seasonCounts);

        final categoryScore =
        _calculateCategoryScore(categoryCounts);

        final colorScore =
        _calculateColorScore(colorCounts);

        final wardrobeScore =
        ((categoryScore + colorScore) / 2).round();

        return Scaffold(
          backgroundColor: const Color(0xFFFFFBF7),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            title: const Text(
              'Wardrobe Insights',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: items.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
            onRefresh: () async {
              await wardrobeProvider.loadItems();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                30,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _buildScoreCard(wardrobeScore),
                  const SizedBox(height: 20),

                  _buildSectionTitle(
                    'Wardrobe Overview',
                    'A quick look at your collection',
                  ),
                  const SizedBox(height: 12),

                  _buildOverviewGrid(
                    totalItems: totalItems,
                    totalValue: totalValue,
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle(
                    'Categories',
                    'How your wardrobe is distributed',
                  ),
                  const SizedBox(height: 12),

                  _buildCategoryCard(
                    categoryCounts,
                    totalItems,
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle(
                    'Your Favorites',
                    'The most common choices in your wardrobe',
                  ),
                  const SizedBox(height: 12),

                  _buildInsightCard(
                    icon: Icons.palette_outlined,
                    title: 'Most Common Color',
                    value: mostCommonColor,
                    subtitle:
                    '${colorCounts[mostCommonColor] ?? 0} items',
                  ),

                  const SizedBox(height: 10),

                  _buildInsightCard(
                    icon: Icons.style_outlined,
                    title: 'Most Common Style',
                    value: mostCommonStyle,
                    subtitle:
                    '${styleCounts[mostCommonStyle] ?? 0} items',
                  ),

                  const SizedBox(height: 10),

                  _buildInsightCard(
                    icon: Icons.calendar_month_outlined,
                    title: 'Most Common Season',
                    value: mostCommonSeason,
                    subtitle:
                    '${seasonCounts[mostCommonSeason] ?? 0} items',
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle(
                    'Wardrobe Tips',
                    'Suggestions based on your collection',
                  ),
                  const SizedBox(height: 12),

                  ..._buildTips(
                    items,
                    categoryCounts,
                    colorCounts,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: AppTheme.brown.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.insights_outlined,
                size: 55,
                color: AppTheme.brown,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No wardrobe data yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some clothes to your wardrobe and your insights will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(int score) {
    String message;

    if (score >= 85) {
      message = 'Your wardrobe has great variety!';
    } else if (score >= 70) {
      message = 'Your wardrobe is looking balanced.';
    } else if (score >= 50) {
      message = 'You have a good start. Add some variety.';
    } else {
      message = 'Your wardrobe could use more variety.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.brown,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 105,
            height: 105,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 9,
                    backgroundColor: Colors.white24,
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Text(
                      '$score',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '/ 100',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wardrobe Score',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Your collection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      String title,
      String subtitle,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewGrid({
    required int totalItems,
    required double totalValue,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.checkroom_outlined,
            title: 'Items',
            value: totalItems.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.payments_outlined,
            title: 'Total Value',
            value: _formatPrice(totalValue),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppTheme.brown.withValues(
                alpha: 0.10,
              ),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.brown,
              size: 22,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      Map<String, int> categories,
      int total,
      ) {
    final sorted = categories.entries.toList()
      ..sort(
            (a, b) => b.value.compareTo(a.value),
      );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < sorted.length; i++) ...[
            _buildCategoryRow(
              sorted[i].key,
              sorted[i].value,
              total,
            ),
            if (i != sorted.length - 1)
              const SizedBox(height: 15),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryRow(
      String category,
      int count,
      int total,
      ) {
    final percentage =
    total == 0 ? 0.0 : count / total;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                category,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$count',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius:
          BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor:
            Colors.grey.shade200,
            valueColor:
            AlwaysStoppedAnimation<Color>(
              AppTheme.brown,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.brown.withValues(
                alpha: 0.10,
              ),
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: AppTheme.brown,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTips(
      List<ClothingItem> items,
      Map<String, int> categoryCounts,
      Map<String, int> colorCounts,
      ) {
    final tips = <String>[];

    if (items.length < 10) {
      tips.add(
        'Add more clothing items to build a more versatile wardrobe.',
      );
    }

    if (categoryCounts.length <= 2 &&
        items.isNotEmpty) {
      tips.add(
        'Try adding items from different categories for more outfit combinations.',
      );
    }

    if (colorCounts.length <= 2 &&
        items.length >= 5) {
      tips.add(
        'Your wardrobe has limited color variety. Try adding another color.',
      );
    }

    if (items.isNotEmpty) {
      final categories = categoryCounts.entries.toList();

      categories.sort(
            (a, b) => a.value.compareTo(b.value),
      );

      if (categories.isNotEmpty) {
        tips.add(
          'You have the fewest items in ${categories.first.key}. Consider adding more options.',
        );
      }
    }

    if (tips.isEmpty) {
      tips.add(
        'Your wardrobe has a nice variety. Keep experimenting with new combinations!',
      );
    }

    return tips
        .take(3)
        .map(
          (tip) => Padding(
        padding:
        const EdgeInsets.only(bottom: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppTheme.brown,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tip,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .toList();
  }

  Map<String, int> _countValues(
      Iterable<String> values,
      ) {
    final result = <String, int>{};

    for (final value in values) {
      final cleaned = value.trim();

      if (cleaned.isEmpty) {
        continue;
      }

      result[cleaned] =
          (result[cleaned] ?? 0) + 1;
    }

    return result;
  }

  String _mostCommon(
      Map<String, int> values,
      ) {
    if (values.isEmpty) {
      return 'None yet';
    }

    return values.entries.reduce(
          (a, b) => a.value >= b.value ? a : b,
    ).key;
  }

  int _calculateCategoryScore(
      Map<String, int> categories,
      ) {
    if (categories.isEmpty) {
      return 0;
    }

    if (categories.length >= 6) {
      return 100;
    }

    if (categories.length == 5) {
      return 95;
    }

    if (categories.length == 4) {
      return 85;
    }

    if (categories.length == 3) {
      return 70;
    }

    if (categories.length == 2) {
      return 50;
    }

    return 30;
  }

  int _calculateColorScore(
      Map<String, int> colors,
      ) {
    if (colors.isEmpty) {
      return 0;
    }

    if (colors.length >= 8) {
      return 100;
    }

    if (colors.length >= 6) {
      return 90;
    }

    if (colors.length >= 4) {
      return 75;
    }

    if (colors.length == 3) {
      return 60;
    }

    if (colors.length == 2) {
      return 45;
    }

    return 30;
  }

  String _formatPrice(double value) {
    if (value == 0) {
      return '0';
    }

    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }
}