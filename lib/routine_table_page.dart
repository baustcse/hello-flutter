import 'package:flutter/material.dart';

import 'main.dart'; // for AppDrawer

// ============================================================================
// STEP 1 — The data. Hard-coded, right here in the file. No internet, no API.
// ============================================================================

/// One row of the routine. A plain class that just holds values.
class ClassSlot {
  final String day;
  final String time;
  final String code;
  final String title;
  final String room;
  final String teacher;

  const ClassSlot({
    required this.day,
    required this.time,
    required this.code,
    required this.title,
    required this.room,
    required this.teacher,
  });
}

/// `const` means this list is built once, at compile time, and never changes.
const List<ClassSlot> kRoutine = [
  ClassSlot(
    day: 'Sunday',
    time: '09:00 – 10:30',
    code: 'CSE 3100',
    title: 'Software Development Project I',
    room: 'Lab 2',
    teacher: 'MRT',
  ),
  ClassSlot(
    day: 'Sunday',
    time: '11:00 – 12:30',
    code: 'CSE 3101',
    title: 'Operating Systems',
    room: '301',
    teacher: 'AKM',
  ),
  ClassSlot(
    day: 'Monday',
    time: '09:00 – 10:30',
    code: 'CSE 3103',
    title: 'Database Systems',
    room: '302',
    teacher: 'SRA',
  ),
  ClassSlot(
    day: 'Monday',
    time: '14:00 – 16:30',
    code: 'CSE 3104',
    title: 'Database Systems Lab',
    room: 'Lab 1',
    teacher: 'SRA',
  ),
  ClassSlot(
    day: 'Tuesday',
    time: '10:30 – 12:00',
    code: 'CSE 3105',
    title: 'Computer Networks',
    room: '303',
    teacher: 'MHK',
  ),
  ClassSlot(
    day: 'Wednesday',
    time: '09:00 – 10:30',
    code: 'CSE 3107',
    title: 'Microprocessors',
    room: '301',
    teacher: 'TAR',
  ),
  ClassSlot(
    day: 'Wednesday',
    time: '14:00 – 16:30',
    code: 'CSE 3100',
    title: 'Flutter Lab',
    room: 'Lab 2',
    teacher: 'MRT',
  ),
  ClassSlot(
    day: 'Thursday',
    time: '11:00 – 12:30',
    code: 'MATH 3121',
    title: 'Numerical Methods',
    room: '205',
    teacher: 'NAS',
  ),
];

// ============================================================================
// STEP 2 — The page. A StatelessWidget: nothing here ever changes.
// ============================================================================

class RoutineTablePage extends StatelessWidget {
  const RoutineTablePage({super.key});

  /// Give each day its own colour so the table is easy to scan.
  Color _dayColor(String day) {
    switch (day) {
      case 'Sunday':
        return const Color(0xFF4F46E5);
      case 'Monday':
        return const Color(0xFF0891B2);
      case 'Tuesday':
        return const Color(0xFF16A34A);
      case 'Wednesday':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF9333EA);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Routine'),
        centerTitle: true,
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // ---- A small header strip ----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFEEF2FF),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 18, color: Color(0xFF4338CA)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'CSE 3rd Year · 1st Semester',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                Text(
                  '${kRoutine.length} classes',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),

          // ---- The table ----
          // Two nested scroll views: one for up/down, one for left/right,
          // because six columns will never fit a phone's width.
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor:
                      WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF0F172A),
                  ),
                  dataTextStyle: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF1E293B),
                  ),
                  columnSpacing: 20,
                  headingRowHeight: 46,
                  dataRowMinHeight: 46,
                  dataRowMaxHeight: 54,
                  border: TableBorder.symmetric(
                    inside: const BorderSide(
                      color: Color(0xFFE2E8F0),
                      width: 0.6,
                    ),
                  ),

                  // One DataColumn per column header.
                  columns: const [
                    DataColumn(label: Text('Day')),
                    DataColumn(label: Text('Time')),
                    DataColumn(label: Text('Code')),
                    DataColumn(label: Text('Course')),
                    DataColumn(label: Text('Room')),
                    DataColumn(label: Text('Teacher')),
                  ],

                  // One DataRow per item in our list.
                  // The number of cells must match the number of columns.
                  rows: List<DataRow>.generate(kRoutine.length, (i) {
                    final slot = kRoutine[i];
                    return DataRow(
                      color: WidgetStateProperty.all(
                        i.isEven ? Colors.white : const Color(0xFFFAFBFC),
                      ),
                      cells: [
                        DataCell(_DayPill(
                          day: slot.day,
                          color: _dayColor(slot.day),
                        )),
                        DataCell(Text(slot.time)),
                        DataCell(Text(
                          slot.code,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4338CA),
                          ),
                        )),
                        DataCell(Text(slot.title)),
                        DataCell(Text(slot.room)),
                        DataCell(Text(slot.teacher)),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A small coloured pill for the Day column.
class _DayPill extends StatelessWidget {
  final String day;
  final Color color;

  const _DayPill({required this.day, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        day,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
