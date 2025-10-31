// ignore_for_file: deprecated_member_use

import 'package:expert_connect/src/app/app_color.dart';
import 'package:expert_connect/src/profile/bloc/booking_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalendarWidget {
  static Widget calendarSection(BuildContext context, BookingState state) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColor.splashColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _previousMonth(context, state),
                    icon: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  GestureDetector(
                    onTap: () => _showMonthYearPicker(context, state),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${state.months[state.currentViewDate.month - 1]}, ${state.currentViewDate.year}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _nextMonth(context, state),
                    icon: Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: state.weekDays
                        .map(
                          (day) => SizedBox(
                            width: 35,
                            child: Text(
                              day,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: 16),
                  // Calendar dates
                  _buildCalendarGrid(state, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildCalendarGrid(BookingState state, BuildContext context) {
    // Get the first day of the current month
    DateTime firstDayOfMonth = DateTime(
      state.currentViewDate.year,
      state.currentViewDate.month,
      1,
    );

    // Get the last day of the current month
    DateTime lastDayOfMonth = DateTime(
      state.currentViewDate.year,
      state.currentViewDate.month + 1,
      0,
    );

    // Get the weekday of the first day (0 = Sunday, 1 = Monday, etc.)
    int firstWeekday = firstDayOfMonth.weekday % 7;

    // Create the calendar grid
    List<Widget> calendarDays = [];

    // Add empty containers for days before the first day of the month
    for (int i = 0; i < firstWeekday; i++) {
      calendarDays.add(SizedBox(width: 35, height: 35));
    }

    // Add all days of the current month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      DateTime currentDate = DateTime(
        state.currentViewDate.year,
        state.currentViewDate.month,
        day,
      );
      bool isSelected =
          state.selectedDate.year == currentDate.year &&
          state.selectedDate.month == currentDate.month &&
          state.selectedDate.day == currentDate.day;
      bool isToday =
          DateTime.now().year == currentDate.year &&
          DateTime.now().month == currentDate.month &&
          DateTime.now().day == currentDate.day;
      bool isPastDate = currentDate.isBefore(
        DateTime.now().subtract(Duration(days: 1)),
      );

      calendarDays.add(
        GestureDetector(
          onTap: isPastDate
              ? null
              : () {
                  context.read<BookingBloc>().add(
                    UpdateSelectedDate(selectedDate: currentDate),
                  );
                },
          child: Container(
            width: 35,
            height: 35,
            margin: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected ? AppColor.splashColor : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isToday && !isSelected
                  ? Border.all(color: AppColor.splashColor, width: 1)
                  : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: isPastDate
                      ? Colors.grey[400]
                      : isSelected
                      ? Colors.white
                      : isToday
                      ? AppColor.splashColor
                      : Colors.grey[800],
                  fontSize: 16,
                  fontWeight: isSelected || isToday
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Arrange the days in a grid (7 columns)
    List<Widget> rows = [];
    for (int i = 0; i < calendarDays.length; i += 7) {
      List<Widget> week = calendarDays.sublist(
        i,
        i + 7 > calendarDays.length ? calendarDays.length : i + 7,
      );

      // Fill the remaining days of the week with empty containers
      while (week.length < 7) {
        week.add(SizedBox(width: 35, height: 35));
      }

      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: week,
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  static void _previousMonth(BuildContext context, BookingState state) {
    context.read<BookingBloc>().add(
      UpdateCurrentViewDate(
        currentViewDate: DateTime(
          state.currentViewDate.year,
          state.currentViewDate.month - 1,
          1,
        ),
      ),
    );
  }

  static void _nextMonth(BuildContext context, BookingState state) {
    context.read<BookingBloc>().add(
      UpdateCurrentViewDate(
        currentViewDate: DateTime(
          state.currentViewDate.year,
          state.currentViewDate.month + 1,
          1,
        ),
      ),
    );
  }

  static void _showMonthYearPicker(BuildContext context, BookingState state) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int tempYear = state.currentViewDate.year;
        int tempMonth = state.currentViewDate.month;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                'Select Month & Year',
                style: TextStyle(
                  color: AppColor.splashColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          setDialogState(() {
                            tempYear--;
                          });
                        },
                        icon: Icon(Icons.remove, color: AppColor.splashColor),
                      ),
                      Text(
                        '$tempYear',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColor.splashColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setDialogState(() {
                            tempYear++;
                          });
                        },
                        icon: Icon(Icons.add, color: AppColor.splashColor),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Month selection using Wrap instead of GridView
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: List.generate(12, (index) {
                      bool isSelected = (index + 1) == tempMonth;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            tempMonth = index + 1;
                          });
                        },
                        child: Container(
                          width: 60,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColor.splashColor
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              state.months[index].substring(0, 3),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<BookingBloc>().add(
                      UpdateCurrentViewDate(
                        currentViewDate: DateTime(tempYear, tempMonth, 1),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(color: AppColor.splashColor),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
