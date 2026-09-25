import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

import 'providers/wardrobe_provider.dart';

import 'screens/home/home_screen.dart';
import 'screens/wardrobe/wardrobe_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/planner/planner_screen.dart';

void main() {
  runApp(const StyleShuffleApp());
}

class StyleShuffleApp extends StatefulWidget {
  const StyleShuffleApp({super.key});

  @override
  State<StyleShuffleApp> createState() =>
      _StyleShuffleAppState();
}

class _StyleShuffleAppState
    extends State<StyleShuffleApp> {
  late final WardrobeProvider wardrobeProvider;

  @override
  void initState() {
    super.initState();

    wardrobeProvider = WardrobeProvider();

    wardrobeProvider.loadItems();
  }

  @override
  void dispose() {
    wardrobeProvider.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'StyleShuffle',

      theme: AppTheme.lightTheme,

      home: MainNavigationScreen(
        wardrobeProvider: wardrobeProvider,
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final WardrobeProvider wardrobeProvider;

  const MainNavigationScreen({
    super.key,
    required this.wardrobeProvider,
  });

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),

      WardrobeScreen(
        wardrobeProvider:
        widget.wardrobeProvider,
      ),

      const FavoritesScreen(),

      const PlannerScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,

        children: screens,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,

        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),

            selectedIcon: Icon(
              Icons.home,
            ),

            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.checkroom_outlined,
            ),

            selectedIcon: Icon(
              Icons.checkroom,
            ),

            label: 'Wardrobe',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.favorite_outline,
            ),

            selectedIcon: Icon(
              Icons.favorite,
            ),

            label: 'Favorites',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.calendar_month_outlined,
            ),

            selectedIcon: Icon(
              Icons.calendar_month,
            ),

            label: 'Planner',
          ),
        ],
      ),
    );
  }
}