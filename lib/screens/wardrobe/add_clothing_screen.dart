import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/clothing_item.dart';
import '../../providers/wardrobe_provider.dart';

class AddClothingScreen extends StatefulWidget {
  final WardrobeProvider wardrobeProvider;

  const AddClothingScreen({
    super.key,
    required this.wardrobeProvider,
  });

  @override
  State<AddClothingScreen> createState() =>
      _AddClothingScreenState();
}

class _AddClothingScreenState
    extends State<AddClothingScreen> {
  final TextEditingController nameController =
  TextEditingController();

  final ImagePicker imagePicker = ImagePicker();

  String selectedCategory = 'Tops';
  String selectedColor = 'White';
  String selectedStyle = 'Casual';
  String selectedSeason = 'All Season';

  String? imagePath;

  final List<String> categories = [
    'Tops',
    'Bottoms',
    'Shoes',
    'Outerwear',
    'Accessories',
  ];

  final List<String> colors = [
    'Black',
    'White',
    'Brown',
    'Beige',
    'Blue',
    'Red',
    'Green',
    'Yellow',
    'Pink',
    'Purple',
    'Gray',
    'Orange',
  ];

  final List<String> styles = [
    'Casual',
    'Formal',
    'Streetwear',
    'Sport',
    'Smart Casual',
  ];

  final List<String> seasons = [
    'All Season',
    'Spring',
    'Summer',
    'Autumn',
    'Winter',
  ];

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) {
      return;
    }

    setState(() {
      imagePath = image.path;
    });
  }

  Future<void> saveClothing() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a clothing name.'),
        ),
      );

      return;
    }

    final clothingItem = ClothingItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      category: selectedCategory,
      color: selectedColor,
      style: selectedStyle,
      season: selectedSeason,
      imagePath: imagePath,
      createdAt: DateTime.now(),
    );

    await widget.wardrobeProvider.addItem(
      clothingItem,
    );

    if (!mounted) {
      return;
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Clothing added to your wardrobe! 👕'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Clothing'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Center(
              child: GestureDetector(
                onTap: pickImage,

                child: Container(
                  width: 180,
                  height: 180,

                  decoration: BoxDecoration(
                    color: const Color(0xFFF4ECE6),

                    borderRadius:
                    BorderRadius.circular(24),

                    border: Border.all(
                      color: const Color(0xFFE4D7CD),
                    ),
                  ),

                  child: imagePath == null
                      ? const Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,

                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: 42,
                        color: Color(0xFF8A817C),
                      ),

                      SizedBox(height: 12),

                      Text(
                        'Add Photo',
                        style: TextStyle(
                          fontWeight:
                          FontWeight.w600,
                          color:
                          Color(0xFF8A817C),
                        ),
                      ),
                    ],
                  )
                      : ClipRRect(
                    borderRadius:
                    BorderRadius.circular(24),

                    child: Image.file(
                      File(imagePath!),
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Clothing Name',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: nameController,

              decoration: InputDecoration(
                hintText: 'Example: White T-Shirt',

                filled: true,

                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(14),

                  borderSide: const BorderSide(
                    color: Color(0xFFEDE5DE),
                  ),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(14),

                  borderSide: const BorderSide(
                    color: Color(0xFFEDE5DE),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            _buildDropdown(
              title: 'Category',
              value: selectedCategory,
              values: categories,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            _buildDropdown(
              title: 'Color',
              value: selectedColor,
              values: colors,
              onChanged: (value) {
                setState(() {
                  selectedColor = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            _buildDropdown(
              title: 'Style',
              value: selectedStyle,
              values: styles,
              onChanged: (value) {
                setState(() {
                  selectedStyle = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            _buildDropdown(
              title: 'Season',
              value: selectedSeason,
              values: seasons,
              onChanged: (value) {
                setState(() {
                  selectedSeason = value!;
                });
              },
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 54,

              child: ElevatedButton.icon(
                onPressed: saveClothing,

                icon: const Icon(
                  Icons.check,
                ),

                label: const Text(
                  'Add to Wardrobe',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF5C4033),

                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String title,
    required String value,
    required List<String> values,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 10),

        DropdownButtonFormField<String>(
          initialValue: value,

          items: values.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),

          onChanged: onChanged,

          decoration: InputDecoration(
            filled: true,

            fillColor: Colors.white,

            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(14),

              borderSide: const BorderSide(
                color: Color(0xFFEDE5DE),
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(14),

              borderSide: const BorderSide(
                color: Color(0xFFEDE5DE),
              ),
            ),
          ),
        ),
      ],
    );
  }
}