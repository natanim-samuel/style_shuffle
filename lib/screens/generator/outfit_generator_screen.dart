```dart
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

ClothingItem? _top;
ClothingItem? _bottom;
ClothingItem? _shoes;
ClothingItem? _outerwear;
ClothingItem? _accessory;

bool _hasGenerated = false;

List<ClothingItem> get _tops {
return widget.wardrobeProvider
    .getByCategory('Tops');
}

List<ClothingItem> get _bottoms {
return widget.wardrobeProvider
    .getByCategory('Bottoms');
}

List<ClothingItem> get _shoeItems {
return widget.wardrobeProvider
    .getByCategory('Shoes');
}

List<ClothingItem> get _outerwear {
return widget.wardrobeProvider
    .getByCategory('Outerwear');
}

List<ClothingItem> get _accessories {
return widget.wardrobeProvider
    .getByCategory('Accessories');
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
_bottoms.isEmpty ||
_shoes.isEmpty) {
setState(() {
_hasGenerated = false;
});
return;
}

ClothingItem bestTop = _tops.first;
ClothingItem bestBottom = _bottoms.first;
ClothingItem bestShoes = _shoes.first;

int bestScore = -1;

for (final top in _tops) {
for (final bottom in _bottoms) {
for (final shoes in _shoes) {
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
ClothingItem? selectedAccessory;

if (_outerwear.isNotEmpty) {
selectedOuterwear =
_findBestAdditionalItem(
_outerwear,
bestTop,
bestBottom,
bestShoes,
);
}

if (_accessories.isNotEmpty) {
selectedAccessory =
_findBestAdditionalItem(
_accessories,
bestTop,
bestBottom,
bestShoes,
);
}

setState(() {
_top = bestTop;
_bottom = bestBottom;
_shoes = _shoes;
_shoes = bestShoes;
_outerwear = _outerwear;
_accessory = selectedAccessory;
_outerwear = _outerwear;
_hasGenerated = true;
});
}

int _calculateOutfitScore({
required ClothingItem top,
required ClothingItem bottom,
required ClothingItem shoes,
}) {
int score = 0;

// ----------------------------------------------------------
// COLOR MATCHING
// ----------------------------------------------------------

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

// ----------------------------------------------------------
// STYLE MATCHING
// ----------------------------------------------------------

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

// ----------------------------------------------------------
// SEASON MATCHING
// ----------------------------------------------------------

if (top.season == bottom.season) {
score += 10;
}

if (shoes.season == top.season) {
score += 5;
}

return score;
}

int _colorCompatibility(
String color1,
String color2,
) {
final a = color1.toLowerCase();
final b = color2.toLowerCase();

if (a == b) {
return 8;
}

// Neutrals work with almost everything.
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

// Common complementary combinations.
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
// INDIVIDUAL SHUFFLING
// ------------------------------------------------------------

void _shuffleTop() {
if (_tops.isEmpty) return;

setState(() {
_top = _getRandomDifferent(
_tops,
_top,
);
});
}

void _shuffleBottom() {
if (_bottoms.isEmpty) return;

setState(() {
_bottom = _getRandomDifferent(
_bottoms,
_bottom,
);
});
}

void _shuffleShoes() {
if (_shoes.isEmpty) return;

setState(() {
_shoes = _shoes;
_shoes = _getRandomDifferent(
_shoes,
_shoes,
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
    .where((item) => item.id != current?.id)
    .toList();

return available[
_random.nextInt(available.length)
];
}

// ------------------------------------------------------------
// UI
// ------------------------------------------------------------

@override
Widget build(BuildContext context) {
final hasEnoughClothes =
_tops.isNotEmpty &&
_bottoms.isNotEmpty &&
_shoes.isNotEmpty;

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
Text(
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

_buildItemSection(
label: 'Top',
item: _top!,
onShuffle: _shuffleTop,
),

const SizedBox(height: 14),

_buildItemSection(
label: 'Bottom',
item: _bottom!,
onShuffle: _shuffleBottom,
),

const SizedBox(height: 14),

_buildItemSection(
label: 'Shoes',
item: _shoes!,
onShuffle: _shuffleShoes,
),

if (_outerwear != null) ...[
const SizedBox(height: 14),
_buildItemSection(
label: 'Outerwear',
item: _outerwear!,
onShuffle: () {
if (_outerwear!.isNotEmpty) {
setState(() {
_outerwear =
_getRandomDifferent(
_outerwear,
_outerwear,
);
});
}
},
),
],

if (_accessory != null) ...[
const SizedBox(height: 14),
_buildItemSection(
label: 'Accessory',
item: _accessory!,
onShuffle: () {
if (_accessories.isNotEmpty) {
setState(() {
_accessory =
_getRandomDifferent(
_accessories,
_accessory,
);
});
}
},
),
],

const SizedBox(height: 28),

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
```
