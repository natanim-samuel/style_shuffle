import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/clothing_item.dart';
import '../../providers/wardrobe_provider.dart';
import 'add_clothing_screen.dart';

class WardrobeScreen extends StatefulWidget {
  final WardrobeProvider wardrobeProvider;

  const WardrobeScreen({
    super.key,
    required this.wardrobeProvider,
  });

  @override
  State<WardrobeScreen> createState() =>
      _WardrobeScreenState();
}

class _WardrobeScreenState
    extends State<WardrobeScreen> {
  String selectedCategory = 'All';
  String searchText = '';

  final TextEditingController searchController =
  TextEditingController();

  final List<String> categories = [
    'All',
    'Tops',
    'Bottoms',
    'Shoes',
    'Outerwear',
    'Accessories',
  ];

  @override
  void initState() {
    super.initState();

    widget.wardrobeProvider.addListener(_refresh);

    widget.wardrobeProvider.loadItems();
  }

  @override
  void dispose() {
    widget.wardrobeProvider.removeListener(_refresh);
    searchController.dispose();

    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  List<ClothingItem> get filteredItems {
    var result = widget.wardrobeProvider.getByCategory(
      selectedCategory,
    );

    if (searchText.trim().isNotEmpty) {
      final search = searchText.toLowerCase();

      result = result.where((item) {
        return item.name.toLowerCase().contains(search) ||
            item.color.toLowerCase().contains(search) ||
            item.style.toLowerCase().contains(search);
      }).toList();
    }

    return result;
  }

  Future<void> openAddClothing() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddClothingScreen(
          wardrobeProvider: widget.wardrobeProvider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clothes = filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Wardrobe',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: openAddClothing,

            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              16,
            ),

            child: TextField(
              controller: searchController,

              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },

              decoration: InputDecoration(
                hintText: 'Search clothes...',

                prefixIcon: const Icon(
                  Icons.search,
                ),

                suffixIcon:
                searchText.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    searchController.clear();

                    setState(() {
                      searchText = '';
                    });
                  },
                  icon: const Icon(
                    Icons.close,
                  ),
                )
                    : null,

                filled: true,

                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(16),

                  borderSide: const BorderSide(
                    color: Color(0xFFEDE5DE),
                  ),
                ),

                enabledBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(16),

                  borderSide: const BorderSide(
                    color: Color(0xFFEDE5DE),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 45,

            child: ListView.builder(
              scrollDirection: Axis.horizontal,

              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              itemCount: categories.length,

              itemBuilder: (context, index) {
                final category =
                categories[index];

                final isSelected =
                    selectedCategory == category;

                return Padding(
                  padding:
                  const EdgeInsets.only(
                    right: 10,
                  ),

                  child: ChoiceChip(
                    label: Text(category),

                    selected: isSelected,

                    onSelected: (_) {
                      setState(() {
                        selectedCategory =
                            category;
                      });
                    },

                    selectedColor:
                    const Color(0xFFE8D8C8),

                    backgroundColor:
                    Colors.white,

                    labelStyle: TextStyle(
                      color: isSelected
                          ? const Color(
                        0xFF5C4033,
                      )
                          : const Color(
                        0xFF8A817C,
                      ),

                      fontWeight:
                      isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),

                    side: const BorderSide(
                      color: Color(0xFFEDE5DE),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: clothes.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
              padding:
              const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                100,
              ),

              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,

                crossAxisSpacing: 14,

                mainAxisSpacing: 14,

                childAspectRatio: 0.72,
              ),

              itemCount: clothes.length,

              itemBuilder: (context, index) {
                return _ClothingCard(
                  item: clothes[index],

                  onDelete: () {
                    _deleteItem(
                      clothes[index],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddClothing,

        backgroundColor:
        const Color(0xFF5C4033),

        foregroundColor: Colors.white,

        icon: const Icon(Icons.add),

        label: const Text('Add Clothes'),
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
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: const Color(0xFFF4ECE6),

                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.checkroom_outlined,
                size: 60,
                color: Color(0xFF8A817C),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Your wardrobe is empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Add your clothes and start creating outfits.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF8A817C),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: openAddClothing,

              icon: const Icon(Icons.add),

              label: const Text('Add Your First Item'),

              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF5C4033),

                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteItem(
      ClothingItem item,
      ) async {
    final shouldDelete =
    await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete clothing?',
          ),

          content: Text(
            'Remove "${item.name}" from your wardrobe?',
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
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await widget.wardrobeProvider.deleteItem(
        item.id,
      );
    }
  }
}

class _ClothingCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback onDelete;

  const _ClothingCard({
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: const Color(0xFFEDE5DE),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.03,
            ),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),

                  child: item.imagePath != null
                      ? Image.file(
                    File(item.imagePath!),

                    width: double.infinity,

                    height: double.infinity,

                    fit: BoxFit.cover,
                  )
                      : Container(
                    width: double.infinity,

                    height: double.infinity,

                    color:
                    const Color(0xFFF4ECE6),

                    child: Icon(
                      _categoryIcon(
                        item.category,
                      ),

                      size: 60,

                      color:
                      const Color(
                        0xFFB7A69A,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 8,
                  right: 8,

                  child: Material(
                    color: Colors.white
                        .withValues(alpha: 0.9),

                    shape:
                    const CircleBorder(),

                    child: IconButton(
                      onPressed: onDelete,

                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                      ),

                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),

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
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${item.color} • ${item.style}',

                  maxLines: 1,

                  overflow:
                  TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Color(0xFF8A817C),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  item.category,

                  style: const TextStyle(
                    color: Color(0xFF5C4033),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Tops':
        return Icons.checkroom;

      case 'Bottoms':
        return Icons.accessibility_new;

      case 'Shoes':
        return Icons.directions_walk;

      case 'Outerwear':
        return Icons.dry_cleaning;

      case 'Accessories':
        return Icons.watch;

      default:
        return Icons.checkroom;
    }
  }
}