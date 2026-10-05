import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/favorite_outfit.dart';
import '../../models/planned_outfit.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/planner_provider.dart';
import '../../providers/wear_history_provider.dart';
import '../../theme/app_theme.dart';

class PlannerScreen extends StatefulWidget {
  final FavoritesProvider favoritesProvider;
  final PlannerProvider plannerProvider;
  final WearHistoryProvider wearHistoryProvider;

  const PlannerScreen({
    super.key,
    required this.favoritesProvider,
    required this.plannerProvider,
    required this.wearHistoryProvider,
  });

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  DateTime _displayedMonth = DateTime.now();

  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  DateTime _weekStart = _startOfWeek(DateTime.now());

  static DateTime _startOfWeek(DateTime date) {
    final normalized = DateTime(
      date.year,
      date.month,
      date.day,
    );

    return normalized.subtract(
      Duration(days: normalized.weekday - 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.favoritesProvider,
        widget.plannerProvider,
        widget.wearHistoryProvider,
      ]),
      builder: (context, child) {
        final selectedPlan = widget.plannerProvider
            .getPlanForDate(_selectedDate);

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Outfit Planner',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              TextButton(
                onPressed: _goToToday,
                child: const Text(
                  'Today',
                  style: TextStyle(
                    color: AppTheme.brown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              30,
            ),
            children: [
              _buildWeekSummary(),
              const SizedBox(height: 20),
              _buildWeekNavigation(),
              const SizedBox(height: 12),
              _buildWeeklyPlanner(),
              const SizedBox(height: 24),
              _buildMonthHeader(),
              const SizedBox(height: 14),
              _buildCalendar(),
              const SizedBox(height: 24),
              _buildSelectedDateHeader(),
              const SizedBox(height: 12),
              _buildSelectedDateContent(
                selectedPlan,
              ),
              const SizedBox(height: 30),
              _buildUpcomingSection(),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // WEEK SUMMARY
  // ------------------------------------------------------------

  Widget _buildWeekSummary() {
    final plans = _getPlansForCurrentWeek();

    final wornCount = plans.where(
          (plan) {
        return widget.wearHistoryProvider
            .isPlannedOutfitMarkedWorn(plan.id);
      },
    ).length;

    final remaining = plans.length - wornCount;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.brown,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'This Week',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.calendar_month,
                  value: plans.length.toString(),
                  label: 'Planned',
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.check_circle_outline,
                  value: wornCount.toString(),
                  label: 'Worn',
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.schedule,
                  value: remaining.toString(),
                  label: 'Remaining',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // WEEK NAVIGATION
  // ------------------------------------------------------------

  Widget _buildWeekNavigation() {
    final weekEnd = _weekStart.add(
      const Duration(days: 6),
    );

    return Row(
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _weekStart = _weekStart.subtract(
                const Duration(days: 7),
              );
            });
          },
          icon: const Icon(Icons.chevron_left),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              '${_formatShortDate(_weekStart)} - '
                  '${_formatShortDate(weekEnd)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _weekStart = _weekStart.add(
                const Duration(days: 7),
              );
            });
          },
          icon: const Icon(Icons.chevron_right),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // WEEKLY PLANNER
  // ------------------------------------------------------------

  Widget _buildWeeklyPlanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: List.generate(
          7,
              (index) {
            final date = _weekStart.add(
              Duration(days: index),
            );

            return _buildWeekDay(date);
          },
        ),
      ),
    );
  }

  Widget _buildWeekDay(DateTime date) {
    final plan = widget.plannerProvider
        .getPlanForDate(date);

    final isSelected = _isSameDay(
      date,
      _selectedDate,
    );

    final isToday = _isSameDay(
      date,
      DateTime.now(),
    );

    final isWorn = plan != null &&
        widget.wearHistoryProvider
            .isPlannedOutfitMarkedWorn(plan.id);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
          _displayedMonth = DateTime(
            date.year,
            date.month,
          );
        });
      },
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 8,
        ),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightBrown
              : const Color(0xFFFFFCF8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.brown
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 58,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    _weekdayShort(date),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? AppTheme.brown
                          : AppTheme.grayText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date.day.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: plan == null
                  ? Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.lightBrown,
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppTheme.brown,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'No outfit planned',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.grayText,
                    ),
                  ),
                ],
              )
                  : Row(
                children: [
                  _buildSmallOutfitImage(
                    plan.outfit.items.first,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Planned Outfit',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                            FontWeight.bold,
                            color:
                            AppTheme.darkText,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${plan.outfit.items.length} items',
                          style: const TextStyle(
                            fontSize: 11,
                            color:
                            AppTheme.grayText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isWorn)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 21,
                    )
                  else
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppTheme.grayText,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // MONTH CALENDAR
  // ------------------------------------------------------------

  Widget _buildMonthHeader() {
    const months = [
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

    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Monthly View',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkText,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _displayedMonth = DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month - 1,
                  );
                });
              },
              icon: const Icon(
                Icons.chevron_left,
              ),
            ),
            Text(
              '${months[_displayedMonth.month - 1]} '
                  '${_displayedMonth.year}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkText,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _displayedMonth = DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month + 1,
                  );
                });
              },
              icon: const Icon(
                Icons.chevron_right,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    final firstDay = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );

    final daysInMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;

    final startingWeekday = firstDay.weekday;

    final totalCells =
        ((startingWeekday - 1 + daysInMonth) / 7)
            .ceil() *
            7;

    const weekdays = [
      'M',
      'T',
      'W',
      'T',
      'F',
      'S',
      'S',
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: weekdays.map(
                  (day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.grayText,
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics:
            const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final dayNumber =
                  index -
                      (startingWeekday - 1) +
                      1;

              if (dayNumber < 1 ||
                  dayNumber > daysInMonth) {
                return const SizedBox();
              }

              final date = DateTime(
                _displayedMonth.year,
                _displayedMonth.month,
                dayNumber,
              );

              return _buildCalendarDay(date);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(DateTime date) {
    final isSelected = _isSameDay(
      date,
      _selectedDate,
    );

    final isToday = _isSameDay(
      date,
      DateTime.now(),
    );

    final plan = widget.plannerProvider
        .getPlanForDate(date);

    final hasPlan = plan != null;

    final isWorn = plan != null &&
        widget.wearHistoryProvider
            .isPlannedOutfitMarkedWorn(plan.id);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
          _weekStart = _startOfWeek(date);
        });
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.brown
              : isToday
              ? AppTheme.lightBrown
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                isSelected || isToday
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 4),
            if (hasPlan)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isWorn
                      ? Colors.green
                      : isSelected
                      ? Colors.white
                      : AppTheme.brown,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SELECTED DATE
  // ------------------------------------------------------------

  Widget _buildSelectedDateHeader() {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            _formatSelectedDate(
              _selectedDate,
            ),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkText,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: _showFavoriteOutfits,
          icon: const Icon(
            Icons.add,
            size: 18,
          ),
          label: const Text(
            'Choose Outfit',
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedDateContent(
      PlannedOutfit? plan,
      ) {
    if (plan == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.lightBrown,
                borderRadius:
                BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: AppTheme.brown,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Nothing planned',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose a favorite outfit for this day.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.grayText,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showFavoriteOutfits,
              icon: const Icon(Icons.add),
              label: const Text(
                'Plan an Outfit',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brown,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final isWorn = widget.wearHistoryProvider
        .isPlannedOutfitMarkedWorn(plan.id);

    final recentWearCount =
    widget.wearHistoryProvider
        .getWearCountForOutfit(
      plan.outfit,
    );

    final lastWorn = widget.wearHistoryProvider
        .getLastWornForOutfit(
      plan.outfit,
    );

    final recentlyWorn = lastWorn != null &&
        DateTime.now()
            .difference(lastWorn)
            .inDays <
            3;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isWorn
              ? Colors.green.shade200
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          _buildOutfitPreview(
            plan.outfit,
          ),
          const SizedBox(height: 16),

          if (recentlyWorn && !isWorn)
            _buildRepeatWarning(
              recentWearCount,
              lastWorn,
            ),

          if (recentlyWorn && !isWorn)
            const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isWorn
                      ? null
                      : () {
                    _markPlanAsWorn(plan);
                  },
                  icon: Icon(
                    isWorn
                        ? Icons.check_circle
                        : Icons.checkroom,
                  ),
                  label: Text(
                    isWorn
                        ? 'Worn'
                        : 'Mark as Worn',
                  ),
                  style:
                  OutlinedButton.styleFrom(
                    foregroundColor: isWorn
                        ? Colors.green
                        : AppTheme.brown,
                    side: BorderSide(
                      color: isWorn
                          ? Colors.green
                          : AppTheme.brown,
                    ),
                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  _showFavoriteOutfits(
                    replacingPlan: plan,
                  );
                },
                tooltip: 'Change outfit',
                style: IconButton.styleFrom(
                  backgroundColor:
                  AppTheme.lightBrown,
                ),
                icon: const Icon(
                  Icons.swap_horiz,
                  color: AppTheme.brown,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () {
                  _removePlan(plan);
                },
                tooltip: 'Remove outfit',
                style: IconButton.styleFrom(
                  backgroundColor:
                  Colors.red.shade50,
                ),
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),

          if (isWorn) ...[
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.green,
                ),
                SizedBox(width: 6),
                Text(
                  'Added to Wear History',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRepeatWarning(
      int wearCount,
      DateTime? lastWorn,
      ) {
    String message;

    if (lastWorn != null &&
        _isSameDay(lastWorn, DateTime.now())) {
      message = 'You wore this outfit today.';
    } else if (lastWorn != null &&
        DateTime.now()
            .difference(lastWorn)
            .inDays ==
            1) {
      message = 'You wore this outfit yesterday.';
    } else {
      message =
      'You wore this outfit recently.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange.shade800,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$message It has been worn $wearCount '
                  '${wearCount == 1 ? 'time' : 'times'}.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // OUTFIT PREVIEW
  // ------------------------------------------------------------

  Widget _buildOutfitPreview(
      FavoriteOutfit outfit,
      ) {
    final items = outfit.items;

    if (items.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'No clothing items',
            style: TextStyle(
              color: AppTheme.grayText,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 210,
      child: Row(
        children: [
          Expanded(
            child: _buildOutfitItem(
              items[0],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                if (items.length > 1)
                  Expanded(
                    child: _buildOutfitItem(
                      items[1],
                    ),
                  ),
                if (items.length > 1)
                  const SizedBox(height: 8),
                if (items.length > 2)
                  Expanded(
                    child: _buildOutfitItem(
                      items[2],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitItem(
      dynamic item,
      ) {
    final imagePath = item.imagePath;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightBrown,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: imagePath != null &&
          imagePath.isNotEmpty &&
          File(imagePath).existsSync()
          ? Image.file(
        File(imagePath),
        fit: BoxFit.cover,
      )
          : Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.checkroom_outlined,
              color: AppTheme.brown,
              size: 30,
            ),
            const SizedBox(height: 6),
            Text(
              item.category,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.brown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // UPCOMING OUTFITS
  // ------------------------------------------------------------

  Widget _buildUpcomingSection() {
    final plans = widget.plannerProvider
        .plannedOutfits
        .where(
          (plan) => !_dateBeforeToday(plan.date),
    )
        .toList();

    if (plans.isEmpty) {
      return const SizedBox();
    }

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
        const SizedBox(height: 14),
        ...plans.take(10).map(
              (plan) {
            final isWorn = widget
                .wearHistoryProvider
                .isPlannedOutfitMarkedWorn(
              plan.id,
            );

            return GestureDetector(
              onTap: () {
                final date =
                _dateFromKey(plan.date);

                setState(() {
                  _selectedDate = date;
                  _displayedMonth = DateTime(
                    date.year,
                    date.month,
                  );
                  _weekStart =
                      _startOfWeek(date);
                });
              },
              child: Container(
                margin:
                const EdgeInsets.only(
                  bottom: 10,
                ),
                padding:
                const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    _buildSmallOutfitImage(
                      plan.outfit.items.first,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatPlanDate(
                              plan.date,
                            ),
                            style:
                            const TextStyle(
                              fontSize: 14,
                              fontWeight:
                              FontWeight.bold,
                              color:
                              AppTheme.darkText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${plan.outfit.items.length} '
                                'clothing items',
                            style:
                            const TextStyle(
                              fontSize: 12,
                              color:
                              AppTheme.grayText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isWorn)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      )
                    else
                      const Icon(
                        Icons.chevron_right,
                        color: AppTheme.grayText,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSmallOutfitImage(
      dynamic item,
      ) {
    final imagePath = item.imagePath;

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: AppTheme.lightBrown,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: imagePath != null &&
          imagePath.isNotEmpty &&
          File(imagePath).existsSync()
          ? Image.file(
        File(imagePath),
        fit: BoxFit.cover,
      )
          : const Icon(
        Icons.checkroom_outlined,
        color: AppTheme.brown,
      ),
    );
  }

  // ------------------------------------------------------------
  // FAVORITE OUTFITS
  // ------------------------------------------------------------

  Future<void> _showFavoriteOutfits({
    PlannedOutfit? replacingPlan,
  }) async {
    final favorites =
        widget.favoritesProvider.favorites;

    if (favorites.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Save an outfit to Favorites first.',
          ),
        ),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height:
          MediaQuery.of(context).size.height *
              0.75,
          decoration: const BoxDecoration(
            color: AppTheme.background,
            borderRadius:
            BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius:
                  BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                replacingPlan == null
                    ? 'Choose a Favorite Outfit'
                    : 'Change Planned Outfit',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Plan an outfit for '
                    '${_formatSelectedDate(_selectedDate)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.grayText,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.builder(
                  padding:
                  const EdgeInsets.all(20),
                  itemCount: favorites.length,
                  itemBuilder:
                      (context, index) {
                    final outfit =
                    favorites[index];

                    final isCurrent =
                        replacingPlan != null &&
                            replacingPlan
                                .outfit.id ==
                                outfit.id;

                    return GestureDetector(
                      onTap: isCurrent
                          ? null
                          : () async {
                        Navigator.pop(
                          context,
                        );

                        await widget
                            .plannerProvider
                            .addPlan(
                          date: _selectedDate,
                          outfit: outfit,
                        );

                        if (!mounted) {
                          return;
                        }

                        ScaffoldMessenger
                            .of(
                          context,
                        ).showSnackBar(
                          SnackBar(
                            content: Text(
                              replacingPlan ==
                                  null
                                  ? 'Outfit planned successfully.'
                                  : 'Planned outfit changed.',
                            ),
                          ),
                        );
                      },
                      child: Opacity(
                        opacity:
                        isCurrent ? 0.5 : 1,
                        child: Container(
                          margin:
                          const EdgeInsets.only(
                            bottom: 14,
                          ),
                          padding:
                          const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(
                              20,
                            ),
                            border: Border.all(
                              color:
                              isCurrent
                                  ? AppTheme.brown
                                  : Colors
                                  .grey
                                  .shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildSmallOutfitImage(
                                outfit.items.first,
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    const Text(
                                      'Favorite Outfit',
                                      style:
                                      TextStyle(
                                        fontSize: 15,
                                        fontWeight:
                                        FontWeight
                                            .bold,
                                        color:
                                        AppTheme
                                            .darkText,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      '${outfit.items.length} '
                                          'clothing items',
                                      style:
                                      const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme
                                            .grayText,
                                      ),
                                    ),
                                    if (isCurrent)
                                      const Padding(
                                        padding:
                                        EdgeInsets
                                            .only(
                                          top: 3,
                                        ),
                                        child: Text(
                                          'Currently planned',
                                          style:
                                          TextStyle(
                                            fontSize: 11,
                                            color:
                                            AppTheme
                                                .brown,
                                            fontWeight:
                                            FontWeight
                                                .w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons
                                    .arrow_forward_ios,
                                size: 16,
                                color:
                                AppTheme.grayText,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // ACTIONS
  // ------------------------------------------------------------

  Future<void> _markPlanAsWorn(
      PlannedOutfit plan,
      ) async {
    await widget.wearHistoryProvider.markAsWorn(
      outfit: plan.outfit,
      wornAt: DateTime.now(),
      plannedOutfitId: plan.id,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Outfit marked as worn! 👕',
        ),
      ),
    );
  }

  Future<void> _removePlan(
      PlannedOutfit plan,
      ) async {
    final shouldRemove =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Remove planned outfit?',
          ),
          content: const Text(
            'This outfit will be removed from '
                'this day in your planner.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Remove',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldRemove != true) {
      return;
    }

    await widget.plannerProvider
        .removePlan(plan.id);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Planned outfit removed.',
        ),
      ),
    );
  }

  void _goToToday() {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    setState(() {
      _selectedDate = today;
      _displayedMonth = DateTime(
        today.year,
        today.month,
      );
      _weekStart = _startOfWeek(today);
    });
  }

  // ------------------------------------------------------------
  // HELPERS
  // ------------------------------------------------------------

  List<PlannedOutfit> _getPlansForCurrentWeek() {
    final plans = <PlannedOutfit>[];

    for (int i = 0; i < 7; i++) {
      final date = _weekStart.add(
        Duration(days: i),
      );

      final plan = widget.plannerProvider
          .getPlanForDate(date);

      if (plan != null) {
        plans.add(plan);
      }
    }

    return plans;
  }

  DateTime _dateFromKey(String date) {
    final parts = date.split('-');

    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  bool _dateBeforeToday(String date) {
    final planDate = _dateFromKey(date);

    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    return planDate.isBefore(today);
  }

  bool _isSameDay(
      DateTime first,
      DateTime second,
      ) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _weekdayShort(DateTime date) {
    const weekdays = [
      'MON',
      'TUE',
      'WED',
      'THU',
      'FRI',
      'SAT',
      'SUN',
    ];

    return weekdays[date.weekday - 1];
  }

  String _formatShortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatSelectedDate(
      DateTime date,
      ) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const months = [
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

    return '${weekdays[date.weekday - 1]}, '
        '${months[date.month - 1]} ${date.day}';
  }

  String _formatPlanDate(
      String date,
      ) {
    final parsedDate = _dateFromKey(date);

    const months = [
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

    return '${months[parsedDate.month - 1]} '
        '${parsedDate.day}, '
        '${parsedDate.year}';
  }
}