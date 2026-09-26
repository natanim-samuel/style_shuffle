import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/clothing_item.dart';
import '../../models/outfit.dart';
import '../../providers/wardrobe_provider.dart';

class OutfitGeneratorScreen extends StatefulWidget {
  final WardrobeProvider wardrobeProvider;

  const OutfitGeneratorScreen({
    super.key,
    required this.wardrobeProvider,
  });

  @override
  State<OutfitGeneratorScreen> createState() =>
      _OutfitGeneratorScreenState();
}

class _OutfitGeneratorScreenState
    extends State<OutfitGeneratorScreen> {
  Outfit? generatedOutfit;

  final Random random = Random();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Outfit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: generatedOutfit == null
          ? _buildStartScreen()
          : _buildOutfitScreen(),
    );
  }

  Widget _buildStartScreen() {
    final itemCount =
        widget.wardrobeProvider.items.length;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            Container(
              padding: const EdgeInsets.all(30),

              decoration: BoxDecoration(
                color: const Color(0xFFF4ECE6),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.auto_awesome,
                size: 70,
                color: Color(0xFF5C4033),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Create Your Outfit',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              itemCount < 3
                  ? 'Add at least 3 clothing items first.'
                  : 'Let StyleShuffle create a look for you.',
              textAlign: TextAlign.center,

              style: const TextStyle(
                color: Color(0xFF8A817C),
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 54,

              child: ElevatedButton.icon(
                onPressed:
                itemCount >= 3
                    ? generateOutfit
                    : null,

                icon: const Icon(
                  Icons.shuffle,
                ),

                label: const Text(
                  'Generate Outfit',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF5C4033),

                  foregroundColor: Colors.white,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitScreen() {
    final outfit = generatedOutfit!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          const Text(
            'Your Outfit ✨',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Here is your randomly generated look.',
            style: TextStyle(
              color: Color(0xFF8A817C),
            ),
          ),

          const SizedBox(height: 25),

          if (outfit.top != null)
            _OutfitItemCard(
              item: outfit.top!,
              label: 'TOP',
            ),

          if (outfit.bottom != null)
            _OutfitItemCard(
              item: outfit.bottom!,
              label: 'BOTTOM',
            ),

          if (outfit.shoes != null)
            _OutfitItemCard(
              item: outfit.shoes!,
              label: 'SHOES',
            ),

          if (outfit.outerwear != null)
            _OutfitItemCard(
              item: outfit.outerwear!,
              label: 'OUTERWEAR',
            ),

          if (outfit.accessory != null)
            _OutfitItemCard(
              item: outfit.accessory!,
              label: 'ACCESSORY',
            ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: generateOutfit,

                  icon: const Icon(
                    Icons.shuffle,
                  ),

                  label: const Text(
                    'Shuffle',
                  ),

                  style:
                  OutlinedButton.styleFrom(
                    foregroundColor:
                    const Color(
                      0xFF5C4033,
                    ),

                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 15,
                    ),

                    side:
                    const BorderSide(
                      color: Color(
                        0xFF5C4033,
                      ),
                    ),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Favorite feature coming next ❤️',
                        ),
                      ),
                    );
                  },

                  icon: const Icon(
                    Icons.favorite_border,
                  ),

                  label: const Text(
                    'Save',
                  ),

                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(
                      0xFF5C4033,
                    ),

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
                        14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void generateOutfit() {
    final items =
        widget.wardrobeProvider.items;

    final tops = items
        .where(
          (item) => item.category == 'Tops',
    )
        .toList();

    final bottoms = items
        .where(
          (item) => item.category == 'Bottoms',
    )
        .toList();

    final shoes = items
        .where(
          (item) => item.category == 'Shoes',
    )
        .toList();

    final outerwear = items
        .where(
          (item) => item.category == 'Outerwear',
    )
        .toList();

    final accessories = items
        .where(
          (item) => item.category == 'Accessories',
    )
        .toList();

    if (tops.isEmpty ||
        bottoms.isEmpty ||
        shoes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You need at least one top, bottom, and pair of shoes.',
          ),
        ),
      );

      return;
    }

    setState(() {
      generatedOutfit = Outfit(
        id: DateTime.now()
            .microsecondsSinceEpoch
            .toString(),

        top: _randomItem(tops),

        bottom: _randomItem(bottoms),

        shoes: _randomItem(shoes),

        outerwear:
        outerwear.isNotEmpty
            ? _randomItem(outerwear)
            : null,

        accessory:
        accessories.isNotEmpty
            ? _randomItem(accessories)
            : null,

        createdAt: DateTime.now(),
      );
    });
  }

  ClothingItem _randomItem(
      List<ClothingItem> items,
      ) {
    return items[
    random.nextInt(items.length)
    ];
  }
}

class _OutfitItemCard extends StatelessWidget {
  final ClothingItem item;
  final String label;

  const _OutfitItemCard({
    required this.item,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(20),

        border: Border.all(
          color: const Color(0xFFEDE5DE),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,

            decoration: const BoxDecoration(
              color: Color(0xFFF4ECE6),

              borderRadius:
              BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
            ),

            child: item.imagePath != null
                ? ClipRRect(
              borderRadius:
              const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),

              child:Image.file(
                File(item.imagePath!),
                fit: BoxFit.cover,
              )
            )
                : const Icon(
              Icons.checkroom_outlined,
              size: 40,
              color: Color(0xFFB7A69A),
            ),
          ),

          Expanded(
            child: Padding(
              padding:
              const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Text(
                    label,

                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(
                        0xFF8A817C,
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    item.name,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '${item.color} • ${item.style}',

                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(
                        0xFF8A817C,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}