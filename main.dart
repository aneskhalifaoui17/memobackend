import 'package:first_attemp/pomodoro.dart';
import 'package:flutter/material.dart';
import 'plan.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'profile.dart';
import 'feed.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'module_page.dart';
// --- 1. THE GLOBAL LIST (ONLY ONE VERSION) ---
// This is the "Single Source of Truth" for your whole app.
List<Module> myModules = []; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // This is the magic line that connects your app to the cloud
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MyNavigationPage(),
    );
  }
}

// --- 2. DATA MODELS ---
class Chapter {
  String title;
  List<String> imagePaths;

  Chapter({required this.title, List<String>? imagePaths}) 
      : this.imagePaths = imagePaths ?? [];
}

class Module {
  String name;
  List<Chapter> chapters;
  Module({required this.name, List<Chapter>? chapters})
      : this.chapters = chapters ?? [];
}

// --- 3. MAIN NAVIGATION PAGE ---
class MyNavigationPage extends StatefulWidget {
  const MyNavigationPage({super.key});
  @override
  State<MyNavigationPage> createState() => _MyNavigationPageState();
}

class _MyNavigationPageState extends State<MyNavigationPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAllData(); // Loads data from disk when the app turns on
  }

  Future<void> _loadAllData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/vault_structure.json');

      if (await file.exists()) {
        final String content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        setState(() {
          // Updating the GLOBAL myModules
          myModules = jsonList.map((m) {
            return Module(
              name: m['name'],
              chapters: (m['chapters'] as List).map((c) {
                return Chapter(
                  title: c['title'],
                  imagePaths: List<String>.from(c['imagePaths']),
                );
              }).toList(),
            );
          }).toList();
        });
      } else {
        // If no file exists, start with a default module
        setState(() {
          myModules = [Module(name: 'Mathematics')];
        });
      }
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  /*void _addModule(String name) {
  setState(() => myModules.add(Module(name: name)));
    saveAllData(myModules); // Save immediately
  }  */

  Widget _getPage() {
    switch (_selectedIndex) {
      case 0: return AcademicFeedScreen();
      case 1: return moduleScreen();
      case 2: return const TaskCalendarCard();
      case 3: return const PomodoroScreen();
      case 4: return const ProfileScreen();
      default: return AcademicFeedScreen();
    }
  }

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
      body: _getPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.auto_stories), label: 'feed'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'achievments'),
          BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: 'Pomodoro'),
          BottomNavigationBarItem(icon: Icon(Icons.mood), label: 'Me'),
        ],
      ),
      );
  }
}

// --- 4. MODULE DETAIL SCREEN ---
