import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class ImagePickerField extends StatefulWidget {
  final String? initialImageUrl;
  final Function(String? base64Image) onImageSelected;
  final String label;

  const ImagePickerField({
    Key? key,
    this.initialImageUrl,
    required this.onImageSelected,
    this.label = 'Poster de la Película',
  }) : super(key: key);

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  Uint8List? _imageBytes;
  String? _base64Image;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    setState(() => _isLoading = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.bytes != null) {
          final base64 = base64Encode(file.bytes!);

          setState(() {
            _imageBytes = file.bytes;
            _base64Image = 'data:image/${file.extension ?? 'jpg'};base64,$base64';
            _isLoading = false;
          });

          widget.onImageSelected(_base64Image);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error picking image: $e');
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _clearImage() {
    setState(() {
      _imageBytes = null;
      _base64Image = null;
    });
    widget.onImageSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = _imageBytes != null || widget.initialImageUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.image,
              size: 20,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),

        // Image Preview or Placeholder
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
            borderRadius: AppSpacing.borderRadiusMD,
            border: Border.all(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
              width: 2,
            ),
          ),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : hasImage
                  ? Stack(
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: AppSpacing.borderRadiusMD,
                          child: _imageBytes != null
                              ? Image.memory(
                                  _imageBytes!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  widget.initialImageUrl!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.broken_image, size: 48),
                                          SizedBox(height: 8),
                                          Text('Error al cargar imagen'),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                        // Remove button
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: _clearImage,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )
                  : InkWell(
                      onTap: _pickImage,
                      borderRadius: AppSpacing.borderRadiusMD,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 48,
                              color: AppColors.primary,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Click para seleccionar imagen',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'JPG, PNG, WEBP (Max 5MB)',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
        ),

        // Change Image Button (when image is selected)
        if (hasImage) ...[
          SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: Icon(Icons.change_circle),
              label: Text('Cambiar Imagen'),
              onPressed: _pickImage,
            ),
          ),
        ],
      ],
    );
  }
}
