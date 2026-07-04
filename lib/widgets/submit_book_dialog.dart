import 'dart:io';
import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/helpers/ui_utils.dart';
import 'package:book_reader_app/providers/book_provider.dart';
import 'package:book_reader_app/providers/category_provider.dart';
import 'package:book_reader_app/theme/app_colors.dart';
import 'package:book_reader_app/widgets/common/app_button.dart';
import 'package:book_reader_app/widgets/common/app_card.dart';
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
  String? _submittedBookTitle; // Store title for success dialog

  final ImagePicker _imagePicker = ImagePicker();

  // Max file sizes in bytes
  static const int maxBookFileSize = 50 * 1024 * 1024; // 50MB
  static const int maxCoverImageSize = 2 * 1024 * 1024; // 2MB

  @override
  void initState() {
    super.initState();
    // Ensure categories are loaded when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider = Provider.of<CategoryProvider>(
        context,
        listen: false,
      );
      if (categoryProvider.categories.length <= 1) {
        // Only "All" category exists, load categories
        categoryProvider.loadCategories();
      }
    });
  }

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
            // Check file size
            final fileSize = await file.length();
            if (fileSize > maxBookFileSize) {
              if (mounted) {
                UiUtils.showErrorSnackBar(
                  context,
                  'File size exceeds 50MB limit. Please select a smaller file.',
                );
              }
              return;
            }

            // Auto-detect file type from extension
            final extension =
                pickedFile.extension?.toLowerCase() ??
                pickedFile.path!.split('.').last.toLowerCase();

            // Validate file extension
            if (!allowedBookExtensions.contains(extension)) {
              if (mounted) {
                UiUtils.showErrorSnackBar(
                  context,
                  'Invalid file type. Please select a PDF or EPUB file.',
                );
              }
              return;
            }

            setState(() {
              _bookFile = file;
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

            // Check file size
            final fileSize = pickedFile.bytes!.length;
            if (fileSize > maxBookFileSize) {
              if (mounted) {
                UiUtils.showErrorSnackBar(
                  context,
                  'File size exceeds 50MB limit. Please select a smaller file.',
                );
              }
              return;
            }

            // Validate file extension
            if (!allowedBookExtensions.contains(extension)) {
              if (mounted) {
                UiUtils.showErrorSnackBar(
                  context,
                  'Invalid file type. Please select a PDF or EPUB file.',
                );
              }
              return;
            }

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
        final file = File(pickedFile.path);

        // Check file size
        final fileSize = await file.length();
        if (fileSize > maxCoverImageSize) {
          if (mounted) {
            UiUtils.showErrorSnackBar(
              context,
              'Image size exceeds 2MB limit. Please select a smaller image.',
            );
          }
          return;
        }

        setState(() {
          _coverImage = file;
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

    // Validate file type matches selected type
    final fileExtension = _bookFile!.path.split('.').last.toLowerCase();
    if ((_selectedFileType == 'pdf' && fileExtension != 'pdf') ||
        (_selectedFileType == 'epub' && fileExtension != 'epub')) {
      UiUtils.showErrorSnackBar(
        context,
        'Selected file type does not match the file extension. Please select the correct file type.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);

      // Store title before submission for success dialog
      final bookTitle = _titleController.text.trim();

      final result = await bookProvider.submitBook(
        title: bookTitle,
        author: _authorController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategoryId!,
        fileType: _selectedFileType,
        numberOfPages: int.parse(_pagesController.text.trim()),
        bookFile: _bookFile,
        coverImage: _coverImage,
      );

      if (mounted) {
        if (result != null) {
          // Store title for success dialog
          _submittedBookTitle = bookTitle;

          // Reset form
          _resetForm();

          // Close dialog
          Navigator.pop(context);

          // Show success dialog with admin approval message
          _showSuccessDialog();
        } else {
          setState(() {
            _isSubmitting = false;
          });

          final errorMessage =
              bookProvider.errorMessage ?? 'Failed to submit book';
          UiUtils.showErrorSnackBar(context, errorMessage);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        String errorMessage = 'An error occurred while submitting the book.';
        if (e.toString().contains('timeout')) {
          errorMessage =
              'Request timed out. Please check your internet connection and try again.';
        } else if (e.toString().contains('network')) {
          errorMessage =
              'Network error. Please check your internet connection.';
        } else if (e.toString().contains('401') ||
            e.toString().contains('unauthorized')) {
          errorMessage =
              'You are not authorized to submit books. Please log in again.';
        } else if (e.toString().contains('422') ||
            e.toString().contains('validation')) {
          errorMessage =
              'Validation error. Please check all fields and try again.';
        }

        UiUtils.showErrorSnackBar(context, errorMessage);
      }
    }
  }

  void _resetForm() {
    _titleController.clear();
    _authorController.clear();
    _descriptionController.clear();
    _pagesController.clear();
    _bookFile = null;
    _coverImage = null;
    _selectedCategoryId = null;
    _selectedFileType = 'pdf';
    _formKey.currentState?.reset();
  }

  void _showSuccessDialog() {
    final colors = AppColors.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusXLarge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(spacingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: colors.success,
                  size: 50,
                ),
              ),
              const SizedBox(height: spacingLarge),

              // Title
              Text(
                'Book Submitted Successfully!',
                style: displaySmall.copyWith(color: colors.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: spacingMedium),

              // Message
              Text(
                _submittedBookTitle != null
                    ? 'Your book "$_submittedBookTitle" has been submitted for review.'
                    : 'Your book has been submitted for review.',
                style: bodyMedium.copyWith(color: colors.secondaryText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: spacingSmall),

              // Admin Approval Info
              Container(
                padding: const EdgeInsets.all(spacingMedium),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(borderRadiusMedium),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: colors.primary, size: 24),
                    const SizedBox(width: spacingMedium),
                    Expanded(
                      child: Text(
                        'Your book is pending admin approval. You will be notified once it\'s approved and published.',
                        style: bodySmall.copyWith(
                          color: colors.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: spacingLarge),

              // OK Button
              PrimaryButton(
                label: 'Got it',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shared decoration for the dialog's form fields, so the fill/border/radius
  /// aren't re-specified on every input.
  InputDecoration _fieldDecoration(
    AppColors colors, {
    required String label,
    required IconData icon,
    Widget? suffixIcon,
    bool alignLabelWithHint = false,
    EdgeInsetsGeometry? prefixPadding,
  }) {
    final prefix = Icon(icon, color: colors.primary);
    return InputDecoration(
      labelText: label,
      labelStyle: bodyMedium.copyWith(color: colors.secondaryText),
      prefixIcon: prefixPadding != null
          ? Padding(padding: prefixPadding, child: prefix)
          : prefix,
      alignLabelWithHint: alignLabelWithHint,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: colors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(color: colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: spacingMedium,
        vertical: spacingLarge,
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(borderRadiusXLarge),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
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
                padding: const EdgeInsets.all(spacingLarge),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.06),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(borderRadiusXLarge),
                    topRight: Radius.circular(borderRadiusXLarge),
                  ),
                  border: Border(bottom: BorderSide(color: colors.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const IconTile(icon: Icons.upload_file),
                        const SizedBox(width: spacingMedium),
                        Text(
                          'Submit New Book',
                          style: labelLarge.copyWith(color: colors.onSurface),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: colors.secondaryText),
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: colors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            borderRadiusSmall,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(spacingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Field
                      TextFormField(
                        controller: _titleController,
                        style: bodyMedium.copyWith(color: colors.onSurface),
                        decoration: _fieldDecoration(
                          colors,
                          label: 'Title *',
                          icon: Icons.title,
                        ),
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter book title'
                            : null,
                      ),
                      const SizedBox(height: spacingMedium),

                      // Author Field
                      TextFormField(
                        controller: _authorController,
                        style: bodyMedium.copyWith(color: colors.onSurface),
                        decoration: _fieldDecoration(
                          colors,
                          label: 'Author *',
                          icon: Icons.person,
                        ),
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter author name'
                            : null,
                      ),
                      const SizedBox(height: spacingMedium),

                      // Category Dropdown
                      Consumer<CategoryProvider>(
                        builder: (context, categoryProvider, _) {
                          // Filter out "All" category (id is null) and get only valid categories
                          final validCategories = categoryProvider.categories
                              .where((cat) => cat['id'] != null)
                              .toList();

                          if (categoryProvider.busy) {
                            return DropdownButtonFormField<int>(
                              decoration: _fieldDecoration(
                                colors,
                                label: 'Category *',
                                icon: Icons.category,
                                suffixIcon: const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                              items: const [],
                              onChanged: null,
                              validator: (value) => 'Loading categories...',
                            );
                          }

                          if (validCategories.isEmpty) {
                            return DropdownButtonFormField<int>(
                              decoration: _fieldDecoration(
                                colors,
                                label: 'Category *',
                                icon: Icons.category,
                              ),
                              items: const [],
                              onChanged: null,
                              validator: (value) => 'No categories available',
                            );
                          }

                          return DropdownButtonFormField<int>(
                            initialValue: _selectedCategoryId,
                            decoration: _fieldDecoration(
                              colors,
                              label: 'Category *',
                              icon: Icons.category,
                            ),
                            items: validCategories.map((category) {
                              return DropdownMenuItem<int>(
                                value: category['id'] as int,
                                child: Text(category['name']?.toString() ?? ''),
                              );
                            }).toList(),
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
                      const SizedBox(height: spacingMedium),

                      // File Type and Pages Row
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedFileType,
                              isExpanded: true,
                              decoration: _fieldDecoration(
                                colors,
                                label: 'File Type *',
                                icon: Icons.description,
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
                          const SizedBox(width: spacingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _pagesController,
                              style: bodyMedium.copyWith(
                                color: colors.onSurface,
                              ),
                              decoration: _fieldDecoration(
                                colors,
                                label: 'Pages *',
                                icon: Icons.menu_book,
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
                      const SizedBox(height: spacingMedium),

                      // Book File Picker
                      _buildFilePicker(
                        colors: colors,
                        selected: _bookFile != null,
                        onTap: _isSubmitting ? null : _pickBookFile,
                        selectedIcon: Icons.check_circle,
                        idleIcon: Icons.upload_file,
                        selectedLabel: 'Book File Selected',
                        idleLabel: 'Select Book File *',
                        selectedSubtitle: _bookFile?.path.split('/').last,
                        idleSubtitle: 'PDF or EPUB file (max 50MB)',
                      ),
                      const SizedBox(height: spacingMedium),

                      // Cover Image Picker
                      _buildFilePicker(
                        colors: colors,
                        selected: _coverImage != null,
                        onTap: _isSubmitting ? null : _pickCoverImage,
                        selectedIcon: Icons.check_circle,
                        idleIcon: Icons.image,
                        selectedLabel: 'Cover Image Selected',
                        idleLabel: 'Select Cover Image (Optional)',
                        selectedSubtitle: _coverImage?.path.split('/').last,
                        idleSubtitle: 'JPG, PNG (recommended: 800x800)',
                      ),
                      const SizedBox(height: spacingMedium),

                      // Description Field
                      TextFormField(
                        controller: _descriptionController,
                        style: bodyMedium.copyWith(color: colors.onSurface),
                        decoration: _fieldDecoration(
                          colors,
                          label: 'Description *',
                          icon: Icons.description,
                          alignLabelWithHint: true,
                          prefixPadding: const EdgeInsets.only(bottom: 60),
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
                padding: const EdgeInsets.all(spacingLarge),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(borderRadiusXLarge),
                    bottomRight: Radius.circular(borderRadiusXLarge),
                  ),
                  border: Border(top: BorderSide(color: colors.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SecondaryButton(
                      label: 'Cancel',
                      expand: false,
                      color: colors.secondaryText,
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context),
                    ),
                    const SizedBox(width: spacingMedium),
                    PrimaryButton(
                      label: 'Submit Book',
                      icon: Icons.upload,
                      expand: false,
                      busy: _isSubmitting,
                      onPressed: _submitBook,
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

  /// File/cover selector row — a tappable bordered tile whose accent turns to
  /// [AppColors.success] once a file has been picked.
  Widget _buildFilePicker({
    required AppColors colors,
    required bool selected,
    required VoidCallback? onTap,
    required IconData selectedIcon,
    required IconData idleIcon,
    required String selectedLabel,
    required String idleLabel,
    required String? selectedSubtitle,
    required String idleSubtitle,
  }) {
    final accent = selected ? colors.success : colors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadiusMedium),
      child: Container(
        padding: const EdgeInsets.all(spacingMedium),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          border: Border.all(
            color: selected ? colors.success : colors.border,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(selected ? selectedIcon : idleIcon, color: accent),
            const SizedBox(width: spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selected ? selectedLabel : idleLabel,
                    style: bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: selected ? colors.success : colors.onSurface,
                    ),
                  ),
                  Text(
                    selected ? (selectedSubtitle ?? '') : idleSubtitle,
                    style: bodySmall.copyWith(color: colors.secondaryText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.secondaryText),
          ],
        ),
      ),
    );
  }
}
