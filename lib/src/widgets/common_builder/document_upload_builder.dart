import 'dart:io';
import 'package:expert_connect/src/extension/string_extensions.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';

class DocumentUploadBuilder extends StatefulWidget {
  final String name;
  final List<String> initialDocumentPaths;
  final String? errorText;
  final List<String> allowedExtensions;
  final int? maxFiles;
  final double? maxFileSizeInMB;
  final bool isRequired;
  final void Function(List<String>)? onChanged;
  final String? Function(List<String>?)? customValidator;

  const DocumentUploadBuilder({
    super.key,
    required this.name,
    this.initialDocumentPaths = const [],
    this.errorText,
    this.allowedExtensions = const ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    this.maxFiles,
    this.maxFileSizeInMB = 10.0,
    this.isRequired = false,
    this.onChanged,
    this.customValidator,
  });

  @override
  State<DocumentUploadBuilder> createState() => _DocumentUploadBuilderState();
}

class _DocumentUploadBuilderState extends State<DocumentUploadBuilder> {
  List<String> _selectedDocumentPaths = [];
  String? _validationError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDocumentPaths = List.from(widget.initialDocumentPaths);
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<List<String>>(
      name: widget.name,
      initialValue: _selectedDocumentPaths,
      validator: _buildValidator(),
      builder: (FormFieldState<List<String>> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 5.0.h),
              child: CommonWidgets.text(
                text: widget.name.capitalize(),
                color: Colors.black,
                fontFamily: TextFamily.manrope,
                fontWeight: TextWeight.bold,
                fontSize: 14.sp,
              ),
            ),

            // Upload Button
            GestureDetector(
              onTap: _isLoading ? null : () => _pickDocuments(field),
              child: Container(
                width: double.infinity,
                height: 60.h,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: field.hasError ? Colors.red : Colors.grey,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8.sp),
                  color: _isLoading ? Colors.grey[100] : null,
                ),
                child: _isLoading
                    ? Center(
                        child: SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            color: Colors.grey[600],
                            size: 24.sp,
                          ),
                          SizedBox(width: 8.w),
                          CommonWidgets.text(
                            text: "Upload ${widget.name.toLowerCase()}",
                            color: Colors.grey[600]!,
                            fontFamily: TextFamily.manrope,
                            fontWeight: TextWeight.medium,
                            fontSize: 14.sp,
                          ),
                        ],
                      ),
              ),
            ),

            // Error Text
            if (field.hasError || widget.errorText != null)
              Padding(
                padding: EdgeInsets.only(top: 5.h),
                child: CommonWidgets.text(
                  text: field.errorText ?? widget.errorText ?? '',
                  color: Colors.red,
                  fontFamily: TextFamily.manrope,
                  fontWeight: TextWeight.regular,
                  fontSize: 12.sp,
                ),
              ),

            // Validation Error
            if (_validationError != null)
              Padding(
                padding: EdgeInsets.only(top: 5.h),
                child: CommonWidgets.text(
                  text: _validationError!,
                  color: Colors.red,
                  fontFamily: TextFamily.manrope,
                  fontWeight: TextWeight.regular,
                  fontSize: 12.sp,
                ),
              ),

            // Uploaded Documents List
            if (_selectedDocumentPaths.isNotEmpty) ...[
              SizedBox(height: 10.h),
              CommonWidgets.text(
                text: "Uploaded Documents:",
                color: Colors.black87,
                fontFamily: TextFamily.manrope,
                fontWeight: TextWeight.medium,
                fontSize: 13.sp,
              ),
              SizedBox(height: 5.h),
              ...List.generate(
                _selectedDocumentPaths.length,
                (index) => _buildDocumentTile(
                  _selectedDocumentPaths[index],
                  index,
                  field,
                ),
              ),
            ],

            // Upload Info
            SizedBox(height: 5.h),
            CommonWidgets.text(
              text: _getUploadInfo(),
              color: Colors.grey[600]!,
              fontFamily: TextFamily.manrope,
              fontWeight: TextWeight.regular,
              fontSize: 11.sp,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDocumentTile(
    String documentPath,
    int index,
    FormFieldState<List<String>> field,
  ) {
    String fileName = documentPath.split('/').last;
    String fileSize = _getFileSize(documentPath);
    IconData fileIcon = _getFileIcon(fileName);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(6.sp),
      ),
      child: Row(
        children: [
          Icon(fileIcon, color: _getFileIconColor(fileName), size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonWidgets.text(
                  text: fileName,
                  color: Colors.black87,
                  fontFamily: TextFamily.manrope,
                  fontWeight: TextWeight.medium,
                  fontSize: 13.sp,
                ),
                CommonWidgets.text(
                  text: fileSize,
                  color: Colors.grey[600]!,
                  fontFamily: TextFamily.manrope,
                  fontWeight: TextWeight.regular,
                  fontSize: 11.sp,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _removeDocument(index, field),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(4.sp),
              ),
              child: Icon(Icons.close, color: Colors.red, size: 16.sp),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDocuments(FormFieldState<List<String>> field) async {
    if (_isLoading) return;

    setState(() {
      _validationError = null;
      _isLoading = true;
    });

    try {
      FilePickerResult? result;

      if (widget.allowedExtensions.isNotEmpty) {
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: widget.allowedExtensions,
          allowMultiple: widget.maxFiles == null || widget.maxFiles! > 1,
          withData: false, 
          withReadStream: false,
        );
      } else {
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: widget.maxFiles == null || widget.maxFiles! > 1,
          withData: false,
          withReadStream: false,
        );
      }

      if (result != null && result.files.isNotEmpty) {
        List<String> newFilePaths = [];

        for (PlatformFile file in result.files) {
          if (file.path != null) {
            newFilePaths.add(file.path!);
          }
        }

        if (newFilePaths.isEmpty) {
          setState(() {
            _validationError = "No valid files selected";
            _isLoading = false;
          });
          return;
        }

        String? validationError = _validateFiles(newFilePaths);
        if (validationError != null) {
          setState(() {
            _validationError = validationError;
            _isLoading = false;
          });
          return;
        }

        setState(() {
          if (widget.maxFiles == 1) {
            _selectedDocumentPaths = newFilePaths;
          } else {
            _selectedDocumentPaths.addAll(newFilePaths);
            if (widget.maxFiles != null &&
                _selectedDocumentPaths.length > widget.maxFiles!) {
              _selectedDocumentPaths = _selectedDocumentPaths
                  .take(widget.maxFiles!)
                  .toList();
            }
          }
          _isLoading = false;
        });

        field.didChange(_selectedDocumentPaths);
        widget.onChanged?.call(_selectedDocumentPaths);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _validationError = "Permission denied or file picker unavailable";
        _isLoading = false;
      });
      debugPrint("PlatformException: ${e.toString()}");
    } catch (e) {
      setState(() {
        _validationError = "Error selecting files. Please try again.";
        _isLoading = false;
      });
      debugPrint("FilePicker Error: ${e.toString()}");
    }
  }

  void _removeDocument(int index, FormFieldState<List<String>> field) {
    setState(() {
      _selectedDocumentPaths.removeAt(index);
      _validationError = null;
    });
    field.didChange(_selectedDocumentPaths);
    widget.onChanged?.call(_selectedDocumentPaths);
  }

  String? _validateFiles(List<String> filePaths) {
    for (String path in filePaths) {
      try {
        File file = File(path);

        if (!file.existsSync()) {
          return "Selected file does not exist";
        }

        if (widget.maxFileSizeInMB != null) {
          double fileSizeInMB = file.lengthSync() / (1024 * 1024);
          if (fileSizeInMB > widget.maxFileSizeInMB!) {
            return "File size should not exceed ${widget.maxFileSizeInMB} MB";
          }
        }

        String extension = path.split('.').last.toLowerCase();
        if (widget.allowedExtensions.isNotEmpty &&
            !widget.allowedExtensions.contains(extension)) {
          return "File type not allowed. Allowed types: ${widget.allowedExtensions.join(', ')}";
        }
      } catch (e) {
        return "Error validating file: ${path.split('/').last}";
      }
    }

    if (widget.maxFiles != null) {
      int totalFiles = _selectedDocumentPaths.length + filePaths.length;
      if (totalFiles > widget.maxFiles!) {
        return "Maximum ${widget.maxFiles} files allowed";
      }
    }

    return null;
  }

  String? Function(List<String>?)? _buildValidator() {
    List<String? Function(List<String>?)> validators = [];

    if (widget.isRequired) {
      validators.add((filePaths) {
        if (filePaths == null || filePaths.isEmpty) {
          return "Please upload at least one document";
        }
        return null;
      });
    }

    if (widget.customValidator != null) {
      validators.add(widget.customValidator!);
    }

    return validators.isEmpty
        ? null
        : (filePaths) {
            for (var validator in validators) {
              String? error = validator(filePaths);
              if (error != null) return error;
            }
            return null;
          };
  }

  String _getFileSize(String filePath) {
    try {
      File file = File(filePath);
      if (file.existsSync()) {
        int bytes = file.lengthSync();
        if (bytes < 1024) return '$bytes B';
        if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
        return '${(bytes / 1048576).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      Logger().e(e.toString());
    }
    return 'Unknown size';
  }

  IconData _getFileIcon(String fileName) {
    String extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileIconColor(String fileName) {
    String extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.green;
      case 'txt':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getUploadInfo() {
    List<String> info = [];

    if (widget.allowedExtensions.isNotEmpty) {
      info.add("Allowed: ${widget.allowedExtensions.join(', ')}");
    }

    if (widget.maxFileSizeInMB != null) {
      info.add("Max size: ${widget.maxFileSizeInMB} MB");
    }

    if (widget.maxFiles != null) {
      info.add("Max files: ${widget.maxFiles}");
    }

    return info.join(" • ");
  }
}
