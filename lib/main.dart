import 'package:flutter/material.dart';
import 'cgpa_calculator.dart';
import 'study_timer.dart';
import 'cse3100_page.dart';
import 'routine_table_page.dart';
import 'course_cards_page.dart';
import 'weather_table_page.dart';
import 'map_page.dart';

void main() {
  runApp(const QuickInfoApp());
}

class InfoCardData {
  final String category;
  final String content;
  final String author;
  final String reference;

  const InfoCardData({
    required this.category,
    required this.content,
    required this.author,
    required this.reference,
  });
}

const List<InfoCardData> kCards = [
  InfoCardData(
    category: 'Flutter Tip #1',
    content:
        'Everything in Flutter is a widget. Layout, styling, and even padding '
        'are widgets you compose together like Lego bricks.',
    author: 'Flutter Docs',
    reference: 'flutter.dev/basics',
  ),
  InfoCardData(
    category: 'Quote',
    content:
        'Simplicity is the soul of efficiency. Write the smallest thing that '
        'works, then make it beautiful.',
    author: 'Austin Freeman',
    reference: 'The Eye of Osiris',
  ),
  InfoCardData(
    category: 'Flutter Tip #2',
    content:
        'Prefer const constructors wherever you can. Flutter skips rebuilding '
        'const widgets entirely, which keeps your UI fast for free.',
    author: 'Performance Guide',
    reference: 'flutter.dev/perf',
  ),
  InfoCardData(
    category: 'Concept',
    content:
        'setState() tells Flutter that this widget’s state changed, so the '
        'framework schedules a rebuild of just that subtree.',
    author: 'State Basics',
    reference: 'api.flutter.dev',
  ),
  InfoCardData(
    category: 'Flutter Tutotial',
    content:
        'Flutter is a UI toolkit for building cross-platform applications.',
    author: 'Md. Rakib Trofder',
    reference: 'baust-flutter-learning.lovable.app',
  ),
];

const Map<String, double> kGradePoints = {
  'A+': 4.00,
  'A': 3.75,
  'A-': 3.50,
  'B+': 3.25,
  'B': 3.00,
  'B-': 2.75,
  'C+': 2.50,
  'C': 2.25,
  'D': 2.00,
  'F': 0.00,
};

class QuickInfoApp extends StatelessWidget {
  const QuickInfoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BAUST Flutter Learning',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.school, size: 32, color: Color(0xFF4F46E5)),
                ),
                SizedBox(height: 12),
                Text(
                  'BAUST Learning',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Student Tools',
                  style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 13),
                ),
              ],
            ),
          ),
          _DrawerTile(
            icon: Icons.flash_on,
            title: 'Flashcards',
            subtitle: 'Learning tips & quotes',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => const HomePage(),
              ));
            },
          ),
          _DrawerTile(
            icon: Icons.computer,
            title: 'CSE 3100',
            subtitle: 'Course Info',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => const Cse3100Page(),
              ));
            },
          ),
          _DrawerTile(
            icon: Icons.calculate,
            title: 'CGPA Calculator',
            subtitle: 'Compute your result',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => const CgpaCalculatorPage(),
              ));
            },
          ),
          _DrawerTile(
            icon: Icons.timer,
            title: 'Study Timer',
            subtitle: 'Focus sessions (Pomodoro)',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => const StudyTimerPage(),
              ));
            },
          ),
          _DrawerTile(
            icon: Icons.grid_on,
            title: 'Class Routine',
            subtitle: 'Static table',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => const RoutineTablePage(),
              ));
            },
          ),
          _DrawerTile(
            icon: Icons.view_agenda,
            title: 'Course Cards',
            subtitle: 'Static card list',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => const CourseCardsPage(),
              ));
            },
          ),
          _DrawerTile(
            icon: Icons.table_chart,
            title: 'Weather Table',
            subtitle: 'Live data from a public API',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => const WeatherTablePage(),
              ));
            },
          ),
          _DrawerTile(
            icon: Icons.map,
            title: 'Map',
            subtitle: 'OpenStreetMap + markers',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => const MapPage(),
              ));
            },
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4F46E5)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}

// ============================================================================
// HOME PAGE (Flashcards)
// ============================================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  void _next() {
    setState(() {
      _index = (_index + 1) % kCards.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = kCards[_index];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InfoCard(data: card),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    onPressed: _next,
                    icon: const Icon(Icons.autorenew),
                    label: const Text('Next card'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: const StadiumBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_index + 1} of ${kCards.length}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.45),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SHARED UI: InfoCard, CategoryBadge, AuthorRow
// ============================================================================

class InfoCard extends StatelessWidget {
  final InfoCardData data;

  const InfoCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Card(
        elevation: 10,
        shadowColor: const Color(0xFF4F46E5).withOpacity(0.20),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CategoryBadge(label: data.category),
              const SizedBox(height: 20),
              Text(
                '“',
                style: TextStyle(
                  fontSize: 44,
                  height: 0.9,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4F46E5).withOpacity(0.25),
                ),
              ),
              Text(
                data.content,
                style: const TextStyle(
                  fontSize: 19,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 16),
              AuthorRow(name: data.author, reference: data.reference),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryBadge extends StatelessWidget {
  final String label;

  const CategoryBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF4F46E5).withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.20)),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: Color(0xFF4338CA),
        ),
      ),
    );
  }
}

class AuthorRow extends StatelessWidget {
  final String name;
  final String reference;

  const AuthorRow({super.key, required this.name, required this.reference});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFF4F46E5).withOpacity(0.12),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF4338CA),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                reference,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withOpacity(0.50),
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.format_quote_rounded,
          color: const Color(0xFF4F46E5).withOpacity(0.35),
        ),
      ],
    );
  }
}
