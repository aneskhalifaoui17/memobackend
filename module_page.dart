import 'package:flutter/material.dart';
import 'main.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';


class ModuleDetailScreen extends StatefulWidget {
  final Module module;
  const ModuleDetailScreen({super.key, required this.module});
  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {
  final ImagePicker _picker = ImagePicker();

  void _showPhotoOptions(Chapter chapter) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Wrap(
          children: [
            _buildPickerTile(chapter: chapter, icon: Icons.camera_alt_outlined, title: "Take a Photo", source: ImageSource.camera),
            const Divider(color: Colors.white10),
            _buildPickerTile(chapter: chapter, icon: Icons.photo_library_outlined, title: "Choose from Gallery", source: ImageSource.gallery),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerTile({required Chapter chapter, required IconData icon, required String title, required ImageSource source}) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: const Color(0xFF2C2C2E), child: Icon(icon, color: Colors.redAccent)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () async {
        Navigator.pop(context);
        final XFile? image = await _picker.pickImage(source: source);
        if (image != null) {
          final Directory appDocDir = await getApplicationDocumentsDirectory();
          String fileName = "vault_${DateTime.now().millisecondsSinceEpoch}.jpg";
          String permanentPath = "${appDocDir.path}/$fileName";
          final File savedFile = await File(image.path).copy(permanentPath);

          setState(() {
            chapter.imagePaths.add(savedFile.path);
          });
          saveAllData(myModules); // CRITICAL: Save after photo added
        }
      },
    );
  }

  void _addChapter(String title) {
    setState(() {
      widget.module.chapters.add(Chapter(title: title));
    });
    saveAllData(myModules); // Save after chapter name added
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: Text(widget.module.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.module.chapters.length,
        itemBuilder: (context, index) {
          final chapter = widget.module.chapters[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(20)),
            child: ExpansionTile(
              leading: const Icon(Icons.menu_book_rounded, color: Colors.redAccent),
              title: Text(chapter.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                    itemCount: chapter.imagePaths.length + 1,
                    itemBuilder: (context, imgIndex) {
                      if (imgIndex == chapter.imagePaths.length) {
                        return GestureDetector(
                          onTap: () => _showPhotoOptions(chapter),
                          child: Container(
                            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.add_a_photo_outlined, color: Colors.white60),
                          ),
                        );
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(chapter.imagePaths[imgIndex]), fit: BoxFit.cover),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () => _showAddDialog(context, _addChapter, "Chapter"),
        child: const Icon(Icons.post_add),
    ),
    );
  }
}

// --- 5. SHARED HELPERS ---
void _showAddDialog(BuildContext context, Function(String) onSave, String hint) {
  TextEditingController controller = TextEditingController();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text("New $hint", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Enter $hint name",
          hintStyle: const TextStyle(color: Colors.white38),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
        TextButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              onSave(controller.text);
              Navigator.pop(context);
            }
          },
          child: const Text('Add', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

Future<void> saveAllData(List<Module> modules) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/vault_structure.json');
  List<Map<String, dynamic>> jsonData = modules.map((module) {
    return {
      'name': module.name,
      'chapters': module.chapters.map((chapter) {
        return {'title': chapter.title, 'imagePaths': chapter.imagePaths};
      }).toList(),
    };
  }).toList();
  await file.writeAsString(jsonEncode(jsonData));
}





class moduleScreen extends StatefulWidget {
  const moduleScreen({super.key});

  @override
  State<moduleScreen> createState() => _moduleScreenState();
}

class _moduleScreenState extends State<moduleScreen> {

  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _buildModuleGrid(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        // FIX: Change "Chapter" to "Module" and call the correct function
        onPressed: () => _showAddDialog(context, _addModule, "Module"), 
        child: const Icon(Icons.folder_copy_outlined),
      ),
    );
  }

  // FIX: This function now adds a module, not a chapter
  void _addModule(String name) {
    setState(() {
      myModules.add(Module(name: name, chapters: []));
    });
    saveAllData(myModules); 
  }
  Widget _buildModuleGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.0,
      ),
      itemCount: myModules.length,
      itemBuilder: (context, index) {
        final module = myModules[index];
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ModuleDetailScreen(module: module)),
            ).then((_) => setState(() {})); // Refresh grid when coming back
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.folder_rounded, color: Colors.redAccent, size: 28),
                const Spacer(),
                Text(module.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text("${module.chapters.length} items", style: const TextStyle(color: Colors.white38, fontSize: 13)),
              ],
            ),
          ),
        );
      },
    );
  }
}
