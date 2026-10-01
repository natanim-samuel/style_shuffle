import 'package:flutter/material.dart';

import 'providers/favorites_provider.dart';
import 'providers/planner_provider.dart';
import 'providers/wardrobe_provider.dart';
import 'providers/wear_history_provider.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/planner/planner_screen.dart';
import 'screens/wardrobe/wardrobe_screen.dart';
import 'screens/wear_history/wear_history_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const StyleShuffleApp());
}

class StyleShuffleApp extends StatefulWidget {
  const StyleShuffleApp({
    super.key,
  });

  @override
  State<StyleShuffleApp> createState() =>
      _StyleShuffleAppState();
}

class _StyleShuffleAppState
    extends State<StyleShuffleApp> {
  late final WardrobeProvider wardrobeProvider;
  late final FavoritesProvider favoritesProvider;
  late final PlannerProvider plannerProvider;
  late final WearHistoryProvider wearHistoryProvider;

  @override
  void initState() {
    super.initState();

    wardrobeProvider =
        WardrobeProvider();

    favoritesProvider =
        FavoritesProvider();

    plannerProvider =
        PlannerProvider();

    wearHistoryProvider =
        WearHistoryProvider();

    _loadData();
  }

  Future<void> _loadData() async {
    await wardrobeProvider.loadItems();
    await favoritesProvider.loadFavorites();
    await plannerProvider.loadPlans();
    await wearHistoryProvider.loadHistory();
  }

  @override
  void dispose() {
    wardrobeProvider.dispose();
    favoritesProvider.dispose();
    plannerProvider.dispose();
    wearHistoryProvider.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StyleShuffle',
      theme: AppTheme.lightTheme,
      home: MainNavigationScreen(
        wardrobeProvider:
        wardrobeProvider,
        favoritesProvider:
        favoritesProvider,
        plannerProvider:
        plannerProvider,
        wearHistoryProvider:
        wearHistoryProvider,
      ),
    );
  }
}

class MainNavigationScreen
    extends StatefulWidget {
  final WardrobeProvider wardrobeProvider;
  final FavoritesProvider favoritesProvider;
  final PlannerProvider plannerProvider;
  final WearHistoryProvider wearHistoryProvider;

  const MainNavigationScreen({
    super.key,
    required this.wardrobeProvider,
    required this.favoritesProvider,
    required this.plannerProvider,
    required this.wearHistoryProvider,
  });

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        wardrobeProvider: widget.wardrobeProvider,
      ),
      WardrobeScreen(
        wardrobeProvider:
        widget.wardrobeProvider,
      ),
      FavoritesScreen(
        favoritesProvider:
        widget.favoritesProvider,
      ),
      PlannerScreen(
        favoritesProvider:
        widget.favoritesProvider,
        plannerProvider:
        widget.plannerProvider,
        wearHistoryProvider:
        widget.wearHistoryProvider,
      ),
      WearHistoryScreen(
        wearHistoryProvider:
        widget.wearHistoryProvider,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar:
      NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(
              Icons.checkroom_outlined,
            ),
            selectedIcon: Icon(
              Icons.checkroom,
            ),
            label: 'Wardrobe',
          ),
          NavigationDestination(
            icon: _favoriteIcon(false),
            selectedIcon: _favoriteIcon(true),
            label: 'Favorites',
          ),
          const NavigationDestination(
            icon: Icon(
              Icons.calendar_month_outlined,
            ),
            selectedIcon: Icon(
              Icons.calendar_month,
            ),
            label: 'Planner',
          ),
          NavigationDestination(
            icon: _historyIcon(false),
            selectedIcon: _historyIcon(true),
            label: 'History',
          ),
        ],
      ),
    );
  }

  Widget _favoriteIcon(
      bool selected,
      ) {
    return AnimatedBuilder(
      animation:
      widget.favoritesProvider,
      builder: (context, child) {
        final count =
            widget.favoritesProvider.count;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              selected
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
            if (count > 0)
              Positioned(
                right: -9,
                top: -7,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration:
                  BoxDecoration(
                    color: AppTheme.brown,
                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: Text(
                    count > 99
                        ? '99+'
                        : count.toString(),
                    style:
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _historyIcon(
      bool selected,
      ) {
    return AnimatedBuilder(
      animation:
      widget.wearHistoryProvider,
      builder: (context, child) {
        final count =
            widget.wearHistoryProvider
                .totalWears;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              selected
                  ? Icons.history
                  : Icons.history_outlined,
            ),
            if (count > 0)
              Positioned(
                right: -9,
                top: -7,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration:
                  BoxDecoration(
                    color: AppTheme.brown,
                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: Text(
                    count > 99
                        ? '99+'
                        : count.toString(),
                    style:
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}