import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

typedef OnImageSelected = Future<void> Function(File imageFile);

class ImageUploadField extends StatefulWidget {
  final String label;
  final String? currentImageUrl;
  final OnImageSelected onImageSelected;
  final bool isUploading;
  final double uploadProgress;
  final String? errorMessage;

  const ImageUploadField({
    super.key,
    required this.label,
    this.currentImageUrl,
    required this.onImageSelected,
    this.isUploading = false,
    this.uploadProgress = 0.0,
    this.errorMessage,
  });

  @override
  State<ImageUploadField> createState() => _ImageUploadFieldState();
}

class _ImageUploadFieldState extends State<ImageUploadField> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        await widget.onImageSelected(_selectedImage!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.currentImageUrl != null || _selectedImage != null;
    final imageUrl = widget.currentImageUrl;
    final selectedImagePath = _selectedImage?.path;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              if (hasImage)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Image preview
                    if (selectedImagePath != null)
                      Image.file(
                        _selectedImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    else if (imageUrl != null)
                      Image.network(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    // Upload progress overlay
                    if (widget.isUploading)
                      Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.black26,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: widget.uploadProgress,
                                backgroundColor: Colors.white30,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${(widget.uploadProgress * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                )
              else
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No image selected',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Action buttons
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: widget.isUploading
                          ? null
                          : () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                    ElevatedButton.icon(
                      onPressed: widget.isUploading
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.image),
                      label: const Text('Gallery'),
                    ),
                    if (hasImage && !widget.isUploading)
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                          });
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Clear'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (widget.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.errorMessage!,
              style: TextStyle(color: Colors.red[600], fontSize: 12),
            ),
          ),
      ],
    );
  }
}
