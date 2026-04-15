import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class LocalVaultGallery extends StatefulWidget {
  const LocalVaultGallery({super.key});

  @override
  State<LocalVaultGallery> createState() => _LocalVaultGalleryState();
}

class _LocalVaultGalleryState extends State<LocalVaultGallery> {
  List<File> _savedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadImages(); // Load existing photos when the app starts
  }

  // --- LOGIC: LOAD IMAGES FROM ANDROID STORAGE ---
  Future<void> _loadImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final List<FileSystemEntity> files = directory.listSync();
    
    setState(() {
      _savedImages = files
          .whereType<File>()
          .where((file) => file.path.endsWith('.jpg'))
          .toList();
    });
  }

  // --- LOGIC: TAKE PHOTO AND SAVE TO VAULT ---
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = "vault_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final File localFile = File('${directory.path}/$fileName');

      // Copy the temp camera photo to our permanent vault folder
      await File(photo.path).copy(localFile.path);
      
      _loadImages(); // Refresh the grid
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Academic Vault", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: _savedImages.isEmpty
          ? const Center(child: Text("No photos in the vault yet", style: TextStyle(color: Colors.white38)))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _savedImages.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _savedImages[index],
                    fit: BoxFit.cover,
                    // Critical for Android performance:
                    cacheWidth: 300, 
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: _takePhoto,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }
}