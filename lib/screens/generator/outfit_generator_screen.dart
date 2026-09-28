import 'dart:io';
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
  final Random _random = Random();

  ClothingItem? _selectedTop;
  ClothingItem? _selectedBottom;
  ClothingItem? _selectedShoes;
  ClothingItem? _selectedOuterwear;
  ClothingItem? _selectedAccessory;

  bool _hasGenerated = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _shuffleAll();
    });
  }

  List<ClothingItem> get _tops {
    return widget.wardrobeProvider.getByCategory('Tops');
  }

  List<ClothingItem> get _bottoms {
    return widget.wardrobeProvider.getByCategory('Bottoms');
  }

  List<ClothingItem> get _shoes {
    return widget.wardrobeProvider.getByCategory('Shoes');
  }

  List<ClothingItem> get _outerwear {
    return widget.wardrobeProvider.getByCategory('Outerwear');
  }

  List<ClothingItem> get _accessories {
    return widget.wardrobeProvider.getByCategory('Accessories');
  }

  List<ClothingItem> get _selectedItems {
    return [
      _selectedTop,
      _selectedBottom,
      _selectedShoes,
      _selectedOuterwear,
      _selectedAccessory,
    ].whereType<ClothingItem>().toList();
  }

  // ============================================================
  // COLOR MATCHING
  // ============================================================

  int _colorCompatibility(
      String first,
      String second,
      ) {
    final a = first.toLowerCase().trim();
    final b = second.toLowerCase().trim();

    if (a == b) {
      return 80;
    }

    final neutrals = [
      'black',
      'white',
      'gray',
      'beige',
      'brown',
    ];

    final darkNeutrals = [
      'black',
      'brown',
      'gray',
    ];

    final lightNeutrals = [
      'white',
      'beige',
      'gray',
    ];

    if (neutrals.contains(a) &&
        neutrals.contains(b)) {
      return 95;
    }

    if (neutrals.contains(a) ||
        neutrals.contains(b)) {
      return 90;
    }

    if ((a == 'blue' && b == 'red') ||
        (a == 'red' && b == 'blue')) {
      return 65;
    }

    if ((a == 'blue' && b == 'green') ||
        (a == 'green' && b == 'blue')) {
      return 75;
    }

    if ((a == 'red' && b == 'green') ||
        (a == 'green' && b == 'red')) {
      return 55;
    }

    if ((a == 'purple' && b == 'yellow') ||
        (a == 'yellow' && b == 'purple')) {
      return 75;
    }

    if ((a == 'orange' && b == 'blue') ||
        (a == 'blue' && b == 'orange')) {
      return 75;
    }

    if ((a == 'pink' && b == 'green') ||
        (a == 'green' && b == 'pink')) {
      return 75;
    }

    if ((a == 'pink' && b == 'blue') ||
        (a == 'blue' && b == 'pink')) {
      return 85;
    }

    if ((a == 'yellow' && b == 'blue') ||
        (a == 'blue' && b == 'yellow')) {
      return 85;
    }

    if ((a == 'orange' && b == 'brown') ||
        (a == 'brown' && b == 'orange')) {
      return 85;
    }

    if (darkNeutrals.contains(a) &&
        lightNeutrals.contains(b)) {
      return 95;
    }

    if (darkNeutrals.contains(b) &&
        lightNeutrals.contains(a)) {
      return 95;
    }

    return 65;
  }

  int _calculateColorScore() {
    final items = _selectedItems;

    if (items.length < 2) {
      return 0;
    }

    int total = 0;
    int comparisons = 0;

    for (int i = 0; i < items.length; i++) {
      for (int j = i + 1;
      j < items.length;
      j++) {
        total += _colorCompatibility(
          items[i].color,
          items[j].color,
        );

        comparisons++;
      }
    }

    if (comparisons == 0) {
      return 0;
    }

    return (total / comparisons).round();
  }

  String _colorMatchText(int score) {
    if (score >= 90) {
      return 'Excellent color match ✨';
    }

    if (score >= 80) {
      return 'Great color combination';
    }

    if (score >= 70) {
      return 'Good color combination';
    }

    if (score >= 60) {
      return 'Bold color combination';
    }

    return 'Try another color combination';
  }

  Color _colorMatchBackground(int score) {
    if (score >= 80) {
      return const Color(0xFFE7F3E8);
    }

    if (score >= 65) {
      return const Color(0xFFFFF3D9);
    }

    return const Color(0xFFF8E3E3);
  }

  Color _colorMatchTextColor(int score) {
    if (score >= 80) {
      return const Color(0xFF47734A);
    }

    if (score >= 65) {
      return const Color(0xFF8A651B);
    }

    return const Color(0xFF9A4C4C);
  }

  // ============================================================
  // STYLE MATCHING
  // ============================================================

  int _styleCompatibility(
      String first,
      String second,
      ) {
    final a = first.toLowerCase().trim();
    final b = second.toLowerCase().trim();

    if (a == b) {
      return 100;
    }

    final casualStyles = [
      'casual',
      'smart casual',
    ];

    final formalStyles = [
      'formal',
      'smart casual',
    ];

    final streetStyles = [
      'streetwear',
      'casual',
    ];

    final sportStyles = [
      'sport',
      'casual',
    ];

    if (casualStyles.contains(a) &&
        casualStyles.contains(b)) {
      return 90;
    }

    if (formalStyles.contains(a) &&
        formalStyles.contains(b)) {
      return 90;
    }

    if (streetStyles.contains(a) &&
        streetStyles.contains(b)) {
      return 88;
    }

    if (sportStyles.contains(a) &&
        sportStyles.contains(b)) {
      return 85;
    }

    if ((a == 'formal' &&
        b == 'smart casual') ||
        (a == 'smart casual' &&
            b == 'formal')) {
      return 85;
    }

    if ((a == 'streetwear' &&
        b == 'sport') ||
        (a == 'sport' &&
            b == 'streetwear')) {
      return 85;
    }

    if ((a == 'streetwear' &&
        b == 'smart casual') ||
        (a == 'smart casual' &&
            b == 'streetwear')) {
      return 65;
    }

    if ((a == 'formal' &&
        b == 'streetwear') ||
        (a == 'streetwear' &&
            b == 'formal')) {
      return 45;
    }

    if ((a == 'formal' &&
        b == 'sport') ||
        (a == 'sport' &&
            b == 'formal')) {
      return 40;
    }

    return 60;
  }

  int _calculateStyleScore() {
    final items = _selectedItems;

    if (items.length < 2) {
      return 0;
    }

    int total = 0;
    int comparisons = 0;

    for (int i = 0; i < items.length; i++) {
      for (int j = i + 1;
      j < items.length;
      j++) {
        total += _styleCompatibility(
          items[i].style,
          items[j].style,
        );

        comparisons++;
      }
    }

    if (comparisons == 0) {
      return 0;
    }

    return (total / comparisons).round();
  }

  String _styleMatchText(int score) {
    if (score >= 90) {
      return 'Excellent style match ✨';
    }

    if (score >= 80) {
      return 'Great style combination';
    }

    if (score >= 70) {
      return 'Good style combination';
    }

    if (score >= 60) {
      return 'Mixed style combination';
    }

    return 'Styles may clash';
  }

  Color _styleMatchBackground(int score) {
    if (score >= 80) {
      return const Color(0xFFE7F3E8);
    }

    if (score >= 65) {
      return const Color(0xFFFFF3D9);
    }

    return const Color(0xFFF8E3E3);
  }

  Color _styleMatchTextColor(int score) {
    if (score >= 80) {
      return const Color(0xFF47734A);
    }

    if (score >= 65) {
      return const Color(0xFF8A651B);
    }

    return const Color(0xFF9A4C4C);
  }

  // ============================================================
  // SMART OUTFIT GENERATION
  // ============================================================

  ClothingItem? _bestMatchingItem(
      List<ClothingItem> items,
      List<ClothingItem> alreadySelected,
      ) {
    if (items.isEmpty) {
      return null;
    }

    if (items.length == 1) {
      return items.first;
    }

    ClothingItem? bestItem;
    double bestScore = -1;

    for (final candidate in items) {
      if (alreadySelected.any(
            (item) => item.id == candidate.id,
      )) {
        continue;
      }

      if (alreadySelected.isEmpty) {
        if (bestItem == null ||
            _random.nextBool()) {
          bestItem = candidate;
        }

        continue;
      }

      int totalColor = 0;
      int totalStyle = 0;

      for (final selected in alreadySelected) {
        totalColor += _colorCompatibility(
          candidate.color,
          selected.color,
        );

        totalStyle += _styleCompatibility(
          candidate.style,
          selected.style,
        );
      }

      final colorScore =
          totalColor / alreadySelected.length;

      final styleScore =
          totalStyle / alreadySelected.length;

      final combinedScore =
          (colorScore * 0.5) +
              (styleScore * 0.5);

      if (combinedScore > bestScore) {
        bestScore = combinedScore;
        bestItem = candidate;
      }
    }

    return bestItem ?? items.first;
  }

  void _shuffleAll() {
    setState(() {
      _selectedTop = _bestMatchingItem(
        _tops,
        [],
      );

      final selectedAfterTop = [
        if (_selectedTop != null) _selectedTop!,
      ];

      _selectedBottom = _bestMatchingItem(
        _bottoms,
        selectedAfterTop,
      );

      final selectedAfterBottom = [
        ...selectedAfterTop,
        if (_selectedBottom != null) _selectedBottom!,
      ];

      _selectedShoes = _bestMatchingItem(
        _shoes,
        selectedAfterBottom,
      );

      final selectedAfterShoes = [
        ...selectedAfterBottom,
        if (_selectedShoes != null) _selectedShoes!,
      ];

      _selectedOuterwear = _outerwear.isEmpty
          ? null
          : _bestMatchingItem(
        _outerwear,
        selectedAfterShoes,
      );

      final selectedAfterOuterwear = [
        ...selectedAfterShoes,
        if (_selectedOuterwear != null)
          _selectedOuterwear!,
      ];

      _selectedAccessory = _accessories.isEmpty
          ? null
          : _bestMatchingItem(
        _accessories,
        selectedAfterOuterwear,
      );

      _hasGenerated = true;
    });
  }

  // ============================================================
  // INDIVIDUAL SHUFFLE
  // ============================================================

  ClothingItem? _randomItem(
      List<ClothingItem> items, {
        ClothingItem? current,
      }) {
    if (items.isEmpty) {
      return null;
    }

    if (items.length == 1) {
      return items.first;
    }

    final available = items
        .where(
          (item) => item.id != current?.id,
    )
        .toList();

    if (available.isEmpty) {
      return items.first;
    }

    return available[
    _random.nextInt(available.length)
    ];
  }

  ClothingItem? _findBestReplacement(
      List<ClothingItem> candidates,
      ClothingItem? current,
      ) {
    final otherItems = _selectedItems
        .where(
          (item) => item.id != current?.id,
    )
        .toList();

    if (otherItems.isEmpty) {
      return _randomItem(
        candidates,
        current: current,
      );
    }

    ClothingItem? bestItem;
    double bestScore = -1;

    for (final candidate in candidates) {
      if (candidate.id == current?.id) {
        continue;
      }

      int totalColor = 0;
      int totalStyle = 0;

      for (final item in otherItems) {
        totalColor += _colorCompatibility(
          candidate.color,
          item.color,
        );

        totalStyle += _styleCompatibility(
          candidate.style,
          item.style,
        );
      }

      final colorScore =
          totalColor / otherItems.length;

      final styleScore =
          totalStyle / otherItems.length;

      final combinedScore =
          (colorScore * 0.5) +
              (styleScore * 0.5);

      if (combinedScore > bestScore) {
        bestScore = combinedScore;
        bestItem = candidate;
      }
    }

    return bestItem ??
        _randomItem(
          candidates,
          current: current,
        );
  }

  void _shuffleTop() {
    if (_tops.isEmpty) {
      _showMessage(
        'Add some tops to your wardrobe first.',
      );
      return;
    }

    setState(() {
      _selectedTop = _findBestReplacement(
        _tops,
        _selectedTop,
      );
    });
  }

  void _shuffleBottom() {
    if (_bottoms.isEmpty) {
      _showMessage(
        'Add some bottoms to your wardrobe first.',
      );
      return;
    }

    setState(() {
      _selectedBottom = _findBestReplacement(
        _bottoms,
        _selectedBottom,
      );
    });
  }

  void _shuffleShoes() {
    if (_shoes.isEmpty) {
      _showMessage(
        'Add some shoes to your wardrobe first.',
      );
      return;
    }

    setState(() {
      _selectedShoes = _findBestReplacement(
        _shoes,
        _selectedShoes,
      );
    });
  }

  void _shuffleOuterwear() {
    if (_outerwear.isEmpty) {
      _showMessage(
        'Add some outerwear to your wardrobe first.',
      );
      return;
    }

    setState(() {
      _selectedOuterwear =
          _findBestReplacement(
            _outerwear,
            _selectedOuterwear,
          );
    });
  }

  void _shuffleAccessory() {
    if (_accessories.isEmpty) {
      _showMessage(
        'Add some accessories to your wardrobe first.',
      );
      return;
    }

    setState(() {
      _selectedAccessory =
          _findBestReplacement(
            _accessories,
            _selectedAccessory,
          );
    });
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _saveOutfit() async {
    if (_selectedTop == null ||
        _selectedBottom == null ||
        _selectedShoes == null) {
      _showMessage(
        'You need at least a top, bottom, and shoes.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final outfit = FavoriteOutfit(
      id: DateTime.now()
          .microsecondsSinceEpoch
          .toString(),
      top: _selectedTop!,
      bottom: _selectedBottom!,
      shoes: _selectedShoes!,
      outerwear: _selectedOuterwear,
      accessory: _selectedAccessory,
      createdAt: DateTime.now(),
    );

    await widget.favoritesProvider.addFavorite(
      outfit,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Outfit saved to Favorites ❤️',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final hasEnoughItems =
        _tops.isNotEmpty &&
            _bottoms.isNotEmpty &&
            _shoes.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Outfit Generator',
        ),
      ),
      body: !hasEnoughItems
          ? _buildMissingItemsState()
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          35,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 20),

            _buildOutfitPreview(),

            const SizedBox(height: 14),

            _buildColorMatchCard(),

            const SizedBox(height: 12),

            _buildStyleMatchCard(),

            const SizedBox(height: 22),

            _buildShuffleAgainButton(),

            const SizedBox(height: 22),

            const Text(
              'Customize your outfit',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Shuffle individual pieces while keeping the rest.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.grayText,
              ),
            ),

            const SizedBox(height: 16),

            _buildClothingSection(
              label: 'Top',
              item: _selectedTop,
              onShuffle: _shuffleTop,
            ),

            const SizedBox(height: 12),

            _buildClothingSection(
              label: 'Bottom',
              item: _selectedBottom,
              onShuffle: _shuffleBottom,
            ),

            const SizedBox(height: 12),

            _buildClothingSection(
              label: 'Shoes',
              item: _selectedShoes,
              onShuffle: _shuffleShoes,
            ),

            if (_outerwear.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildClothingSection(
                label: 'Outerwear',
                item: _selectedOuterwear,
                onShuffle: _shuffleOuterwear,
              ),
            ],

            if (_accessories.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildClothingSection(
                label: 'Accessory',
                item: _selectedAccessory,
                onShuffle: _shuffleAccessory,
              ),
            ],

            const SizedBox(height: 24),

            _buildSaveButton(),
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
        const Text(
          'Shuffle your style ✨',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _hasGenerated
              ? 'Your outfit is matched by color and style.'
              : 'Let StyleShuffle pick an outfit for you.',
          style: const TextStyle(
            fontSize: 15,
            color: AppTheme.grayText,
          ),
        ),
      ],
    );
  }

  Widget _buildOutfitPreview() {
    final items = _selectedItems;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(26),
        border: Border.all(
          color: AppTheme.lightBrown,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your outfit',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                  AppTheme.lightBrown,
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: const Text(
                  'SMART MATCH',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.brown,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics:
            const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.82,
            ),
            itemBuilder:
                (context, index) {
              return _buildPreviewItem(
                items[index],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(
      ClothingItem item,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.lightBrown,
        ),
      ),
      clipBehavior:
      Clip.antiAlias,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: item.imagePath != null
                  ? Image.file(
                File(item.imagePath!),
                fit: BoxFit.cover,
                errorBuilder:
                    (context,
                    error,
                    stackTrace) {
                  return _buildImagePlaceholder();
                },
              )
                  : _buildImagePlaceholder(),
            ),
          ),

          Padding(
            padding:
            const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w600,
                    color:
                    AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.color} • ${item.style}',
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color:
                    AppTheme.grayText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppTheme.lightBrown,
      child: const Center(
        child: Icon(
          Icons.checkroom_outlined,
          size: 42,
          color: AppTheme.brown,
        ),
      ),
    );
  }

  Widget _buildColorMatchCard() {
    final score =
    _calculateColorScore();

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
        _colorMatchBackground(score),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildScoreCircle(
            score,
            _colorMatchTextColor(score),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  _colorMatchText(score),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.bold,
                    color:
                    _colorMatchTextColor(
                        score),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Color compatibility',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                    _colorMatchTextColor(
                        score),
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.palette_outlined,
            color: AppTheme.brown,
          ),
        ],
      ),
    );
  }

  Widget _buildStyleMatchCard() {
    final score =
    _calculateStyleScore();

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
        _styleMatchBackground(score),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildScoreCircle(
            score,
            _styleMatchTextColor(score),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  _styleMatchText(score),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.bold,
                    color:
                    _styleMatchTextColor(
                        score),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Style compatibility',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                    _styleMatchTextColor(
                        score),
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.auto_awesome_outlined,
            color: AppTheme.brown,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCircle(
      int score,
      Color textColor,
      ) {
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$score',
          style: TextStyle(
            fontSize: 18,
            fontWeight:
            FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildShuffleAgainButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _shuffleAll,
        icon: const Icon(
          Icons.shuffle,
        ),
        label: const Text(
          'Shuffle Again',
          style: TextStyle(
            fontSize: 16,
            fontWeight:
            FontWeight.bold,
          ),
        ),
        style:
        ElevatedButton.styleFrom(
          backgroundColor:
          AppTheme.brown,
          foregroundColor:
          Colors.white,
          elevation: 0,
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _buildClothingSection({
    required String label,
    required ClothingItem? item,
    required VoidCallback onShuffle,
  }) {
    return Container(
      padding:
      const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color:
          AppTheme.lightBrown,
        ),
      ),
      child: Row(
        children: [
          _buildSmallImage(item),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color:
                    AppTheme.grayText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item?.name ??
                      'Not selected',
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w600,
                    color:
                    AppTheme.darkText,
                  ),
                ),
                if (item != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    '${item.color} • ${item.style}',
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style:
                    const TextStyle(
                      fontSize: 12,
                      color:
                      AppTheme.grayText,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          IconButton(
            onPressed: onShuffle,
            tooltip:
            'Shuffle $label',
            style:
            IconButton.styleFrom(
              backgroundColor:
              AppTheme.lightBrown,
              foregroundColor:
              AppTheme.brown,
            ),
            icon: const Icon(
              Icons.shuffle,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallImage(
      ClothingItem? item,
      ) {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(14),
      child: SizedBox(
        width: 64,
        height: 64,
        child: item?.imagePath != null
            ? Image.file(
          File(
            item!.imagePath!,
          ),
          fit: BoxFit.cover,
          errorBuilder:
              (context,
              error,
              stackTrace) {
            return _buildImagePlaceholder();
          },
        )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed:
        _isSaving
            ? null
            : _saveOutfit,
        icon: _isSaving
            ? const SizedBox(
          width: 18,
          height: 18,
          child:
          CircularProgressIndicator(
            strokeWidth: 2,
          ),
        )
            : const Icon(
          Icons.favorite_border,
        ),
        label: Text(
          _isSaving
              ? 'Saving...'
              : 'Save Outfit',
          style: const TextStyle(
            fontSize: 16,
            fontWeight:
            FontWeight.bold,
          ),
        ),
        style:
        OutlinedButton.styleFrom(
          foregroundColor:
          AppTheme.brown,
          side: const BorderSide(
            color: AppTheme.brown,
          ),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _buildMissingItemsState() {
    final missing = <String>[];

    if (_tops.isEmpty) {
      missing.add('Top');
    }

    if (_bottoms.isEmpty) {
      missing.add('Bottom');
    }

    if (_shoes.isEmpty) {
      missing.add('Shoes');
    }

    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration:
              BoxDecoration(
                color:
                AppTheme.lightBrown,
                borderRadius:
                BorderRadius.circular(
                    30),
              ),
              child: const Icon(
                Icons.checkroom_outlined,
                size: 45,
                color:
                AppTheme.brown,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            const Text(
              'Your wardrobe needs a few more items',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                FontWeight.bold,
                color:
                AppTheme.darkText,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              'Add at least ${missing.join(', ')} to generate an outfit.',
              textAlign:
              TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color:
                AppTheme.grayText,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                AppTheme.brown,
                foregroundColor:
                Colors.white,
                elevation: 0,
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                      16),
                ),
              ),
              child: const Text(
                'Back to Wardrobe',
              ),
            ),
          ],
        ),
      ),
    );
  }
}