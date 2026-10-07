import 'package:flutter/material.dart';

import 'main.dart'; // for AppDrawer

// ============================================================================
// STEP 1 — Hard-coded data. One object per card.
// ============================================================================

class CourseCard {
  final String code;
  final String title;
  final String teacher;
  final double credit;
  final IconData icon;
  final Color color;
  final List<String> topics;

  const CourseCard({
    required this.code,
    required this.title,
    required this.teacher,
    required this.credit,
    required this.icon,
    required this.color,
    required this.topics,
  });
}

const List<CourseCard> kCourses = [
  CourseCard(
    code: 'CSE 3100',
    title: 'Software Development Project I',
    teacher: 'Md Rakib Trofder',
    credit: 1.5,
    icon: Icons.phone_android,
    color: Color(0xFF4F46E5),
    topics: ['Flutter', 'Dart', 'Widgets', 'State'],
  ),
  CourseCard(
    code: 'CSE 3101',
    title: 'Operating Systems',
    teacher: 'A. K. M. Rahman',
    credit: 3.0,
    icon: Icons.memory,
    color: Color(0xFF0891B2),
    topics: ['Processes', 'Scheduling', 'Memory', 'Deadlock'],
  ),
  CourseCard(
    code: 'CSE 3103',
    title: 'Database Systems',
    teacher: 'S. R. Ahmed',
    credit: 3.0,
    icon: Icons.storage,
    color: Color(0xFF16A34A),
    topics: ['SQL', 'Normalization', 'Indexing', 'Transactions'],
  ),
  CourseCard(
    code: 'CSE 3105',
    title: 'Computer Networks',
    teacher: 'M. H. Khan',
    credit: 3.0,
    icon: Icons.router,
    color: Color(0xFFD97706),
    topics: ['TCP/IP', 'Routing', 'DNS', 'Sockets'],
  ),
  CourseCard(
    code: 'CSE 3107',
    title: 'Microprocessors',
    teacher: 'T. A. Rahat',
    credit: 3.0,
    icon: Icons.developer_board,
    color: Color(0xFF9333EA),
    topics: ['8086', 'Assembly', 'Interrupts', 'I/O'],
  ),
  CourseCard(
    code: 'MATH 3121',
    title: 'Numerical Methods',
    teacher: 'N. A. Siddique',
    credit: 3.0,
    icon: Icons.functions,
    color: Color(0xFFDC2626),
    topics: ['Interpolation', 'Root finding', 'Integration'],
  ),
];

// ============================================================================
// STEP 2 — The page. ListView.builder makes one card per item.
// ============================================================================

class CourseCardsPage extends StatelessWidget {
  const CourseCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Cards'),
        centerTitle: true,
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEEF2FF), Color(0xFFF8FAFC), Color(0xFFE0E7FF)],
          ),
        ),
        child: SafeArea(
          // ListView.builder only builds the cards that are visible.
          // itemCount = how many, itemBuilder = how to build cards[i].
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: kCourses.length,
            itemBuilder: (context, i) {
              return _CourseTile(course: kCourses[i]);
            },
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// STEP 3 — One card, extracted into its own widget.
// ============================================================================

class _CourseTile extends StatelessWidget {
  final CourseCard course;

  const _CourseTile({required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 5,
      shadowColor: course.color.withValues(alpha: 0.25),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Top row: icon + code/title + credit badge ----
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: course.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(course.icon, color: course.color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.code,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: course.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: course.color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${course.credit} cr',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 12),

            // ---- Topic chips: a Wrap, so they flow onto the next line ----
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: course.topics.map((topic) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    topic,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 14),

            // ---- Bottom row: teacher ----
            Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: course.color.withValues(alpha: 0.12),
                  child: Text(
                    course.teacher.isNotEmpty
                        ? course.teacher[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: course.color,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    course.teacher,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.black.withValues(alpha: 0.25),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
