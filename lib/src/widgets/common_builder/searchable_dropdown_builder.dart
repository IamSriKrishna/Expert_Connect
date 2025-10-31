import 'package:expert_connect/src/extension/string_extensions.dart';
import 'package:expert_connect/src/widgets/common_builder/drop_down_builder.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchableDropdownField<T> extends StatefulWidget {
  final String name;
  final String? errorText;
  final List<ValidationType> validationTypes;
  final String? Function(T?)? customValidator;
  final void Function(T?)? onChanged;
  final List<SearchableDropdownOption<T>> items;
  final T? initialValue;
  final String? hintText;
  final bool enabled;
  final Widget? prefixIcon;
  final String? emptyMessage;
  final bool showClearButton;
  
  const SearchableDropdownField({
    super.key,
    required this.name,
    required this.items,
    this.errorText,
    this.onChanged,
    this.validationTypes = const [],
    this.customValidator,
    this.initialValue,
    this.hintText,
    this.enabled = true,
    this.prefixIcon,
    this.emptyMessage,
    this.showClearButton = true,
  });

  @override
  State<SearchableDropdownField<T>> createState() => _SearchableDropdownFieldState<T>();
}

class _SearchableDropdownFieldState<T> extends State<SearchableDropdownField<T>> 
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  
  bool _isExpanded = false;
  List<SearchableDropdownOption<T>> _filteredItems = [];
  SearchableDropdownOption<T>? _selectedItem;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  
  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(widget.items); // Create a copy to avoid reference issues
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // Set initial selected item
    if (widget.initialValue != null) {
      try {
        _selectedItem = widget.items.firstWhere(
          (item) => item.value == widget.initialValue,
        );
        _searchController.text = _selectedItem?.label ?? '';
      } catch (e) {
        // Handle case where initialValue doesn't match any item
        _selectedItem = null;
      }
    }
    
    _focusNode.addListener(_onFocusChange);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }
  
  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      // Add a small delay to allow for item selection
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!_focusNode.hasFocus) {
          _hideOverlay();
        }
      });
    }
  }
  
  void _showOverlay() {
    if (_overlayEntry != null) return;
    
    // Reset filtered items when showing overlay
    _filteredItems = List.from(widget.items);
    
    _overlayEntry = OverlayEntry(
      builder: (context) => _buildOverlay(),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isExpanded = true;
    });
    _animationController.forward();
  }
  
  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isExpanded = false;
      });
      _animationController.reverse();
    }
  }
  
  void _onSearchChanged(String query) {
    print('Search query: $query'); // Debug print
    
    if (!mounted) return;
    
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(widget.items);
      } else {
        _filteredItems = widget.items
            .where((item) => item.label.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
    
    // Update overlay if it's showing
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
    
    print('Filtered items count: ${_filteredItems.length}'); // Debug print
  }
  
  void _selectItem(SearchableDropdownOption<T> item) {
    setState(() {
      _selectedItem = item;
      _searchController.text = item.label;
    });
    widget.onChanged?.call(item.value);
    _focusNode.unfocus();
  }
  
  void _clearSelection() {
    setState(() {
      _selectedItem = null;
      _searchController.clear();
      _filteredItems = List.from(widget.items); // Reset filter when clearing
    });
    widget.onChanged?.call(null);
    
    // Update overlay if it's showing
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }
  
  Widget _buildOverlay() {
    return Positioned(
      width: MediaQuery.of(context).size.width - 40.w,
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: Offset(0, 60.h),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            constraints: BoxConstraints(maxHeight: 200.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _expandAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.95 + (0.05 * _expandAnimation.value),
                  child: Opacity(
                    opacity: _expandAnimation.value,
                    child: _buildDropdownList(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDropdownList() {
    if (_filteredItems.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.w),
        child: Text(
          widget.emptyMessage ?? 'No items found',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      shrinkWrap: true,
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        final isSelected = _selectedItem?.value == item.value;
        
        return InkWell(
          onTap: () => _selectItem(item),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade50 : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                if (item.icon != null) ...[
                  item.icon!,
                  SizedBox(width: 12.w),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isSelected ? Colors.blue.shade700 : Colors.black87,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (item.subtitle != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          item.subtitle!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Colors.blue.shade600,
                    size: 18.sp,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.0.h),
          child: CommonWidgets.text(
            text: widget.name.capitalize(),
            color: Colors.black87,
            fontFamily: TextFamily.manrope,
            fontWeight: TextWeight.bold,
            fontSize: 14.sp,
          ),
        ),
        CompositedTransformTarget(
          link: _layerLink,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: _isExpanded ? Colors.blue.shade400 : Colors.grey.shade300,
                width: _isExpanded ? 2 : 1,
              ),
              boxShadow: _isExpanded
                  ? [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              controller: _searchController,
              focusNode: _focusNode,
              enabled: widget.enabled,
              onChanged: _onSearchChanged,
              validator: _buildValidator(),
              onTap: () {
                // Clear the text when tapping to start fresh search
                if (_selectedItem != null) {
                  _searchController.clear();
                  _onSearchChanged('');
                }
              },
              decoration: InputDecoration(
                hintText: widget.hintText ?? "Search ${widget.name.toLowerCase()}".capitalize(),
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14.sp,
                ),
                prefixIcon: widget.prefixIcon ?? Icon(
                  Icons.search,
                  color: _isExpanded ? Colors.blue.shade400 : Colors.grey.shade400,
                  size: 20.sp,
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.showClearButton && (_selectedItem != null || _searchController.text.isNotEmpty))
                      GestureDetector(
                        onTap: _clearSelection,
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          child: Icon(
                            Icons.clear,
                            color: Colors.grey.shade400,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: _isExpanded ? Colors.blue.shade400 : Colors.grey.shade400,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                errorText: widget.errorText,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  String? Function(String?)? _buildValidator() {
    if (widget.validationTypes.isEmpty && widget.customValidator == null) {
      return null;
    }

    List<String? Function(String?)> validators = [];

    for (ValidationType type in widget.validationTypes) {
      switch (type) {
        case ValidationType.required:
          validators.add((value) {
            if (value == null || value.isEmpty || _selectedItem == null) {
              return 'This field is required';
            }
            return null;
          });
          break;
        default:
          break;
      }
    }

    if (widget.customValidator != null) {
      validators.add((value) => widget.customValidator!(_selectedItem?.value));
    }

    return validators.isEmpty
        ? null
        : (String? value) {
            for (var validator in validators) {
              final result = validator(value);
              if (result != null) return result;
            }
            return null;
          };
  }
}

class SearchableDropdownOption<T> {
  final T value;
  final String label;
  final Widget? icon;
  final String? subtitle;

  const SearchableDropdownOption({
    required this.value,
    required this.label,
    this.icon,
    this.subtitle,
  });
}

extension SearchableDropdownOptionsExtension<T> on List<SearchableDropdownOption<T>> {
  List<SearchableDropdownOption<T>> toSearchableDropdownOptions() {
    return this;
  }
}