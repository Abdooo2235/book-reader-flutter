import 'dart:io';
import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/helpers/ui_utils.dart';
import 'package:book_reader_app/providers/book_provider.dart';
import 'package:book_reader_app/providers/category_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class SubmitBookDialog extends StatefulWidget {
  const SubmitBookDialog({super.key});

  @override
  State<SubmitBookDialog> createState() => _SubmitBookDialogState();
}

class _SubmitBookDialogState extends State<SubmitBookDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pagesController = TextEditingController();

  File? _bookFile;
  File? _coverImage;
  int? _selectedCategoryId;
  String _selectedFileType = 'pdf';
  bool _isSubmitting = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _pagesController.dispose();
    super.dispose();
  }

  Future<void> _pickBookFile() async {
    try {
      FilePickerResult? result;

      // Try to pick files with proper error handling
      try {
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: allowedBookExtensions,
          allowMultiple: false,
        );
      } catch (e) {
        // Handle platform-specific initialization errors
        debugPrint('FilePicker error: $e');
        if (mounted) {
          String errorMessage = 'File picker not available.';
          if (e.toString().contains('LateInitializationError')) {
            errorMessage =
                'File picker is not initialized. Please restart the app.';
          } else if (e.toString().contains('permission')) {
            errorMessage =
                'Please grant file access permission in app settings.';
          }

          UiUtils.showErrorSnackBar(context, errorMessage);
        }
        return;
      }

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;

        // Check if file path exists
        if (pickedFile.path != null && pickedFile.path!.isNotEmpty) {
          final file = File(pickedFile.path!);

          // Verify file exists
          if (await file.exists()) {
            setState(() {
              _bookFile = file;
              // Auto-detect file type from extension
              final extension =
                  pickedFile.extension?.toLowerCase() ??
                  pickedFile.path!.split('.').last.toLowerCase();
              if (extension == 'epub') {
                _selectedFileType = 'epub';
              } else {
                _selectedFileType = 'pdf';
              }
            });
          } else {
            if (mounted) {
              UiUtils.showErrorSnackBar(
                context,
                'Selected file does not exist',
              );
            }
          }
        } else if (pickedFile.bytes != null) {
          // Handle web platform where path might be null but bytes are available
          // Save bytes to temporary file
          try {
            final tempDir = await getTemporaryDirectory();
            final extension = pickedFile.extension?.toLowerCase() ?? 'pdf';
            final tempFile = File(
              '${tempDir.path}/book_${DateTime.now().millisecondsSinceEpoch}.$extension',
            );
            await tempFile.writeAsBytes(pickedFile.bytes!);

            setState(() {
              _bookFile = tempFile;
              if (extension == 'epub') {
                _selectedFileType = 'epub';
              } else {
                _selectedFileType = 'pdf';
              }
            });
          } catch (e) {
            if (mounted) {
              UiUtils.showErrorSnackBar(
                context,
                'Error saving file: ${e.toString()}',
              );
            }
          }
        } else {
          if (mounted) {
            UiUtils.showErrorSnackBar(
              context,
              'Could not access selected file',
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        UiUtils.showErrorSnackBar(
          context,
          'Error picking file: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _pickCoverImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxImageWidth,
        maxHeight: maxImageHeight,
        imageQuality: imageQuality,
      );

      if (pickedFile != null) {
        setState(() {
          _coverImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        UiUtils.showErrorSnackBar(context, 'Error picking image: $e');
      }
    }
  }

  Future<void> _submitBook() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_bookFile == null) {
      UiUtils.showErrorSnackBar(
        context,
        'Please select a book file (PDF or EPUB)',
      );
      return;
    }

    if (_selectedCategoryId == null) {
      UiUtils.showErrorSnackBar(context, 'Please select a category');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);

      final result = await bookProvider.submitBook(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategoryId!,
        fileType: _selectedFileType,
        numberOfPages: int.parse(_pagesController.text.trim()),
        bookFile: _bookFile,
        coverImage: _coverImage,
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        if (result != null) {
          // Close dialog
          Navigator.pop(context);

          // Show success dialog with admin approval message
          _showSuccessDialog();
        } else {
          UiUtils.showErrorSnackBar(
            context,
            bookProvider.errorMessage ?? 'Failed to submit book',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        UiUtils.showErrorSnackBar(context, 'Error: ${e.toString()}');
      }
    }
  }

  void _showSuccessDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogColor = isDark ? surfaceColorDark : whiteColor;
    final textColor = isDark ? whiteColorDark : blackColor;
    final secondaryTextColor = isDark
        ? whiteColorDark.withValues(alpha: 0.7)
        : Colors.grey[700];
    final accentColor = isDark ? primaryColorDark : primaryColor;
    final successColor = isDark ? greenColorDark : greenColor;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: dialogColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: successColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: successColor, size: 50),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Book Submitted Successfully!',
                style: labelLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Message
              Text(
                'Your book "${_titleController.text}" has been submitted for review.',
                style: bodyMedium.copyWith(color: secondaryTextColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Admin Approval Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: accentColor, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your book is pending admin approval. You will be notified once it\'s approved and published.',
                        style: bodySmall.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // OK Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Got it',
                    style: labelMedium.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogColor = isDark ? surfaceColorDark : whiteColor;
    final headerColor = isDark
        ? scaffoldBackgroundColorDark
        : primaryColor.withValues(alpha: 0.05);
    final textColor = isDark ? whiteColorDark : blackColor;
    final secondaryTextColor = isDark
        ? whiteColorDark.withValues(alpha: 0.6)
        : Colors.grey[600];
    final accentColor = isDark ? primaryColorDark : primaryColor;
    final formFieldColor = isDark
        ? scaffoldBackgroundColorDark
        : scaffoldBackgroundColor;
    final closeButtonColor = isDark ? surfaceColorDark : Colors.grey[100];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: dialogColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: isDark ? 0.3 : 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: headerColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: accentColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.upload_file,
                            color: accentColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Submit New Book',
                          style: labelLarge.copyWith(color: textColor),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: secondaryTextColor),
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: closeButtonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Field
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title *',
                          prefixIcon: Icon(Icons.title, color: accentColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: formFieldColor,
                        ),
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter book title'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Author Field
                      TextFormField(
                        controller: _authorController,
                        decoration: InputDecoration(
                          labelText: 'Author *',
                          prefixIcon: Icon(Icons.person, color: accentColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: formFieldColor,
                        ),
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter author name'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Category Dropdown
                      Consumer<CategoryProvider>(
                        builder: (context, categoryProvider, _) {
                          return DropdownButtonFormField<int>(
                            initialValue: _selectedCategoryId,
                            decoration: InputDecoration(
                              labelText: 'Category *',
                              prefixIcon: Icon(
                                Icons.category,
                                color: accentColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: formFieldColor,
                            ),
                            items: categoryProvider.categories
                                .where((cat) => cat['id'] != null)
                                .map((category) {
                                  return DropdownMenuItem<int>(
                                    value: category['id'] as int,
                                    child: Text(
                                      category['name']?.toString() ?? '',
                                    ),
                                  );
                                })
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategoryId = value;
                              });
                            },
                            validator: (value) => value == null
                                ? 'Please select a category'
                                : null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // File Type and Pages Row
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedFileType,
                              decoration: InputDecoration(
                                labelText: 'File Type *',
                                prefixIcon: Icon(
                                  Icons.description,
                                  color: accentColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: formFieldColor,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'pdf',
                                  child: Text('PDF'),
                                ),
                                DropdownMenuItem(
                                  value: 'epub',
                                  child: Text('EPUB'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedFileType = value ?? 'pdf';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _pagesController,
                              decoration: InputDecoration(
                                labelText: 'Pages *',
                                prefixIcon: Icon(
                                  Icons.menu_book,
                                  color: accentColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: formFieldColor,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final pages = int.tryParse(value);
                                if (pages == null || pages <= 0) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Book File Picker
                      InkWell(
                        onTap: _isSubmitting ? null : _pickBookFile,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: formFieldColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _bookFile != null
                                  ? greenColor
                                  : accentColor.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _bookFile != null
                                    ? Icons.check_circle
                                    : Icons.upload_file,
                                color: _bookFile != null
                                    ? greenColor
                                    : accentColor,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _bookFile != null
                                          ? 'Book File Selected'
                                          : 'Select Book File *',
                                      style: bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: _bookFile != null
                                            ? greenColor
                                            : textColor,
                                      ),
                                    ),
                                    if (_bookFile != null)
                                      Text(
                                        _bookFile!.path.split('/').last,
                                        style: bodySmall.copyWith(
                                          color: secondaryTextColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    else
                                      Text(
                                        'PDF or EPUB file (max 50MB)',
                                        style: bodySmall.copyWith(
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Cover Image Picker
                      InkWell(
                        onTap: _isSubmitting ? null : _pickCoverImage,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: formFieldColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _coverImage != null
                                  ? greenColor
                                  : accentColor.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _coverImage != null
                                    ? Icons.check_circle
                                    : Icons.image,
                                color: _coverImage != null
                                    ? greenColor
                                    : accentColor,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _coverImage != null
                                          ? 'Cover Image Selected'
                                          : 'Select Cover Image (Optional)',
                                      style: bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: _coverImage != null
                                            ? greenColor
                                            : textColor,
                                      ),
                                    ),
                                    if (_coverImage != null)
                                      Text(
                                        _coverImage!.path.split('/').last,
                                        style: bodySmall.copyWith(
                                          color: secondaryTextColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    else
                                      Text(
                                        'JPG, PNG (recommended: 800x800)',
                                        style: bodySmall.copyWith(
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description Field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description *',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(bottom: 60),
                            child: Icon(Icons.description, color: accentColor),
                          ),
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: formFieldColor,
                        ),
                        maxLines: 4,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter book description'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),

              // Footer with Buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: formFieldColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: accentColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        side: BorderSide(color: secondaryTextColor as Color),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: bodyMedium.copyWith(
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitBook,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.upload, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Submit Book',
                                  style: labelSmall.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
