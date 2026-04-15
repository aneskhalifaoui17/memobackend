import 'dart:async';
import 'package:flutter/material.dart';

// 1. THE MODEL
class StudyModule {
  final String name;
  final int minutes;
  final Color color;

  StudyModule({
    required this.name,
    required this.minutes,
    required this.color,
  });
}

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  Timer? _timer;
  late int _secondsRemaining;
  bool _isRunning = false;

  final List<StudyModule> _modules = [
    StudyModule(name: "Focus", minutes: 25, color: Colors.redAccent),
    StudyModule(name: "Mathematics", minutes: 45, color: Colors.redAccent),
    StudyModule(name: "Comp. Security", minutes: 60, color: Colors.redAccent),
    StudyModule(name: "Software Eng.", minutes: 30, color: Colors.redAccent),
  ];

  late StudyModule _selectedModule;

  @override
  void initState() {
    super.initState();
    _selectedModule = _modules.first;
    _secondsRemaining = _selectedModule.minutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _timer?.cancel();
            _isRunning = false;
            _showFinishedDialog();
          }
        });
      });
    }
    setState(() => _isRunning = !_isRunning);
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // --- NEW: THE MISSING PIECE ---
void _showEditDeleteOptions(StudyModule module, Offset tapPosition) {
    showMenu<String>( // Added <String> here to match your values
      context: context,
      position: RelativeRect.fromLTRB(
        tapPosition.dx, 
        tapPosition.dy, 
        tapPosition.dx + 1, 
        tapPosition.dy + 1
      ),
      color: const Color(0xFF2C2C2E), 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // THE FIX IS RIGHT HERE:
      items: <PopupMenuEntry<String>>[ 
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: const [
              Icon(Icons.edit_outlined, color: Colors.white70, size: 20),
              SizedBox(width: 12),
              Text("Edit", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        
        const PopupMenuDivider(height: 1), // This was confusing Dart!
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: const [
              Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              SizedBox(width: 12),
              Text("Delete", style: TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'edit') {
        _showEditModuleDialog(module);
      } else if (value == 'delete') {
        setState(() {
          _modules.remove(module);
          if (_selectedModule == module && _modules.isNotEmpty) {
            _selectedModule = _modules.first;
            _secondsRemaining = _selectedModule.minutes * 60;
          }
        });
      }
    });
  }

  void _showEditModuleDialog(StudyModule module) {
    final TextEditingController nameEditController = TextEditingController(text: module.name);
    final TextEditingController timeEditController = TextEditingController(text: module.minutes.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Edit Module", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameEditController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Name", labelStyle: TextStyle(color: Colors.white38)),
            ),
            TextField(
              controller: timeEditController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Minutes", labelStyle: TextStyle(color: Colors.white38)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                int index = _modules.indexOf(module);
                int newMinutes = int.tryParse(timeEditController.text) ?? module.minutes;
                
                _modules[index] = StudyModule(
                  name: nameEditController.text,
                  minutes: newMinutes,
                  color: module.color,
                );

                if (_selectedModule == module) {
                  _selectedModule = _modules[index];
                  _secondsRemaining = newMinutes * 60;
                }
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showModulePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select Subject", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              ..._modules.map((m) {
              Offset tapPosition = Offset.zero; // To store where you touched

              return GestureDetector(
                // Capture the position before the long press triggers
                onTapDown: (details) => tapPosition = details.globalPosition,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF2C2C2E),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: _selectedModule == m ? Colors.redAccent : Colors.white24,
                    ),
                  ),
                  title: Text(m.name, style: const TextStyle(color: Colors.white)),
                  trailing: Text("${m.minutes}m", style: const TextStyle(color: Colors.white38)),
                  onTap: () {
                    setState(() {
                      _selectedModule = m;
                      _secondsRemaining = m.minutes * 60;
                      _isRunning = false;
                      _timer?.cancel();
                    });
                    Navigator.pop(context);
                  },
                  onLongPress: () {
                    // No need to Navigator.pop(context) here if you want it to 
                    // feel like the overlay in your reference image!
                    _showEditDeleteOptions(m, tapPosition);
                  },
                ),
              );
            }).toList(),  
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showFinishedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Time's Up!", style: TextStyle(color: Colors.white)),
        content: const Text("Great job focusing!", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text("Academic Timer", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_formatTime(_secondsRemaining), style: const TextStyle(fontSize: 90, fontWeight: FontWeight.bold, color: Colors.white)),
            GestureDetector(
              onTap: _showModulePicker,
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white10)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 10),
                    Text(_selectedModule.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    const Icon(Icons.chevron_right, color: Colors.white38),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
            SizedBox(
              width: 220, height: 60,
              child: ElevatedButton(
                onPressed: _toggleTimer,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                child: Text(_isRunning ? "PAUSE" : "START FOCUS", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}