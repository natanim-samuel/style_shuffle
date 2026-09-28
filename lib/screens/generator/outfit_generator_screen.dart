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
        .where((item) => item.id != current?.id)
        .toList();

    if (available.isEmpty) {
      return items.first;
    }

    return available[_random.nextInt(available.length)];
  }

  void _shuffleAll() {
    setState(() {
      _selectedTop = _randomItem(_tops);
      _selectedBottom = _randomItem(_bottoms);
      _selectedShoes = _randomItem(_shoes);

      _selectedOuterwear = _outerwear.isEmpty
          ? null
          : _randomItem(_outerwear);

      _selectedAccessory = _accessories.isEmpty
          ? null
          : _randomItem(_accessories);

      _hasGenerated = true;
    });
  }

  void _shuffleTop() {
    if (_tops.isEmpty) {
      _showMessage('Add some tops to your wardrobe first.');
      return;
    }

    setState(() {
      _selectedTop = _randomItem(
        _tops,
        current: _selectedTop,
      );
      _hasGenerated = true;
    });
  }

  void _shuffleBottom() {
    if (_bottoms.isEmpty) {
      _showMessage('Add some bottoms to your wardrobe first.');
      return;
    }

    setState(() {
      _selectedBottom = _randomItem(
        _bottoms,
        current: _selectedBottom,
      );
      _hasGenerated = true;
    });
  }

  void _shuffleShoes() {
    if (_shoes.isEmpty) {
      _showMessage('Add some shoes to your wardrobe first.');
      return;
    }

    setState(() {
      _selectedShoes = _randomItem(
        _shoes,
        current: _selectedShoes,
      );
      _hasGenerated = true;
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
      _selectedOuterwear = _randomItem(
        _outerwear,
        current: _selectedOuterwear,
      );
      _hasGenerated = true;
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
      _selectedAccessory = _randomItem(
        _accessories,
        current: _selectedAccessory,
      );
      _hasGenerated = true;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    final hasEnoughItems =
        _tops.isNotEmpty &&
            _bottoms.isNotEmpty &&
            _shoes.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Generator'),
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
              'Shuffle individual pieces without changing the rest.',
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
              ? 'Here is a random outfit from your wardrobe.'
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
    final items = [
      _selectedTop,
      _selectedBottom,
      _selectedShoes,
      _selectedOuterwear,
      _selectedAccessory,
    ].whereType<ClothingItem>().toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.lightBrown,
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: const Text(
                  'STYLE',
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
            itemBuilder: (context, index) {
              return _buildPreviewItem(
                items[index],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(ClothingItem item) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.lightBrown,
        ),
      ),
      clipBehavior: Clip.antiAlias,
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
                    (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              )
                  : _buildImagePlaceholder(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.color} • ${item.style}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.grayText,
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
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.brown,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.lightBrown,
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
                    color: AppTheme.grayText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item?.name ?? 'Not selected',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkText,
                  ),
                ),
                if (item != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    '${item.color} • ${item.style}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.grayText,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          IconButton(
            onPressed: onShuffle,
            tooltip: 'Shuffle $label',
            style: IconButton.styleFrom(
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

  Widget _buildSmallImage(ClothingItem? item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 64,
        height: 64,
        child: item?.imagePath != null
            ? Image.file(
          File(item!.imagePath!),
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) {
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
        _isSaving ? null : _saveOutfit,
        icon: _isSaving
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
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
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.brown,
          side: const BorderSide(
            color: AppTheme.brown,
          ),
          shape: RoundedRectangleBorder(
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
        padding: const EdgeInsets.all(30),
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
                Icons.checkroom_outlined,
                size: 45,
                color: AppTheme.brown,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Your wardrobe needs a few more items',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Add at least ${missing.join(', ')} to generate an outfit.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.grayText,
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brown,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(16),
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