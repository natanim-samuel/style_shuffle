import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/favorite_outfit.dart';
import '../../models/planned_outfit.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/planner_provider.dart';
import '../../theme/app_theme.dart';

class PlannerScreen extends StatefulWidget {
  final FavoritesProvider favoritesProvider;
  final PlannerProvider plannerProvider;

  const PlannerScreen({
    super.key,
    required this.favoritesProvider,
    required this.plannerProvider,
  });

  @override
  State<PlannerScreen> createState() =>
      _PlannerScreenState();
}

class _PlannerScreenState
    extends State<PlannerScreen> {
  DateTime _selectedDate = DateTime.now();

  DateTime _month = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Outfit Planner',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.background,
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          widget.favoritesProvider,
          widget.plannerProvider,
        ]),
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _buildHeader(),

                const SizedBox(height: 20),

                _buildCalendar(),

                const SizedBox(height: 25),

                _buildSelectedDateSection(),

                const SizedBox(height: 30),

                _buildUpcomingPlans(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Plan your looks',
          style: Theme.of(context)
              .textTheme
              .headlineMedium,
        ),
        const SizedBox(height: 5),
        const Text(
          'Choose an outfit for each day of your week.',
          style: TextStyle(
            color: AppTheme.grayText,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    final daysInMonth = DateUtils.getDaysInMonth(
      _month.year,
      _month.month,
    );

    final firstDay = DateTime(
      _month.year,
      _month.month,
      1,
    );

    // Convert Sunday = 0.
    final firstWeekday =
        firstDay.weekday % 7;

    final totalCells =
        firstWeekday + daysInMonth;

    final rows = (totalCells / 7).ceil();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildMonthHeader(),

          const SizedBox(height: 15),

          Row(
            children: const [
              _WeekDay(label: 'S'),
              _WeekDay(label: 'M'),
              _WeekDay(label: 'T'),
              _WeekDay(label: 'W'),
              _WeekDay(label: 'T'),
              _WeekDay(label: 'F'),
              _WeekDay(label: 'S'),
            ],
          ),

          const SizedBox(height: 8),

          ...List.generate(
            rows,
                (row) {
              return Row(
                children: List.generate(
                  7,
                      (column) {
                    final cellIndex =
                        row * 7 + column;

                    final day =
                        cellIndex - firstWeekday + 1;

                    if (day < 1 ||
                        day > daysInMonth) {
                      return const Expanded(
                        child: SizedBox(
                          height: 52,
                        ),
                      );
                    }

                    final date = DateTime(
                      _month.year,
                      _month.month,
                      day,
                    );

                    return Expanded(
                      child: _buildDayCell(
                        date,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    final monthName =
    _monthName(_month.month);

    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _month = DateTime(
                _month.year,
                _month.month - 1,
              );
            });
          },
          icon: const Icon(
            Icons.chevron_left,
          ),
        ),
        Text(
          '$monthName ${_month.year}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkText,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _month = DateTime(
                _month.year,
                _month.month + 1,
              );
            });
          },
          icon: const Icon(
            Icons.chevron_right,
          ),
        ),
      ],
    );
  }

  Widget _buildDayCell(DateTime date) {
    final isSelected =
    _isSameDay(date, _selectedDate);

    final isToday =
    _isSameDay(date, DateTime.now());

    final hasPlan =
    widget.plannerProvider.hasPlanForDate(
      date,
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        height: 52,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.brown
              : isToday
              ? AppTheme.lightBrown
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 3),
            if (hasPlan)
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Colors.white
                      : AppTheme.brown,
                ),
              )
            else
              const SizedBox(
                height: 5,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateSection() {
    final plan =
    widget.plannerProvider.getPlanForDate(
      _selectedDate,
    );

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Day',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.grayText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDate(_selectedDate),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
              ],
            ),
            if (plan != null)
              IconButton(
                onPressed: () {
                  _confirmRemovePlan(plan);
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.brown,
                ),
              ),
          ],
        ),

        const SizedBox(height: 14),

        if (plan != null)
          _buildPlannedOutfit(plan)
        else
          _buildEmptyDay(),
      ],
    );
  }

  Widget _buildEmptyDay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightBrown,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              color: AppTheme.brown,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No outfit planned',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Choose one of your favorite outfits for this day.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.grayText,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showFavoriteOutfits,
              icon: const Icon(
                Icons.add,
              ),
              label: const Text(
                'Plan an Outfit',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brown,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlannedOutfit(
      PlannedOutfit plan,
      ) {
    final outfit = plan.outfit;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppTheme.brown,
              ),
              const SizedBox(width: 8),
              const Text(
                'Planned Outfit',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            height: 130,
            child: ListView(
              scrollDirection:
              Axis.horizontal,
              children: outfit.items.map(
                    (item) {
                  return _buildOutfitItem(
                    item,
                  );
                },
              ).toList(),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            '${outfit.top.name} • ${outfit.bottom.name} • ${outfit.shoes.name}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.grayText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitItem(
      dynamic item,
      ) {
    final hasImage =
        item.imagePath != null &&
            item.imagePath!.isNotEmpty;

    return Container(
      width: 105,
      margin: const EdgeInsets.only(
        right: 10,
      ),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: hasImage
                ? ClipRRect(
              borderRadius:
              const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.file(
                File(item.imagePath!),
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
                : const Center(
              child: Icon(
                Icons.checkroom_outlined,
                color: AppTheme.brown,
                size: 32,
              ),
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.all(7),
            child: Text(
              item.name,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingPlans() {
    final plans =
        widget.plannerProvider.plannedOutfits;

    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final upcoming = plans.where((plan) {
      final date =
      DateTime.parse(plan.date);

      return !date.isBefore(today);
    }).take(5).toList();

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Outfits',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkText,
          ),
        ),

        const SizedBox(height: 12),

        if (upcoming.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(18),
            ),
            child: const Text(
              'No upcoming outfits planned yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.grayText,
              ),
            ),
          )
        else
          ...upcoming.map(
                (plan) {
              return _buildUpcomingPlanCard(
                plan,
              );
            },
          ),
      ],
    );
  }

  Widget _buildUpcomingPlanCard(
      PlannedOutfit plan,
      ) {
    final date =
    DateTime.parse(plan.date);

    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppTheme.lightBrown,
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Text(
                  _shortMonth(date.month),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.brown,
                  ),
                ),
                Text(
                  date.day.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.brown,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  _weekdayName(
                    date.weekday,
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.grayText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  plan.outfit.top.name,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${plan.outfit.bottom.name} • ${plan.outfit.shoes.name}',
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.grayText,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right,
            color: AppTheme.grayText,
          ),
        ],
      ),
    );
  }

  void _showFavoriteOutfits() {
    final favorites =
        widget.favoritesProvider.favorites;

    if (favorites.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'No Favorite Outfits',
            ),
            content: const Text(
              'Save an outfit to Favorites first, then you can add it to your planner.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'OK',
                ),
              ),
            ],
          );
        },
      );

      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              10,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose an Outfit',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'For ${_formatDate(_selectedDate)}',
                  style: const TextStyle(
                    color: AppTheme.grayText,
                  ),
                ),
                const SizedBox(height: 15),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: favorites.length,
                    itemBuilder:
                        (context, index) {
                      final outfit =
                      favorites[index];

                      return _buildFavoriteChoice(
                        outfit,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoriteChoice(
      FavoriteOutfit outfit,
      ) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);

        await widget.plannerProvider.addPlan(
          date: _selectedDate,
          outfit: outfit,
        );

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Outfit added to your planner.',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 10,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            _buildSmallOutfitImage(
              outfit.top,
            ),
            const SizedBox(width: 10),
            _buildSmallOutfitImage(
              outfit.bottom,
            ),
            const SizedBox(width: 10),
            _buildSmallOutfitImage(
              outfit.shoes,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                outfit.top.name,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
            ),
            const Icon(
              Icons.add_circle_outline,
              color: AppTheme.brown,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallOutfitImage(
      dynamic item,
      ) {
    final hasImage =
        item.imagePath != null &&
            item.imagePath!.isNotEmpty;

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius:
        BorderRadius.circular(12),
      ),
      child: hasImage
          ? ClipRRect(
        borderRadius:
        BorderRadius.circular(12),
        child: Image.file(
          File(item.imagePath!),
          fit: BoxFit.cover,
        ),
      )
          : const Icon(
        Icons.checkroom_outlined,
        color: AppTheme.brown,
      ),
    );
  }

  void _confirmRemovePlan(
      PlannedOutfit plan,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Remove Outfit?',
          ),
          content: const Text(
            'Remove this outfit from your planner?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                await widget.plannerProvider
                    .removePlan(
                  plan.id,
                );
              },
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                AppTheme.brown,
                foregroundColor:
                Colors.white,
              ),
              child: const Text(
                'Remove',
              ),
            ),
          ],
        );
      },
    );
  }

  bool _isSameDay(
      DateTime first,
      DateTime second,
      ) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _formatDate(DateTime date) {
    return '${_weekdayName(date.weekday)}, '
        '${_monthName(date.month)} '
        '${date.day}, '
        '${date.year}';
  }

  String _weekdayName(int weekday) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return names[weekday - 1];
  }

  String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return names[month - 1];
  }

  String _shortMonth(int month) {
    const names = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    return names[month - 1];
  }
}

class _WeekDay extends StatelessWidget {
  final String label;

  const _WeekDay({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppTheme.grayText,
          ),
        ),
      ),
    );
  }
}