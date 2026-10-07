import 'package:flutter/material.dart';
import 'main.dart';

class _CourseRow {
  TextEditingController creditCtrl;
  String grade;

  _CourseRow({double credit = 3.0, this.grade = 'A'})
      : creditCtrl = TextEditingController(text: credit.toString());
}

class CgpaCalculatorPage extends StatefulWidget {
  const CgpaCalculatorPage({super.key});

  @override
  State<CgpaCalculatorPage> createState() => _CgpaCalculatorPageState();
}

class _CgpaCalculatorPageState extends State<CgpaCalculatorPage> {
  final List<_CourseRow> _courses = [
    _CourseRow(credit: 3, grade: 'A'),
    _CourseRow(credit: 3, grade: 'A'),
    _CourseRow(credit: 3, grade: 'B+'),
  ];

  double? _cgpa;
  double? _totalCredits;

  void _addCourse() {
    setState(() {
      _courses.add(_CourseRow());
    });
  }

  void _removeCourse(int index) {
    if (_courses.length <= 1) return;
    setState(() {
      _courses[index].creditCtrl.dispose();
      _courses.removeAt(index);
    });
  }

  void _calculate() {
    double totalPoints = 0;
    double totalCredits = 0;
    bool ok = true;

    for (final c in _courses) {
      final credit = double.tryParse(c.creditCtrl.text);
      final gp = kGradePoints[c.grade];
      if (credit == null || gp == null || credit <= 0) {
        ok = false;
        break;
      }
      totalCredits += credit;
      totalPoints += credit * gp;
    }

    if (!ok || totalCredits == 0) {
      setState(() {
        _cgpa = null;
        _totalCredits = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid credits and grades.')),
      );
      return;
    }

    setState(() {
      _totalCredits = totalCredits;
      _cgpa = totalPoints / totalCredits;
    });
  }

  void _reset() {
    setState(() {
      for (final c in _courses) {
        c.creditCtrl.dispose();
      }
      _courses
        ..clear()
        ..addAll([
          _CourseRow(credit: 3, grade: 'A'),
          _CourseRow(credit: 3, grade: 'A'),
          _CourseRow(credit: 3, grade: 'B+'),
        ]);
      _cgpa = null;
      _totalCredits = null;
    });
  }

  @override
  void dispose() {
    for (final c in _courses) {
      c.creditCtrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CGPA Calculator'),
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
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _courses.length + 1,
                  itemBuilder: (ctx, i) {
                    if (i == _courses.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: OutlinedButton.icon(
                          onPressed: _addCourse,
                          icon: const Icon(Icons.add, color: Color(0xFF4F46E5)),
                          label: const Text('Add Course',
                              style: TextStyle(color: Color(0xFF4F46E5))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF4F46E5)),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      );
                    }
                    final course = _courses[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Text(
                              '${i + 1}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: course.creditCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Credits',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value: course.grade,
                                decoration: const InputDecoration(
                                  labelText: 'Grade',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: kGradePoints.keys
                                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                    .toList(),
                                onChanged: (v) => setState(() => course.grade = v!),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              onPressed: () => _removeCourse(i),
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_cgpa != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Total Credits', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                            _totalCredits!.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('CGPA', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                            _cgpa!.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _reset,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _calculate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Calculate CGPA', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
