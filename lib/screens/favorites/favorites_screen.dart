import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/favorite_outfit.dart';
import '../../providers/favorites_provider.dart';
import '../../theme/app_theme.dart';

class FavoritesScreen extends StatelessWidget {
  final FavoritesProvider favoritesProvider;

  const FavoritesScreen({
    super.key,
    required this.favoritesProvider,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: favoritesProvider,
      builder: (context, child) {
        final favorites = favoritesProvider.favorites;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Favorites'),
          ),
          body: favorites.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              30,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final outfit = favorites[index];

              return _buildFavoriteCard(
                context,
                outfit,
              );
            },
          ),
        );
      },
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
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppTheme.lightBrown,
                borderRadius:
                BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 45,
                color: AppTheme.brown,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No favorite outfits yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Generate an outfit you love and save it here.',
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

  Widget _buildFavoriteCard(
      BuildContext context,
      FavoriteOutfit outfit,
      ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 18,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(22),
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
                'Favorite Outfit',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
              IconButton(
                onPressed: () {
                  _confirmDelete(
                    context,
                    outfit,
                  );
                },
                icon: const Icon(
                  Icons.delete_outline,
                ),
                color: AppTheme.brown,
              ),
            ],
          ),

          const SizedBox(height: 10),

          _buildItemRow(
            'Top',
            outfit.top,
          ),

          const SizedBox(height: 8),

          _buildItemRow(
            'Bottom',
            outfit.bottom,
          ),

          const SizedBox(height: 8),

          _buildItemRow(
            'Shoes',
            outfit.shoes,
          ),

          if (outfit.outerwear != null) ...[
            const SizedBox(height: 8),
            _buildItemRow(
              'Outerwear',
              outfit.outerwear!,
            ),
          ],

          if (outfit.accessory != null) ...[
            const SizedBox(height: 8),
            _buildItemRow(
              'Accessory',
              outfit.accessory!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemRow(
      String label,
      dynamic item,
      ) {
    return Row(
      children: [
        _buildImage(item),
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
              const SizedBox(height: 2),
              Text(
                item.name,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.color} • ${item.style}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.grayText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage(dynamic item) {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(12),
      child: SizedBox(
        width: 60,
        height: 60,
        child: item.imagePath != null
            ? Image.file(
          File(item.imagePath!),
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.lightBrown,
      child: const Icon(
        Icons.checkroom_outlined,
        color: AppTheme.brown,
      ),
    );
  }

  void _confirmDelete(
      BuildContext context,
      FavoriteOutfit outfit,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Remove Favorite?',
          ),
          content: const Text(
            'Are you sure you want to remove this outfit from your favorites?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                await favoritesProvider
                    .removeFavorite(outfit.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                AppTheme.brown,
                foregroundColor:
                Colors.white,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}