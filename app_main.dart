import 'package:flutter/material.dart';

void main() {
  runApp(const QuickInfoApp());
}

/// A tiny data holder for one flashcard.
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
];

class QuickInfoApp extends StatelessWidget {
  const QuickInfoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Info',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

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
      // Subtly styled background: a soft vertical gradient.
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

/// The main focus card.
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
              // ---- Category badge (pill tag) ----
              CategoryBadge(label: data.category),

              const SizedBox(height: 20),

              // ---- Main content ----
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

              // ---- Author / reference row ----
              AuthorRow(name: data.author, reference: data.reference),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small pill tag at the top of the card.
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

/// Bottom row: avatar icon + name + reference.
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
