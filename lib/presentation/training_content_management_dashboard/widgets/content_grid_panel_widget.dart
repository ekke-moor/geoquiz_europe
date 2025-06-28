import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ContentGridPanelWidget extends StatefulWidget {
  final List<Map<String, dynamic>> contentData;
  final String selectedContentId;
  final Function(String) onContentSelected;
  final Function(List<String>) onBulkSelectionChanged;
  final List<String> selectedFilters;
  final bool isCollaborationMode;

  const ContentGridPanelWidget({
    super.key,
    required this.contentData,
    required this.selectedContentId,
    required this.onContentSelected,
    required this.onBulkSelectionChanged,
    required this.selectedFilters,
    required this.isCollaborationMode,
  });

  @override
  State<ContentGridPanelWidget> createState() => _ContentGridPanelWidgetState();
}

class _ContentGridPanelWidgetState extends State<ContentGridPanelWidget> {
  Set<String> selectedItems = {};
  String sortBy = 'lastModified';
  bool sortAscending = false;

  List<Map<String, dynamic>> get filteredContent {
    List<Map<String, dynamic>> filtered = List.from(widget.contentData);

    // Apply filters
    if (widget.selectedFilters.isNotEmpty) {
      filtered = filtered.where((item) {
        return widget.selectedFilters.any((filter) =>
            item['region'].toString().contains(filter) ||
            item['period'].toString().contains(filter) ||
            item['difficulty'].toString().contains(filter) ||
            item['status'].toString().contains(filter));
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      dynamic aValue = a[sortBy];
      dynamic bValue = b[sortBy];

      if (aValue is String && bValue is String) {
        return sortAscending
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      } else if (aValue is int && bValue is int) {
        return sortAscending
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      }
      return 0;
    });

    return filtered;
  }

  void _toggleSelection(String itemId) {
    setState(() {
      if (selectedItems.contains(itemId)) {
        selectedItems.remove(itemId);
      } else {
        selectedItems.add(itemId);
      }
    });
    widget.onBulkSelectionChanged(selectedItems.toList());
  }

  void _selectAll() {
    setState(() {
      if (selectedItems.length == filteredContent.length) {
        selectedItems.clear();
      } else {
        selectedItems =
            filteredContent.map((item) => item['id'] as String).toSet();
      }
    });
    widget.onBulkSelectionChanged(selectedItems.toList());
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return AppTheme.successColor;
      case 'draft':
        return AppTheme.warningColor;
      case 'review':
        return AppTheme.infoColor;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = filteredContent;

    return Container(
      padding: EdgeInsets.all(1.w),
      child: Column(
        children: [
          // Header with controls
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.dividerColor,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Select All Checkbox
                Checkbox(
                  value: selectedItems.length == content.length &&
                      content.isNotEmpty,
                  tristate: true,
                  onChanged: (_) => _selectAll(),
                ),

                SizedBox(width: 2.w),

                Text(
                  'Content Items (${content.length})',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                // Sort Controls
                Text(
                  'Sort by:',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
                SizedBox(width: 1.w),
                DropdownButton<String>(
                  value: sortBy,
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(value: 'title', child: Text('Title')),
                    DropdownMenuItem(
                        value: 'lastModified', child: Text('Modified')),
                    DropdownMenuItem(value: 'usageCount', child: Text('Usage')),
                    DropdownMenuItem(value: 'status', child: Text('Status')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      sortBy = value ?? 'lastModified';
                    });
                  },
                ),

                IconButton(
                  onPressed: () {
                    setState(() {
                      sortAscending = !sortAscending;
                    });
                  },
                  icon: CustomIconWidget(
                    iconName: sortAscending ? 'arrow_upward' : 'arrow_downward',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 1.h),

          // Content Grid
          Expanded(
            child: content.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'search_off',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 48,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'No content found',
                          style: AppTheme.lightTheme.textTheme.titleMedium,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Try adjusting your filters or search terms',
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: content.length,
                    itemBuilder: (context, index) {
                      final item = content[index];
                      final isSelected = selectedItems.contains(item['id']);
                      final isCurrentlySelected =
                          widget.selectedContentId == item['id'];

                      return Container(
                        margin: EdgeInsets.only(bottom: 1.h),
                        decoration: BoxDecoration(
                          color: isCurrentlySelected
                              ? AppTheme.lightTheme.primaryColor
                                  .withValues(alpha: 0.1)
                              : AppTheme.lightTheme.cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCurrentlySelected
                                ? AppTheme.lightTheme.primaryColor
                                : AppTheme.lightTheme.dividerColor,
                            width: isCurrentlySelected ? 2 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => widget.onContentSelected(item['id']),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: EdgeInsets.all(2.w),
                            child: Row(
                              children: [
                                // Selection Checkbox
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (_) =>
                                      _toggleSelection(item['id']),
                                ),

                                SizedBox(width: 2.w),

                                // Content Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title and Status
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item['title'],
                                              style: AppTheme.lightTheme
                                                  .textTheme.titleSmall
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 1.w,
                                              vertical: 0.5.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(
                                                      item['status'])
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              item['status'],
                                              style: AppTheme.lightTheme
                                                  .textTheme.bodySmall
                                                  ?.copyWith(
                                                color: _getStatusColor(
                                                    item['status']),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 0.5.h),

                                      // Description
                                      Text(
                                        item['description'],
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      SizedBox(height: 1.h),

                                      // Metadata Row
                                      Row(
                                        children: [
                                          CustomIconWidget(
                                            iconName: 'location_on',
                                            color: AppTheme.lightTheme
                                                .colorScheme.onSurfaceVariant,
                                            size: 14,
                                          ),
                                          SizedBox(width: 0.5.w),
                                          Text(
                                            item['region'],
                                            style: AppTheme
                                                .lightTheme.textTheme.bodySmall,
                                          ),

                                          SizedBox(width: 2.w),

                                          CustomIconWidget(
                                            iconName: 'schedule',
                                            color: AppTheme.lightTheme
                                                .colorScheme.onSurfaceVariant,
                                            size: 14,
                                          ),
                                          SizedBox(width: 0.5.w),
                                          Text(
                                            item['period'],
                                            style: AppTheme
                                                .lightTheme.textTheme.bodySmall,
                                          ),

                                          SizedBox(width: 2.w),

                                          CustomIconWidget(
                                            iconName: 'trending_up',
                                            color: AppTheme.lightTheme
                                                .colorScheme.onSurfaceVariant,
                                            size: 14,
                                          ),
                                          SizedBox(width: 0.5.w),
                                          Text(
                                            '${item['usageCount']} uses',
                                            style: AppTheme
                                                .lightTheme.textTheme.bodySmall,
                                          ),

                                          const Spacer(),

                                          // Collaboration indicator
                                          if (widget.isCollaborationMode) ...[
                                            CustomIconWidget(
                                              iconName: 'edit',
                                              color: AppTheme
                                                  .lightTheme.primaryColor,
                                              size: 14,
                                            ),
                                            SizedBox(width: 0.5.w),
                                            Text(
                                              'Editing',
                                              style: AppTheme.lightTheme
                                                  .textTheme.bodySmall
                                                  ?.copyWith(
                                                color: AppTheme
                                                    .lightTheme.primaryColor,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Action Menu
                                PopupMenuButton<String>(
                                  icon: CustomIconWidget(
                                    iconName: 'more_vert',
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                    size: 20,
                                  ),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          CustomIconWidget(
                                            iconName: 'edit',
                                            color: AppTheme.lightTheme
                                                .colorScheme.onSurfaceVariant,
                                            size: 16,
                                          ),
                                          SizedBox(width: 1.w),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'duplicate',
                                      child: Row(
                                        children: [
                                          CustomIconWidget(
                                            iconName: 'content_copy',
                                            color: AppTheme.lightTheme
                                                .colorScheme.onSurfaceVariant,
                                            size: 16,
                                          ),
                                          SizedBox(width: 1.w),
                                          Text('Duplicate'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          CustomIconWidget(
                                            iconName: 'delete',
                                            color: AppTheme
                                                .lightTheme.colorScheme.error,
                                            size: 16,
                                          ),
                                          SizedBox(width: 1.w),
                                          Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: AppTheme
                                                  .lightTheme.colorScheme.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    // Handle menu actions
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Action: \$value for ${item['title']}'),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
