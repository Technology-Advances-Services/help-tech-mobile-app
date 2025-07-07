import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../Attention/models/job.dart';
import '../../Attention/services/job_service.dart';

class WorkCalendar extends StatefulWidget {

  const WorkCalendar({super.key});

  @override
  _WorkCalendar createState() => _WorkCalendar();
}

class _WorkCalendar extends State<WorkCalendar> {

  final JobService _jobService = JobService();

  List<Job> allJobs = [];
  List<Job> filteredJobs = [];
  bool isLoading = true;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Future<void> loadJobs() async {

    setState(() => isLoading = true);

    allJobs = await _jobService.jobsByTechnical();
    filteredJobs = allJobs.where((job) {
      return job.jobState == 'COMPLETADO';
    }).toList();

    setState(() => isLoading = false);
  }

  List<Job> _getJobsForDay(DateTime day) {
    return filteredJobs.where((job) {
      final date = job.workDate;
      return date != null &&
          date.year == day.year &&
          date.month == day.month &&
          date.day == day.day;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    loadJobs();
  }

  @override
  Widget build(BuildContext context) {

    final events = _getJobsForDay(_selectedDay ?? _focusedDay);

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2023),
            lastDay: DateTime(2030),
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.deepPurple.shade200,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.tealAccent.shade400,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: const TextStyle(color: Colors.redAccent),
              outsideDaysVisible: false,
              defaultTextStyle: const TextStyle(color: Colors.white),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekendStyle: TextStyle(color: Colors.redAccent),
              weekdayStyle: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 20), ...
          events.map((job) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      '${job.firstName} ${job.lastName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      job.description,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.schedule, color: Colors.white),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('HH:mm').format
                            (job.workDate ?? DateTime.now()),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )),
          if (events.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  'No hay trabajos para este día.',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
        ],
      ),
    );
  }
}