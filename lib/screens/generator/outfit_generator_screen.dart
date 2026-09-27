import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/clothing_item.dart';
import '../../providers/wardrobe_provider.dart';
import '../../theme/app_theme.dart';

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
final Random _random = Random();

// Currently selected outfit items.
ClothingItem? _selectedTop;
ClothingItem? _selectedBottom;
ClothingItem? _selectedShoes;
ClothingItem? _selectedOuterwear;
ClothingItem? _selectedAccessory;

bool _hasGenerated = false;

// ------------------------------------------------------------
// WARDROBE LISTS
// ------------------------------------------------------------

List<ClothingItem> get _tops {
return widget.wardrobeProvider.getByCategory('Tops');
}

List<ClothingItem> get _bottomItems {
return widget.wardrobeProvider.getByCategory('Bottoms');
}

List<ClothingItem> get _shoeItems {
return widget.wardrobeProvider.getByCategory('Shoes');
}

List<ClothingItem> get _outerwearItems {
return widget.wardrobeProvider.getByCategory('Outerwear');
}

List<ClothingItem> get _accessoryItems {
return widget.wardrobeProvider.getByCategory('Accessories');
}

@override
void initState() {
super.initState();

WidgetsBinding.instance.addPostFrameCallback((_) {
_generateSmartOutfit();
});
}

// ------------------------------------------------------------
// SMART OUTFIT GENERATION
// ------------------------------------------------------------

void _generateSmartOutfit() {
if (_tops.isEmpty ||
_bottomItems.isEmpty ||
_shoeItems.isEmpty) {
setState(() {
_hasGenerated = false;
});
return;
}

ClothingItem bestTop = _tops.first;
ClothingItem bestBottom = _bottomItems.first;
ClothingItem bestShoes = _shoeItems.first;

int bestScore = -1;

// Check every possible top + bottom + shoes combination.
for (final top in _tops) {
for (final bottom in _bottomItems) {
for (final shoes in _shoeItems) {
final score = _calculateOutfitScore(
top: top,
bottom: bottom,
shoes: shoes,
);

if (score > bestScore) {
bestScore = score;
bestTop = top;
bestBottom = bottom;
bestShoes = shoes;
}
}
}
}

ClothingItem? selectedOuterwear;

if (_outerwearItems.isNotEmpty) {
selectedOuterwear = _findBestAdditionalItem(
_outerwearItems,
bestTop,
bestBottom,
bestShoes,
);
}

ClothingItem? selectedAccessory;

if (_accessoryItems.isNotEmpty) {
selectedAccessory = _findBestAdditionalItem(
_accessoryItems,
bestTop,
bestBottom,
bestShoes,
);
}

setState(() {
_selectedTop = bestTop;
_selectedBottom = bestBottom;
_selectedShoes = bestShoes;
_selectedOuterwear = selectedOuterwear;
_selectedAccessory = selectedAccessory;
_hasGenerated = true;
});
}

// ------------------------------------------------------------
// OUTFIT SCORE
// ------------------------------------------------------------

int _calculateOutfitScore({
required ClothingItem top,
required ClothingItem bottom,
required ClothingItem shoes,
}) {
int score = 0;

// Color matching.
score += _colorCompatibility(
top.color,
bottom.color,
);

score += _colorCompatibility(
top.color,
shoes.color,
);

score += _colorCompatibility(
bottom.color,
shoes.color,
);

// Style matching.
if (top.style == bottom.style) {
score += 20;
} else if (_stylesCompatible(
top.style,
bottom.style,
)) {
score += 10;
}

if (shoes.style == top.style) {
score += 15;
} else if (_stylesCompatible(
shoes.style,
top.style,
)) {
score += 8;
}

// Season matching.
if (top.season == bottom.season) {
score += 10;
}

if (shoes.season == top.season) {
score += 5;
}

return score;
}

// ------------------------------------------------------------
// COLOR COMPATIBILITY
// ------------------------------------------------------------

int _colorCompatibility(
String color1,
String color2,
) {
final a = color1.toLowerCase();
final b = color2.toLowerCase();

// Same color.
if (a == b) {
return 8;
}

// Neutral colors work with almost everything.
const neutrals = [
'black',
'white',
'beige',
'brown',
'gray',
];

if (neutrals.contains(a) ||
neutrals.contains(b)) {
return 10;
}

// Common combinations.
final combinations = <String>{
'blue_white',
'white_blue',
'blue_beige',
'beige_blue',
'blue_brown',
'brown_blue',
'green_beige',
'beige_green',
'green_brown',
'brown_green',
'red_black',
'black_red',
'red_white',
'white_red',
'pink_white',
'white_pink',
'purple_white',
'white_purple',
'yellow_blue',
'blue_yellow',
'orange_blue',
'blue_orange',
};

if (combinations.contains('${a}_$b')) {
return 12;
}

// Same general color family.
if (_sameColorFamily(a, b)) {
return 7;
}

// Different colors with less compatibility.
return 2;
}

bool _sameColorFamily(
String color1,
String color2,
) {
const warmColors = [
'red',
'orange',
'yellow',
'pink',
];

const coolColors = [
'blue',
'green',
'purple',
];

if (warmColors.contains(color1) &&
warmColors.contains(color2)) {
return true;
}

if (coolColors.contains(color1) &&
coolColors.contains(color2)) {
return true;
}

return false;
}

// ------------------------------------------------------------
// STYLE COMPATIBILITY
// ------------------------------------------------------------

bool _stylesCompatible(
String style1,
String style2,
) {
final a = style1.toLowerCase();
final b = style2.toLowerCase();

if ((a == 'casual' && b == 'smart casual') ||
(a == 'smart casual' && b == 'casual')) {
return true;
}

if ((a == 'streetwear' && b == 'casual') ||
(a == 'casual' && b == 'streetwear')) {
return true;
}

if ((a == 'formal' && b == 'smart casual') ||
(a == 'smart casual' && b == 'formal')) {
return true;
}

if ((a == 'sport' && b == 'casual') ||
(a == 'casual' && b == 'sport')) {
return true;
}

return false;
}

// ------------------------------------------------------------
// ADDITIONAL ITEMS
// ------------------------------------------------------------

ClothingItem? _findBestAdditionalItem(
List<ClothingItem> items,
ClothingItem top,
ClothingItem bottom,
ClothingItem shoes,
) {
ClothingItem? best;
int bestScore = -1;

for (final item in items) {
int score = 0;

score += _colorCompatibility(
item.color,
top.color,
);

score += _colorCompatibility(
item.color,
bottom.color,
);

score += _colorCompatibility(
item.color,
shoes.color,
);

if (item.style == top.style) {
score += 15;
}

if (item.style == bottom.style) {
score += 10;
}

if (score > bestScore) {
bestScore = score;
best = item;
}
}

return best;
}

// ------------------------------------------------------------
// INDIVIDUAL SHUFFLE
// ------------------------------------------------------------

void _shuffleTop() {
if (_tops.isEmpty) return;

setState(() {
_selectedTop = _getRandomDifferent(
_tops,
_selectedTop,
);
});
}

void _shuffleBottom() {
if (_bottomItems.isEmpty) return;

setState(() {
_selectedBottom = _getRandomDifferent(
_bottomItems,
_selectedBottom,
);
});
}

void _shuffleShoes() {
if (_shoeItems.isEmpty) return;

setState(() {
_selectedShoes = _getRandomDifferent(
_shoeItems,
_selectedShoes,
);
});
}

void _shuffleOuterwear() {
if (_outerwearItems.isEmpty) return;

setState(() {
_selectedOuterwear = _getRandomDifferent(
_outerwearItems,
_selectedOuterwear,
);
});
}

void _shuffleAccessory() {
if (_accessoryItems.isEmpty) return;

setState(() {
_selectedAccessory = _getRandomDifferent(
_accessoryItems,
_selectedAccessory,
);
});
}

ClothingItem _getRandomDifferent(
List<ClothingItem> items,
ClothingItem? current,
) {
if (items.length == 1) {
return items.first;
}

final available = items
    .where(
(item) => item.id != current?.id,
)
    .toList();

return available[
_random.nextInt(available.length)];
}

// ------------------------------------------------------------
// MAIN BUILD
// ------------------------------------------------------------

@override
Widget build(BuildContext context) {
final hasEnoughClothes =
_tops.isNotEmpty &&
_bottomItems.isNotEmpty &&
_shoeItems.isNotEmpty;

return Scaffold(
appBar: AppBar(
title: const Text('Outfit Generator'),
),
body: !hasEnoughClothes
? _buildNotEnoughClothes()
    : !_hasGenerated
? const Center(
child: CircularProgressIndicator(),
)
    : _buildGenerator(),
);
}

// ------------------------------------------------------------
// NOT ENOUGH CLOTHES
// ------------------------------------------------------------

Widget _buildNotEnoughClothes() {
return Center(
child: Padding(
padding: const EdgeInsets.all(24),
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
const SizedBox(height: 12),
const Text(
'Add at least one top, one bottom, and one pair of shoes to generate an outfit.',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 15,
color: AppTheme.grayText,
),
),
],
),
),
);
}

// ------------------------------------------------------------
// GENERATOR UI
// ------------------------------------------------------------

Widget _buildGenerator() {
return SingleChildScrollView(
padding: const EdgeInsets.fromLTRB(
20,
12,
20,
30,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Your Outfit',
style: TextStyle(
fontSize: 28,
fontWeight: FontWeight.bold,
color: AppTheme.darkText,
),
),
const SizedBox(height: 6),
const Text(
'A smart combination from your wardrobe.',
style: TextStyle(
fontSize: 14,
color: AppTheme.grayText,
),
),
const SizedBox(height: 24),

// TOP
_buildItemSection(
label: 'Top',
item: _selectedTop!,
onShuffle: _shuffleTop,
),

const SizedBox(height: 14),

// BOTTOM
_buildItemSection(
label: 'Bottom',
item: _selectedBottom!,
onShuffle: _shuffleBottom,
),

const SizedBox(height: 14),

// SHOES
_buildItemSection(
label: 'Shoes',
item: _selectedShoes!,
onShuffle: _shuffleShoes,
),

// OUTERWEAR
if (_selectedOuterwear != null) ...[
const SizedBox(height: 14),
_buildItemSection(
label: 'Outerwear',
item: _selectedOuterwear!,
onShuffle: _shuffleOuterwear,
),
],

// ACCESSORY
if (_selectedAccessory != null) ...[
const SizedBox(height: 14),
_buildItemSection(
label: 'Accessory',
item: _selectedAccessory!,
onShuffle: _shuffleAccessory,
),
],

const SizedBox(height: 28),

// ACTION BUTTONS
Row(
children: [
Expanded(
child: OutlinedButton.icon(
onPressed: _generateSmartOutfit,
icon: const Icon(
Icons.shuffle,
),
label: const Text(
'Smart Shuffle',
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
BorderRadius.circular(16),
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
'Favorites are coming next ❤️',
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
BorderRadius.circular(16),
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

// ------------------------------------------------------------
// ITEM CARD
// ------------------------------------------------------------

Widget _buildItemSection({
required String label,
required ClothingItem item,
required VoidCallback onShuffle,
}) {
return Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
mainAxisAlignment:
MainAxisAlignment.spaceBetween,
children: [
Text(
label,
style: const TextStyle(
fontSize: 15,
fontWeight: FontWeight.w700,
color: AppTheme.darkText,
),
),
IconButton(
onPressed: onShuffle,
tooltip: 'Shuffle $label',
icon: const Icon(
Icons.refresh_rounded,
size: 21,
),
color: AppTheme.brown,
),
],
),
const SizedBox(height: 5),
Container(
height: 100,
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: AppTheme.lightBrown,
),
),
child: Row(
children: [
_buildImage(item),
const SizedBox(width: 16),
Expanded(
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
item.name,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: const TextStyle(
fontSize: 16,
fontWeight:
FontWeight.w700,
color:
AppTheme.darkText,
),
),
const SizedBox(height: 6),
Text(
'${item.color} • ${item.style}',
style: const TextStyle(
fontSize: 13,
color:
AppTheme.grayText,
),
),
const SizedBox(height: 4),
Text(
item.season,
style: const TextStyle(
fontSize: 12,
color:
AppTheme.grayText,
),
),
],
),
),
const SizedBox(width: 12),
],
),
),
],
);
}

// ------------------------------------------------------------
// IMAGE
// ------------------------------------------------------------

Widget _buildImage(ClothingItem item) {
return ClipRRect(
borderRadius: const BorderRadius.only(
topLeft: Radius.circular(20),
bottomLeft: Radius.circular(20),
),
child: SizedBox(
width: 100,
height: 100,
child: item.imagePath != null
? Image.file(
File(item.imagePath!),
fit: BoxFit.cover,
errorBuilder:
(context, error, stackTrace) {
return _buildPlaceholder(item);
},
)
    : _buildPlaceholder(item),
),
);
}

// ------------------------------------------------------------
// IMAGE PLACEHOLDER
// ------------------------------------------------------------

Widget _buildPlaceholder(
ClothingItem item,
) {
return Container(
color: AppTheme.lightBrown,
child: Icon(
_categoryIcon(item.category),
size: 35,
color: AppTheme.brown,
),
);
}

// ------------------------------------------------------------
// CATEGORY ICON
// ------------------------------------------------------------

IconData _categoryIcon(
String category,
) {
switch (category) {
case 'Tops':
return Icons.checkroom_outlined;

case 'Bottoms':
return Icons.accessibility_new;

case 'Shoes':
return Icons.directions_walk_outlined;

case 'Outerwear':
return Icons.dry_cleaning_outlined;

case 'Accessories':
return Icons.watch_outlined;

default:
return Icons.checkroom_outlined;
}
}
}

