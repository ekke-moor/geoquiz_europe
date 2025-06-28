import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilteringToolbarWidget extends StatefulWidget {
  final Function(List<String>) onFiltersChanged;
  final List<String> selectedFilters;
  final Function(String) onBulkAction;
  final int selectedItemsCount;

  const FilteringToolbarWidget({
    super.key,
    required this.onFiltersChanged,
    required this.selectedFilters,
    required this.onBulkAction,
    required this.selectedItemsCount,
  });

  @override
  State<FilteringToolbarWidget> createState() => _FilteringToolbarWidgetState();
}

class _FilteringToolbarWidgetState extends State<FilteringToolbarWidget> {
  String selectedRegion = 'All Regions';
  String selectedPeriod = 'All Periods';
  String selectedDifficulty = 'All Levels';
  String selectedStatus = 'All Status';
  String selectedPreset = 'Default';

  final List<String> regions = [
    'All Regions',
    'Western Europe',
    'Eastern Europe',
    'Northern Europe',
    'Southern Europe',
    'British Isles'
  ];

  final List<String> periods = [
    'All Periods',
    '1900-1920',
    '1920-1940',
    '1940-1960',
    '1960-1980',
    '1980-2000'
  ];

  final List<String> difficulties = [
    'All Levels',
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert'
  ];

  final List<String> statuses = [
    'All Status',
    'Draft',
    'Review',
    'Published',
    'Archived'
  ];

  final List<String> presets = [
    'Default',
    'Recent Content',
    'High Usage',
    'Pending Review',
    'Published Only'
  ];

  final List<String> bulkActions = [
    'Approve Selected',
    'Publish Selected',
    'Archive Selected',
    'Export Selected',
    'Duplicate Selected'
  ];

  void _applyFilters() {
    List<String> filters = [];
    if (selectedRegion != 'All Regions') filters.add(selectedRegion);
    if (selectedPeriod != 'All Periods') filters.add(selectedPeriod);
    if (selectedDifficulty != 'All Levels') filters.add(selectedDifficulty);
    if (selectedStatus != 'All Status') filters.add(selectedStatus);

    widget.onFiltersChanged(filters);
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required String hint,
  }) {
    return Container(
      width: 18.w,
      height: 5.h,
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: AppTheme.lightTheme.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Filter Controls Row
          Row(
            children: [
              // Region Filter
              _buildDropdown(
                value: selectedRegion,
                items: regions,
                onChanged: (value) {
                  setState(() {
                    selectedRegion = value ?? 'All Regions';
                  });
                  _applyFilters();
                },
                hint: 'Region',
              ),
              SizedBox(width: 1.w),

              // Period Filter
              _buildDropdown(
                value: selectedPeriod,
                items: periods,
                onChanged: (value) {
                  setState(() {
                    selectedPeriod = value ?? 'All Periods';
                  });
                  _applyFilters();
                },
                hint: 'Period',
              ),
              SizedBox(width: 1.w),

              // Difficulty Filter
              _buildDropdown(
                value: selectedDifficulty,
                items: difficulties,
                onChanged: (value) {
                  setState(() {
                    selectedDifficulty = value ?? 'All Levels';
                  });
                  _applyFilters();
                },
                hint: 'Difficulty',
              ),
              SizedBox(width: 1.w),

              // Status Filter
              _buildDropdown(
                value: selectedStatus,
                items: statuses,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value ?? 'All Status';
                  });
                  _applyFilters();
                },
                hint: 'Status',
              ),
              SizedBox(width: 1.w),

              // Preset Filter
              _buildDropdown(
                value: selectedPreset,
                items: presets,
                onChanged: (value) {
                  setState(() {
                    selectedPreset = value ?? 'Default';
                  });
                  _applyFilters();
                },
                hint: 'Preset',
              ),

              const Spacer(),

              // Search Field
              SizedBox(
                width: 25.w,
                height: 5.h,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search content...',
                    prefixIcon: CustomIconWidget(
                      iconName: 'search',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 2.w),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.dividerColor,
                      ),
                    ),
                  ),
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          // Bulk Actions Row
          Row(
            children: [
              // Selected Items Count
              widget.selectedItemsCount > 0
                  ? Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.selectedItemsCount} items selected',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),

              SizedBox(width: 2.w),

              // Bulk Action Buttons
              if (widget.selectedItemsCount > 0) ...[
                ...bulkActions
                    .map((action) => Padding(
                          padding: EdgeInsets.only(right: 1.w),
                          child: ElevatedButton.icon(
                            onPressed: () => widget.onBulkAction(action),
                            icon: CustomIconWidget(
                              iconName: _getBulkActionIcon(action),
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                              size: 16,
                            ),
                            label: Text(
                              action,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.lightTheme.primaryColor,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 1.h),
                            ),
                          ),
                        ))
                    ,
              ],

              const Spacer(),

              // Clear Filters Button
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    selectedRegion = 'All Regions';
                    selectedPeriod = 'All Periods';
                    selectedDifficulty = 'All Levels';
                    selectedStatus = 'All Status';
                    selectedPreset = 'Default';
                  });
                  widget.onFiltersChanged([]);
                },
                icon: CustomIconWidget(
                  iconName: 'clear',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
                label: Text(
                  'Clear Filters',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getBulkActionIcon(String action) {
    switch (action) {
      case 'Approve Selected':
        return 'check_circle';
      case 'Publish Selected':
        return 'publish';
      case 'Archive Selected':
        return 'archive';
      case 'Export Selected':
        return 'download';
      case 'Duplicate Selected':
        return 'content_copy';
      default:
        return 'more_horiz';
    }
  }
}
