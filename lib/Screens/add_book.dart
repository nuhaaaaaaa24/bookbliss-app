import 'dart:convert';
import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class AddBookScreen extends StatefulWidget {
  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  File? _coverImage; // Store the selected image
  String _selectedStatus = 'want_to_read'; // Default status
  String? _errorMessage;

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _coverImage = File(image.path);
          _errorMessage = null; // Reset any previous error message
        });
      } else {
        setState(() {
          _errorMessage = 'No image selected.';
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _errorMessage = 'Platform exception occurred: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  Future<void> _addBook() async {
    final String apiUrl = 'http://172.20.10.4:8000/api/books'; // Your store endpoint
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _errorMessage = 'User not logged in. Please log in again.';
      });
      return;
    }

    final request = http.MultipartRequest('POST', Uri.parse(apiUrl))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['title'] = _titleController.text
      ..fields['author'] = _authorController.text
      ..fields['status'] = _selectedStatus;

    if (_coverImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'cover_image',
        _coverImage!.path,
      ));
    }

    final response = await request.send();

    if (response.statusCode == 201) {
      Navigator.pop(context); // Go back to the previous screen on success
    } else {
      final responseData = await response.stream.bytesToString();
      setState(() {
        _errorMessage = 'Failed to add book: $responseData';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCircularTextField(_titleController, 'Title'),
            SizedBox(height: 16.0),
            _buildCircularTextField(_authorController, 'Author'),
            SizedBox(height: 16.0),
            _coverImage != null
                ? Image.file(
              _coverImage!,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            )
                : Text('No image selected.'),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Cover Image'),
            ),
            DropdownButton<String>(
              value: _selectedStatus,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue!;
                });
              },
              items: <String>['want_to_read', 'want_to_buy', 'favorites']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.replaceAll('_', ' ').capitalize()),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addBook,
              child: Text('Add Book'),
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: 16.0),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCircularTextField(TextEditingController controller, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none, // Remove the default underline
          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return this.isEmpty
        ? this
        : this[0].toUpperCase() + this.substring(1);
  }
}
