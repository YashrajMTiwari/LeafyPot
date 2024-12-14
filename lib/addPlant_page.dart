import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AddPlantPage extends StatefulWidget {
  const AddPlantPage({super.key});

  @override
  _AddPlantPageState createState() => _AddPlantPageState();
}

class _AddPlantPageState extends State<AddPlantPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  File? _image;  // Variable to hold the selected image

  final ImagePicker _picker = ImagePicker(); // For picking the image

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Update image when picked
      });
    }
  }

  // Function to upload the image to Firebase Storage and get the URL
  Future<String> _uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child('plant_images/$fileName');
      UploadTask uploadTask = storageReference.putFile(image);
      await uploadTask;
      String downloadUrl = await storageReference.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Error uploading image: $e");
    }
  }

  // Function to add the plant to Firestore
  Future<void> _addPlant() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) {
          throw Exception("User is not logged in.");
        }

        String? imageUrl;

        // If the user has selected an image, upload it
        if (_image != null) {
          imageUrl = await _uploadImage(_image!);
        }

        await FirebaseFirestore.instance.collection('plants').add({
          'plant_name': _nameController.text,
          'plant_type': _typeController.text,
          'user_id': userId,
          'plant_health': '',
          'plant_mos': '',
          'plant_image': imageUrl ?? '', // Save the image URL if available
        });

        _nameController.clear();
        _typeController.clear();
        setState(() {
          _image = null; // Clear the selected image after adding the plant
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Plant added successfully!'),
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error adding plant: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Plant'),
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(color: Colors.black),
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color.fromRGBO(63, 107, 81, 1).withOpacity(0.1),
                        ),
                        child: _image == null
                            ? const Icon(
                          Icons.camera_alt,
                          color: Color.fromRGBO(63, 107, 81, 1),
                          size: 50,
                        )
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _image!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Plant Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the plant name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _typeController,
                      decoration: const InputDecoration(labelText: 'Plant Type'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the plant type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await _addPlant();
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(63, 107, 81, 1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      ),
                      child: const Text('Add Plant'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
