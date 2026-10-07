import 'dart:async';
import 'package:flutter/material.dart';
import 'main.dart';

enum _TimerMode { focus, shortBreak, longBreak }

class StudyTimerPage extends StatefulWidget {
  const StudyTimerPage({super.key});

  @override
  State<StudyTimerPage> createState() => _StudyTimerPageState();
}

class _StudyTimerPageState extends State<StudyTimerPage> {
  static const Map<_TimerMode, int> kDurations = {
    _TimerMode.focus: 25,
    _TimerMode.shortBreak: 5,
    _TimerMode.longBreak: 15,
  };

  static const Map<_TimerMode, String> kModeLabels = {
    _TimerMode.focus: 'Focus',
    _TimerMode.shortBreak: 'Short Break',
    _TimerMode.longBreak: 'Long Break',
  };

  _TimerMode _mode = _TimerMode.focus;
  late int _remainingSec;
  bool _isRunning = false;
  int _completedSessions = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSec = kDurations[_mode]! * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    if (_remainingSec > 0) {
      setState(() => _remainingSec--);
    } else {
      _timer?.cancel();
      setState(() => _isRunning = false);
      _onComplete();
    }
  }

  void _onComplete() {
    if (_mode == _TimerMode.focus) {
      _completedSessions++;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${kModeLabels[_mode]} complete! 🎉'),
        duration: const Duration(seconds: 3),
        backgroundColor: _mode == _TimerMode.focus ? const Color(0xFF16A34A) : const Color(0xFF4F46E5),
      ),
    );
  }

  void _toggle() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      setState(() => _isRunning = true);
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSec = kDurations[_mode]! * 60;
    });
  }

  void _setMode(_TimerMode m) {
    _timer?.cancel();
    setState(() {
      _mode = m;
      _isRunning = false;
      _remainingSec = kDurations[m]! * 60;
    });
  }

  String _formatTime(int totalSec) {
    final m = (totalSec ~/ 60).toString().padLeft(2, '0');
    final s = (totalSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress {
    final total = kDurations[_mode]! * 60;
    return total == 0 ? 0 : 1 - (_remainingSec / total);
  }

  Color get _modeColor {
    switch (_mode) {
      case _TimerMode.focus:
        return const Color(0xFF4F46E5);
      case _TimerMode.shortBreak:
        return const Color(0xFF16A34A);
      case _TimerMode.longBreak:
        return const Color(0xFF0EA5E9);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Timer'),
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ModeChip(
                        label: 'Focus',
                        isSelected: _mode == _TimerMode.focus,
                        color: const Color(0xFF4F46E5),
                        onTap: () => _setMode(_TimerMode.focus),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ModeChip(
                        label: 'Short Break',
                        isSelected: _mode == _TimerMode.shortBreak,
                        color: const Color(0xFF16A34A),
                        onTap: () => _setMode(_TimerMode.shortBreak),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ModeChip(
                        label: 'Long Break',
                        isSelected: _mode == _TimerMode.longBreak,
                        color: const Color(0xFF0EA5E9),
                        onTap: () => _setMode(_TimerMode.longBreak),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 260,
                      height: 260,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 260,
                            height: 260,
                            child: CircularProgressIndicator(
                              value: _progress,
                              strokeWidth: 14,
                              backgroundColor: _modeColor.withOpacity(0.12),
                              valueColor: AlwaysStoppedAnimation(_modeColor),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                kModeLabels[_mode]!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                  color: _modeColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatTime(_remainingSec),
                                style: const TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: 3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh),
                      iconSize: 28,
                      style: IconButton.styleFrom(backgroundColor: Colors.white),
                    ),
                    const SizedBox(width: 24),
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: FilledButton(
                        onPressed: _toggle,
                        style: FilledButton.styleFrom(
                          backgroundColor: _modeColor,
                          shape: const CircleBorder(),
                          elevation: 4,
                        ),
                        child: Icon(_isRunning ? Icons.pause : Icons.play_arrow, size: 36),
                      ),
                    ),
                    const SizedBox(width: 24),
                    const SizedBox(width: 56, height: 56),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF16A34A)),
                      const SizedBox(width: 8),
                      Text(
                        'Completed sessions: $_completedSessions',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withOpacity(isSelected ? 0 : 0.3)),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : color,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
