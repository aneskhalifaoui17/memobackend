import 'package:flutter/material.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:table_calendar/table_calendar.dart';



class TaskCalendarCard extends StatelessWidget {
  const TaskCalendarCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CalendarPage()),
        );
      },
      child: Container(
        // Reduced horizontal padding and vertical height
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16), // Slightly tighter corners
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            // Smaller, cleaner icon container
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calendar_today_rounded, color: Colors.redAccent, size: 20),
            ),
            const SizedBox(width: 12),
            // Text info
            const Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Task Calendar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15, // Smaller font
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Daily schedule",
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
            // Minimalist arrow
            const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
  
}


class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();

  List<AnytimeTask> _allTasks = []; 

List<AnytimeTask> get _filteredTasks {
  // Now this correctly points to the list above
  return _allTasks.where((task) {
    return task.date.year == _selectedDate.year &&
           task.date.month == _selectedDate.month &&
           task.date.day == _selectedDate.day;
  }).toList();
}


  // 2. ADD CONTROLLERS: To grab the text you type in the pop-up
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskNoteController = TextEditingController();

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Academic Vault', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // --- THE CALENDAR STRIP INSIDE A BOX ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E), // A subtle light-gray/dark-gray
                borderRadius: BorderRadius.circular(20), // Round edges
              ),
              child: TableCalendar(
                focusedDay: _selectedDate,
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                headerVisible: true,
                calendarFormat: CalendarFormat.week,
                startingDayOfWeek: StartingDayOfWeek.monday,
                rowHeight: 60,
                daysOfWeekHeight: 25,
                
                // Keep the selection trait
                selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                  });
                },

                // Styles to look good inside the box
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                  weekendStyle: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(color: Colors.white, fontSize: 16),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                ),
                calendarStyle: const CalendarStyle(
                  isTodayHighlighted: true,
                  selectedDecoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(color: Colors.white),
                  weekendTextStyle: TextStyle(color: Colors.white60),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // --- ANYTIME SECTION ---
          // --- ANYTIME SECTION ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Updates count based on selected date
                Text(
                  "Anytime (${_filteredTasks.length})", 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // 1. DYNAMIC LIST: This shows the gray boxes for the selected day
                ..._filteredTasks.map((task) => _buildTaskItem(task)).toList(),

                // 2. THE ADD BUTTON: Always stays below the list
                GestureDetector(
                  onTap: () => _showAddTaskDialog(),
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.grey),
                        Text(" Add an Anytime task", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- DAILY PLAN ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Daily plan", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
              ),
            ),
          ),

          // --- EMPTY STATE / TASK LIST ---
          Expanded(
            child: Center(
              child: Text(
                "No tasks for ${_selectedDate.day}/${_selectedDate.month}",
                style: const TextStyle(color: Colors.white38),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    _taskNameController.clear(); // Clear old text
    _taskNoteController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text("New Anytime Task", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskNameController, // Attach the controller
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Task Name",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _taskNoteController, // Attach the controller
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Add a note...",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
      onPressed: () {
        if (_taskNameController.text.isNotEmpty) {
          setState(() {
            _allTasks.add(AnytimeTask(
              id: DateTime.now().toString(),
              name: _taskNameController.text,
              note: _taskNoteController.text,
              date: _selectedDate, // <--- Assigns it to the HIGHLIGHTED date
            ));
          });
        }
        Navigator.pop(context);
      },
      child: const Text("Add"),
    ),
          ],
        );
      },
    );
  }
}

class AnytimeTask {
  final String id;
  final String name;
  final String note;

  final DateTime date; // <--- Add this

  AnytimeTask({
    required this.id, 
    required this.name, 
    this.note = '',
    required this.date,
  });
}
Widget _buildTaskItem(AnytimeTask task) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 15),
          const CircleAvatar(
            backgroundColor: Color(0xFFFF5E5E),
            radius: 15,
            child: Icon(Icons.timer_outlined, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 15),
          Text(task.name, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    ),
  );
}