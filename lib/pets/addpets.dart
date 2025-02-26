import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddPetPage extends StatefulWidget {
  const AddPetPage({super.key});

  @override
  _AddPetPageState createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  File? _selectedImage;

  String _gender = 'Male';
  String _petType = 'Dog';
  DateTime? _selectedBirthday;

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  /// Function to Pick Image (Camera/Gallery)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        debugPrint("Image Selected: ${image.path}");
        setState(() {
          _selectedImage = File(image.path);
          _imageController.text = image.path; // Store the image path (if needed)
        });
      } else {
        debugPrint("No image selected."); // User canceled the selection
      }
    }catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _savePet() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('pets').add({
        'name': _nameController.text.trim(),
        'breed': _breedController.text.trim(),
        'age': int.parse(_ageController.text.trim()),
        'birthday': _selectedBirthday != null ? _selectedBirthday!.toIso8601String() : null,
        'gender': _gender,
        'petType': _petType,
        'image': _imageController.text.trim(),
        'notes': _notesController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Pet added successfully!"),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Pet")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Pet Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    validator: (value) => value!.isEmpty ? "Please enter pet name" : null,
                  ),
                ),
                const SizedBox(height: 15),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DropdownButtonFormField<String>(
                    value: _petType,
                    items: ["Dog", "Cat", "Other"]
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) => setState(() => _petType = value!),
                    decoration: InputDecoration(
                      labelText: "Pet Type",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Adjust padding
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _breedController,
                    decoration: InputDecoration(
                      labelText: "Breed",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    validator: (value) => value!.isEmpty ? "Please enter breed" : null,
                  ),
                ),
                const SizedBox(height: 15),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Age",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    validator: (value) => value!.isEmpty ? "Please enter pet name" : null,
                  ),
                ),
                const SizedBox(height: 15),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    readOnly: true, // Prevent keyboard input
                    controller: TextEditingController(
                      text: _selectedBirthday != null
                          ? "${_selectedBirthday!.toLocal()}".split(' ')[0]
                          : "",
                    ),
                    decoration: InputDecoration(
                      labelText: "Birthday",
                      hintText: "Select Date",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    onTap: () => _selectBirthday(context), // Open date picker on tap
                  ),
                ),
                const SizedBox(height: 15),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DropdownButtonFormField<String>(
                    value: _gender,
                    items: ["Male", "Female"]
                        .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                        .toList(),
                    onChanged: (value) => setState(() => _gender = value!),
                    decoration: InputDecoration(
                      labelText: "Gender",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Adjust padding for height
                    ),
                  ),
                ),
                const SizedBox(height: 85),

                // Display Selected Image (if any)
                if (_selectedImage != null)
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.gallery), // Change image when tapped
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: FileImage(_selectedImage!),
                      ),
                    ),
                  ),

                // Image Selection Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Take Photo"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.image),
                      label: const Text("Upload"),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 100, // Large area for notes
                    child: TextFormField(
                      controller: _notesController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null, // Expands automatically
                      decoration: InputDecoration(
                        labelText: "Notes (Optional)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignLabelWithHint: true, // Aligns label to the top
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.center, // Centers the button
                  child: SizedBox(
                    width: 200, // Shorter button width
                    child: ElevatedButton(
                      onPressed: _savePet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Rounded corners
                      ),
                      child: const Text("Save Pet", style: TextStyle(color: Colors.white70)),
                    ),
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
