import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ozimiz_test_application/domain/entities/news.dart';
import 'package:path_provider/path_provider.dart';
import '../../application/blocs/news_bloc.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddNewsScreen extends StatefulWidget {
  final News? editingNews;
  final int? index;

  const AddNewsScreen({super.key, this.editingNews, this.index});

  @override
  State<AddNewsScreen> createState() => _AddNewsScreenState();
}

class _AddNewsScreenState extends State<AddNewsScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    if (widget.editingNews != null) {
      _titleController.text = widget.editingNews!.title;
      _descriptionController.text = widget.editingNews!.description;
      _imagePath = widget.editingNews!.imagePath;
      if (_imagePath != null && _imagePath!.startsWith('http')) {
        _imageUrlController.text = _imagePath!;
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final newPath = '${directory.path}/${pickedFile.name}';
      final newFile = await File(pickedFile.path).copy(newPath);
      setState(() {
        _imagePath = newFile.path;
        _imageUrlController.clear();
      });
    }
  }

  void _saveNews() {
    if (_titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty) {
      final news = News(
        title: _titleController.text,
        description: _descriptionController.text,
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        imagePath: _imageUrlController.text.isNotEmpty ? _imageUrlController.text : _imagePath,
      );
      if (widget.editingNews == null) {
        context.read<NewsBloc>().add(AddNewsEvent(news));
      } else {
        context.read<NewsBloc>().add(EditNewsEvent(widget.index!, news));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.editingNews == null ? 'Add News' : 'Edit News')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(
                labelText: 'Image URL (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: _imagePath != null
                  ? (_imagePath!.startsWith('http')
                      ? Image.network(_imagePath!, height: 200, width: double.infinity, fit: BoxFit.cover)
                      : Image.file(File(_imagePath!), height: 200, width: double.infinity, fit: BoxFit.cover))
                  : Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
                    ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image),
                  label: Text('Pick Image'),
                ),
                ElevatedButton.icon(
                  onPressed: _saveNews,
                  icon: Icon(Icons.save),
                  label: Text(widget.editingNews == null ? 'Add News' : 'Save Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}