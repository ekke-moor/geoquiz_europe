import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ContentNavigationTreeWidget extends StatefulWidget {
  final List<Map<String, dynamic>> navigationData;
  final Function(String) onNodeSelected;

  const ContentNavigationTreeWidget({
    super.key,
    required this.navigationData,
    required this.onNodeSelected,
  });

  @override
  State<ContentNavigationTreeWidget> createState() =>
      _ContentNavigationTreeWidgetState();
}

class _ContentNavigationTreeWidgetState
    extends State<ContentNavigationTreeWidget> {
  Set<String> expandedNodes = {};
  String selectedNode = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'folder_open',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 20,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Content Library',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Divider(
            color: AppTheme.lightTheme.dividerColor,
            thickness: 1,
          ),

          SizedBox(height: 1.h),

          // Navigation Tree
          Expanded(
            child: ListView.builder(
              itemCount: widget.navigationData.length,
              itemBuilder: (context, index) {
                final item = widget.navigationData[index];
                return _buildTreeNode(item, 0);
              },
            ),
          ),

          // Statistics Summary
          Container(
            margin: EdgeInsets.only(top: 2.h),
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Library Statistics',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                _buildStatRow('Total Content', '145'),
                _buildStatRow('Published', '98'),
                _buildStatRow('In Review', '23'),
                _buildStatRow('Draft', '24'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeNode(Map<String, dynamic> node, int level) {
    final String title = node['title'] as String;
    final int count = node['count'] as int;
    final List<dynamic>? children = node['children'] as List<dynamic>?;
    final bool hasChildren = children != null && children.isNotEmpty;
    final bool isExpanded = expandedNodes.contains(title);
    final bool isSelected = selectedNode == title;

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (hasChildren) {
                if (isExpanded) {
                  expandedNodes.remove(title);
                } else {
                  expandedNodes.add(title);
                }
              }
              selectedNode = title;
            });
            widget.onNodeSelected(title);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: (level * 2.0 + 1).w,
              vertical: 1.h,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                // Expand/Collapse Icon
                hasChildren
                    ? CustomIconWidget(
                        iconName: isExpanded ? 'expand_less' : 'expand_more',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 16,
                      )
                    : SizedBox(width: 16),

                SizedBox(width: 1.w),

                // Folder/File Icon
                CustomIconWidget(
                  iconName: hasChildren ? 'folder' : 'description',
                  color: hasChildren
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),

                SizedBox(width: 1.w),

                // Title
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Count Badge
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Children
        if (hasChildren && isExpanded) ...[
          ...children
              .map((child) => _buildTreeNode(
                    child as Map<String, dynamic>,
                    level + 1,
                  ))
              ,
        ],
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall,
          ),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
