import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/clothing_item.dart';
import '../../models/favorite_outfit.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/wardrobe_provider.dart';
import '../../theme/app_theme.dart';

class OutfitGeneratorScreen extends StatefulWidget {
  final WardrobeProvider wardrobeProvider;
  final FavoritesProvider favoritesProvider;

  const OutfitGeneratorScreen({
    super.key,
    required this.wardrobeProvider,
    required this.favoritesProvider,
  });

  @override
  State<OutfitGeneratorScreen> createState() =>
      _OutfitGeneratorScreenState();
}

class _OutfitGeneratorScreenState
    extends State<OutfitGeneratorScreen> {
  ClothingItem? _top;
  ClothingItem? _bottom;
  ClothingItem? _shoes;
  ClothingItem? _outerwear;
  ClothingItem? _accessory;

  bool _isGenerating = false;

  final Random _random = Random();

  List<ClothingItem> get _items =>
      widget.wardrobeProvider.items;

  List<ClothingItem> get _tops =>
      _items.where((item) => item.category == 'Tops').toList();

  List<ClothingItem> get _bottoms =>
      _items.where((item) => item.category == 'Bottoms').toList();

  List<ClothingItem> get _shoes =>
      _items.where((item) => item.category == 'Shoes').toList();

  List<ClothingItem> get _outerwears =>
      _items.where((item) => item.category == 'Outerwear').toList();

  List<ClothingItem> get _accessories =>
      _items.where((item) => item.category == 'Accessories').toList();

  List<ClothingItem> get _selectedItems {
    return [
      _top,
      _bottom,
      _shoes,
      _outerwear,
      _accessory,
    ].whereType<ClothingItem>().toList();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _shuffleAll();
    });
  }

  // ------------------------------------------------------------
  // COLOR MATCHING
  // ------------------------------------------------------------

  int _colorCompatibility(
      String first,
      String second,
      ) {
    final a = first.toLowerCase().trim();
    final b = second.toLowerCase().trim();

    if (a == b) {
      return 100;
    }

    const neutralColors = [
      'black',
      'white',
      'gray',
      'beige',
      'brown',
    ];

    if (neutralColors.contains(a) ||
        neutralColors.contains(b)) {
      return 95;
    }

    const compatiblePairs = {
      'blue': [
        'white',
        'beige',
        'brown',
        'gray',
        'black',
      ],
      'red': [
        'black',
        'white',
        'beige',
        'gray',
      ],
      'green': [
        'white',
        'beige',
        'brown',
        'black',
      ],
      'yellow': [
        'blue',
        'white',
        'brown',
        'gray',
      ],
      'pink': [
        'white',
        'gray',
        'black',
        'beige',
      ],
      'purple': [
        'white',
        'gray',
        'black',
        'beige',
      ],
      'orange': [
        'blue',
        'white',
        'brown',
        'beige',
      ],
    };

    if (compatiblePairs[a]?.contains(b) == true ||
        compatiblePairs[b]?.contains(a) == true) {
      return 90;
    }

    return 65;
  }

  int _calculateColorScore() {
    final selected = _selectedItems;

    if (selected.length < 2) {
      return 0;
    }

    int total = 0;
    int comparisons = 0;

    for (int i = 0; i < selected.length; i++) {
      for (int j = i + 1; j < selected.length; j++) {
        total += _colorCompatibility(
          selected[i].color,
          selected[j].color,
        );

        comparisons++;
      }
    }

    return (total / comparisons).round();
  }

  // ------------------------------------------------------------
  // STYLE MATCHING
  // ------------------------------------------------------------

  int _styleCompatibility(
      String first,
      String second,
      ) {
    final a = first.toLowerCase().trim();
    final b = second.toLowerCase().trim();

    if (a == b) {
      return 100;
    }

    const casualStyles = [
      'casual',
      'streetwear',
      'sport',
    ];

    if (casualStyles.contains(a) &&
        casualStyles.contains(b)) {
      return 90;
    }

    if ((a == 'formal' && b == 'smart casual') ||
        (a == 'smart casual' && b == 'formal')) {
      return 85;
    }

    if ((a == 'casual' && b == 'smart casual') ||
        (a == 'smart casual' && b == 'casual')) {
      return 85;
    }

    if ((a == 'streetwear' && b == 'casual') ||
        (a == 'casual' && b == 'streetwear')) {
      return 90;
    }

    return 65;
  }

  int _calculateStyleScore() {
    final selected = _selectedItems;

    if (selected.length < 2) {
      return 0;
    }

    int total = 0;
    int comparisons = 0;

    for (int i = 0; i < selected.length; i++) {
      for (int j = i + 1; j < selected.length; j++) {
        total += _styleCompatibility(
          selected[i].style,
          selected[j].style,
        );

        comparisons++;
      }
    }

    return (total / comparisons).round();
  }

  // ------------------------------------------------------------
  // SEASON MATCHING
  // ------------------------------------------------------------

  int _seasonCompatibility(
      String first,
      String second,
      ) {
    final a = first.toLowerCase().trim();
    final b = second.toLowerCase().trim();

    if (a == 'all season' ||
        b == 'all season') {
      return 100;
    }

    if (a == b) {
      return 100;
    }

    final warmSeasons = [
      'spring',
      'summer',
    ];

    final coolSeasons = [
      'autumn',
      'winter',
    ];

    if (warmSeasons.contains(a) &&
        warmSeasons.contains(b)) {
      return 85;
    }

    if (coolSeasons.contains(a) &&
        coolSeasons.contains(b)) {
      return 85;
    }

    return 55;
  }

  int _calculateSeasonScore() {
    final selected = _selectedItems;

    if (selected.length < 2) {
      return 0;
    }

    int total = 0;
    int comparisons = 0;

    for (int i = 0; i < selected.length; i++) {
      for (int j = i + 1; j < selected.length; j++) {
        total += _seasonCompatibility(
          selected[i].season,
          selected[j].season,
        );

        comparisons++;
      }
    }

    return (total / comparisons).round();
  }

  // ------------------------------------------------------------
  // SMART OUTFIT SCORE
  // ------------------------------------------------------------

  int _calculateOverallScore() {
    final colorScore = _calculateColorScore();
    final styleScore = _calculateStyleScore();
    final seasonScore = _calculateSeasonScore();

    return ((colorScore * 0.40) +
        (styleScore * 0.35) +
        (seasonScore * 0.25))
        .round()
        .clamp(0, 100);
  }

  String _scoreTitle(int score) {
    if (score >= 90) {
      return 'Perfect Outfit ✨';
    }

    if (score >= 80) {
      return 'Great Outfit';
    }

    if (score >= 70) {
      return 'Good Outfit';
    }

    if (score >= 60) {
      return 'Nice Combination';
    }

    return 'Try Another Shuffle';
  }

  String _scoreDescription(int score) {
    if (score >= 90) {
      return 'These pieces work beautifully together.';
    }

    if (score >= 80) {
      return 'These pieces create a strong combination.';
    }

    if (score >= 70) {
      return 'This outfit has a good overall balance.';
    }

    if (score >= 60) {
      return 'The outfit works, but another combination may be better.';
    }

    return 'Try shuffling again to find a stronger combination.';
  }

  // ------------------------------------------------------------
  // BEST MATCHING ITEM
  // ------------------------------------------------------------

  ClothingItem? _bestMatchingItem(
      List<ClothingItem> candidates,
      ) {
    if (candidates.isEmpty) {
      return null;
    }

    if (_selectedItems.isEmpty) {
      return candidates[_random.nextInt(candidates.length)];
    }

    ClothingItem? bestItem;
    int bestScore = -1;

    for (final candidate in candidates) {
      int totalScore = 0;
      int comparisons = 0;

      for (final selected in _selectedItems) {
        if (selected.id == candidate.id) {
          continue;
        }

        final colorScore = _colorCompatibility(
          selected.color,
          candidate.color,
        );

        final styleScore = _styleCompatibility(
          selected.style,
          candidate.style,
        );

        final seasonScore = _seasonCompatibility(
          selected.season,
          candidate.season,
        );

        final combinedScore =
            (colorScore * 0.40) +
                (styleScore * 0.35) +
                (seasonScore * 0.25);

        totalScore += combinedScore.round();
        comparisons++;
      }

      final averageScore =
      comparisons == 0
          ? 0
          : (totalScore / comparisons).round();

      if (averageScore > bestScore) {
        bestScore = averageScore;
        bestItem = candidate;
      }
    }

    return bestItem;
  }

  // ------------------------------------------------------------
  // GENERATE OUTFIT
  // ------------------------------------------------------------

  void _shuffleAll() {
    if (_items.isEmpty) {
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    Future.delayed(
      const Duration(milliseconds: 350),
          () {
        if (!mounted) {
          return;
        }

        final tops = List<ClothingItem>.from(_tops);
        final bottoms = List<ClothingItem>.from(_bottoms);
        final shoes = List<ClothingItem>.from(_shoes);
        final outerwears =
        List<ClothingItem>.from(_outerwears);
        final accessories =
        List<ClothingItem>.from(_accessories);

        tops.shuffle(_random);

        _top = tops.isNotEmpty ? tops.first : null;

        _bottom = _bestMatchingItem(bottoms);
        _shoes = _bestMatchingItem(shoes);

        if (outerwears.isNotEmpty) {
          _outerwear =
              _bestMatchingItem(outerwears);
        } else {
          _outerwear = null;
        }

        if (accessories.isNotEmpty) {
          _accessory =
              _bestMatchingItem(accessories);
        } else {
          _accessory = null;
        }

        setState(() {
          _isGenerating = false;
        });
      },
    );
  }

  ClothingItem? _findBestReplacement(
      ClothingItem? current,
      List<ClothingItem> candidates,
      ) {
    if (candidates.isEmpty) {
      return null;
    }

    final filtered = candidates
        .where((item) => item.id != current?.id)
        .toList();

    if (filtered.isEmpty) {
      return current;
    }

    return _bestMatchingItem(filtered);
  }

  void _shuffleTop() {
    setState(() {
      _top = _findBestReplacement(
        _top,
        _tops,
      );
    });
  }

  void _shuffleBottom() {
    setState(() {
      _bottom = _findBestReplacement(
        _bottom,
        _bottoms,
      );
    });
  }

  void _shuffleShoes() {
    setState(() {
      _shoes = _findBestReplacement(
        _shoes,
        _shoes,
      );
    });
  }

  void _shuffleOuterwear() {
    setState(() {
      _outerwear = _findBestReplacement(
        _outerwear,
        _outerwears,
      );
    });
  }

  void _shuffleAccessory() {
    setState(() {
      _accessory = _findBestReplacement(
        _accessory,
        _accessories,
      );
    });
  }

  // ------------------------------------------------------------
  // SAVE OUTFIT
  // ------------------------------------------------------------

  Future<void> _saveOutfit() async {
    if (_top == null ||
        _bottom == null ||
        _shoes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You need a top, bottom, and shoes to save an outfit.',
          ),
        ),
      );

      return;
    }

    final outfit = FavoriteOutfit(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      top: _top!,
      bottom: _bottom!,
      shoes: _shoes!,
      outerwear: _outerwear,
      accessory: _accessory,
      createdAt: DateTime.now(),
    );

    await widget.favoritesProvider.addFavorite(
      outfit,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Outfit saved to Favorites ❤️',
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final overallScore = _calculateOverallScore();
    final colorScore = _calculateColorScore();
    final styleScore = _calculateStyleScore();
    final seasonScore = _calculateSeasonScore();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Outfit Generator',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.background,
      ),
      body: _items.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 20),

            _buildScoreCard(
              overallScore,
              colorScore,
              styleScore,
              seasonScore,
            ),

            const SizedBox(height: 20),

            _buildOutfitCard(
              title: 'Top',
              item: _top,
              icon: Icons.checkroom_outlined,
              onShuffle: _shuffleTop,
            ),

            _buildOutfitCard(
              title: 'Bottom',
              item: _bottom,
              icon: Icons.dry_cleaning_outlined,
              onShuffle: _shuffleBottom,
            ),

            _buildOutfitCard(
              title: 'Shoes',
              item: _shoes,
              icon: Icons.directions_run_outlined,
              onShuffle: _shuffleShoes,
            ),

            if (_outerwear != null)
              _buildOutfitCard(
                title: 'Outerwear',
                item: _outerwear,
                icon: Icons.layers_outlined,
                onShuffle: _shuffleOuterwear,
              ),

            if (_accessory != null)
              _buildOutfitCard(
                title: 'Accessory',
                item: _accessory,
                icon: Icons.watch_outlined,
                onShuffle: _shuffleAccessory,
              ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isGenerating
                        ? null
                        : _shuffleAll,
                    icon: _isGenerating
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(
                      Icons.shuffle,
                    ),
                    label: const Text(
                      'Shuffle Again',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                      AppTheme.brown,
                      side: const BorderSide(
                        color: AppTheme.brown,
                      ),
                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveOutfit,
                    icon: const Icon(
                      Icons.favorite_border,
                    ),
                    label: const Text(
                      'Save Outfit',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      AppTheme.brown,
                      foregroundColor:
                      Colors.white,
                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Your next look',
          style: Theme.of(context)
              .textTheme
              .headlineMedium,
        ),
        const SizedBox(height: 5),
        const Text(
          'A smart combination from your wardrobe.',
          style: TextStyle(
            color: AppTheme.grayText,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard(
      int overallScore,
      int colorScore,
      int styleScore,
      int seasonScore,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppTheme.brown,
              ),
              const SizedBox(width: 8),
              const Text(
                'Smart Outfit Score',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lightBrown,
              border: Border.all(
                color: AppTheme.brown,
                width: 4,
              ),
            ),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Text(
                  overallScore.toString(),
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.brown,
                  ),
                ),
                const Text(
                  '/ 100',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.grayText,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Text(
            _scoreTitle(overallScore),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkText,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            _scoreDescription(overallScore),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.grayText,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildScoreBreakdown(
                  'Color',
                  colorScore,
                  Icons.palette_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildScoreBreakdown(
                  'Style',
                  styleScore,
                  Icons.style_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildScoreBreakdown(
                  'Season',
                  seasonScore,
                  Icons.wb_sunny_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdown(
      String title,
      int score,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.brown,
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.grayText,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '$score',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitCard({
    required String title,
    required ClothingItem? item,
    required IconData icon,
    required VoidCallback onShuffle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: item?.imagePath != null
                ? ClipRRect(
              borderRadius:
              BorderRadius.circular(14),
              child: Image.file(
                File(item!.imagePath!),
                fit: BoxFit.cover,
              ),
            )
                : Icon(
              icon,
              color: AppTheme.brown,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: item == null
                ? Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.grayText,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'No item available',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
              ],
            )
                : Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.grayText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.color} • ${item.style} • ${item.season}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.grayText,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: item == null
                ? null
                : onShuffle,
            icon: const Icon(
              Icons.shuffle,
              color: AppTheme.brown,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: AppTheme.lightBrown,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.checkroom_outlined,
                size: 55,
                color: AppTheme.brown,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your wardrobe is empty',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add some clothes first so StyleShuffle can create outfits for you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.grayText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}