import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class AddReviewScreen extends StatefulWidget {
  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  String bookName = '';
  int rating = 1;
  String reviewText = '';
  File? reviewImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        reviewImage = File(pickedFile.path);
      });
    }
  }

  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      if (await Permission.camera.request().isGranted) {
        // If granted, allow camera access
        pickImage(ImageSource.camera);
      } else {
        _showPermissionDeniedMessage();
      }
    } else if (status.isGranted) {
      // If already granted, allow camera access
      pickImage(ImageSource.camera);
    } else {
      _showPermissionDeniedMessage();
    }
  }

  void _showPermissionDeniedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Camera permission is required to take pictures.')),
    );
  }

  Future<void> submitReview() async {
    final url = Uri.parse('http://172.20.10.4:8000/api/reviews');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('No token found. Please log in.');
      return;
    }

    try {
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json'
        ..fields['book_name'] = bookName
        ..fields['rating'] = rating.toString()
        ..fields['review_text'] = reviewText;

      if (reviewImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'review_image',
          reviewImage!.path,
        ));
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Review submitted successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Review'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Book Name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onChanged: (value) {
                  setState(() {
                    bookName = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the book name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Rating',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                value: rating,
                items: List.generate(5, (index) {
                  return DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1} star${index == 0 ? '' : 's'}'),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      rating = value;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Review Text',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                maxLines: 3,
                onChanged: (value) {
                  setState(() {
                    reviewText = value;
                  });
                },
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      await pickImage(ImageSource.gallery);
                    },
                    icon: Icon(Icons.image),
                    label: Text('Gallery'),
                  ),
                  ElevatedButton.icon(
                    onPressed: requestCameraPermission, // Request camera permission and open camera
                    icon: Icon(Icons.camera),
                    label: Text('Camera'),
                  ),
                ],
              ),
              if (reviewImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    elevation: 4,
                    child: Image.file(reviewImage!, height: 100, fit: BoxFit.cover),
                  ),
                ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    submitReview();
                  }
                },
                child: Text('Submit Review'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
