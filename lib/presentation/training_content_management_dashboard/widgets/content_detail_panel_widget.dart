import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ContentDetailPanelWidget extends StatefulWidget {
  final String selectedContentId;
  final List<Map<String, dynamic>> contentData;
  final Function(Map<String, dynamic>) onContentUpdated;

  const ContentDetailPanelWidget({
    super.key,
    required this.selectedContentId,
    required this.contentData,
    required this.onContentUpdated,
  });

  @override
  State<ContentDetailPanelWidget> createState() =>
      _ContentDetailPanelWidgetState();
}

class _ContentDetailPanelWidgetState extends State<ContentDetailPanelWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool isEditing = false;
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    titleController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Map<String, dynamic>? get selectedContent {
    if (widget.selectedContentId.isEmpty) return null;
    try {
      return widget.contentData.firstWhere(
        (item) => item['id'] == widget.selectedContentId,
      );
    } catch (e) {
      return null;
    }
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
      if (isEditing && selectedContent != null) {
        titleController.text = selectedContent!['title'];
        descriptionController.text = selectedContent!['description'];
      }
    });
  }

  void _saveChanges() {
    if (selectedContent != null) {
      final updatedContent = Map<String, dynamic>.from(selectedContent!);
      updatedContent['title'] = titleController.text;
      updatedContent['description'] = descriptionController.text;
      updatedContent['lastModified'] =
          DateTime.now().toString().substring(0, 10);

      widget.onContentUpdated(updatedContent);
      setState(() {
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Content updated successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Widget _buildMetadataRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            CustomIconWidget(
              iconName: icon.toString().split('.').last,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
            SizedBox(width: 1.w),
          ],
          SizedBox(
            width: 8.w,
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(width: 1.w),
          Expanded(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(
      String title, String value, String subtitle, IconData icon) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: icon.toString().split('.').last,
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 1.w),
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            subtitle,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (selectedContent == null) {
      return Container(
        padding: EdgeInsets.all(4.w),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'description',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 48,
              ),
              SizedBox(height: 2.h),
              Text(
                'Select Content',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              SizedBox(height: 1.h),
              Text(
                'Choose an item from the content grid to view details',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final content = selectedContent!;

    return Container(
      padding: EdgeInsets.all(2.w),
      child: Column(
        children: [
          // Header with actions
          Container(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Content Details',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _toggleEdit,
                  icon: CustomIconWidget(
                    iconName: isEditing ? 'close' : 'edit',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 20,
                  ),
                ),
                if (isEditing)
                  IconButton(
                    onPressed: _saveChanges,
                    icon: CustomIconWidget(
                      iconName: 'save',
                      color: AppTheme.successColor,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                icon: CustomIconWidget(
                  iconName: 'info',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 16,
                ),
                text: 'Overview',
              ),
              Tab(
                icon: CustomIconWidget(
                  iconName: 'analytics',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 16,
                ),
                text: 'Analytics',
              ),
              Tab(
                icon: CustomIconWidget(
                  iconName: 'settings',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 16,
                ),
                text: 'Settings',
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Overview Tab
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      isEditing
                          ? TextField(
                              controller: titleController,
                              decoration: InputDecoration(
                                labelText: 'Title',
                                border: OutlineInputBorder(),
                              ),
                              style: AppTheme.lightTheme.textTheme.titleMedium,
                            )
                          : Text(
                              content['title'],
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                      SizedBox(height: 2.h),

                      // Description
                      Text(
                        'Description',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      isEditing
                          ? TextField(
                              controller: descriptionController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                            )
                          : Text(
                              content['description'],
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                            ),

                      SizedBox(height: 2.h),

                      // Metadata
                      Text(
                        'Metadata',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.lightTheme.dividerColor,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildMetadataRow('Region:', content['region']),
                            _buildMetadataRow('Period:', content['period']),
                            _buildMetadataRow(
                                'Difficulty:', content['difficulty']),
                            _buildMetadataRow('Status:', content['status']),
                            _buildMetadataRow('Creator:', content['creator']),
                            _buildMetadataRow(
                                'Created:', content['createdDate']),
                            _buildMetadataRow(
                                'Modified:', content['lastModified']),
                          ],
                        ),
                      ),

                      SizedBox(height: 2.h),

                      // Associated Regions
                      Text(
                        'Associated Regions',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Wrap(
                        spacing: 1.w,
                        runSpacing: 0.5.h,
                        children: (content['associatedRegions'] as List)
                            .map((region) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              region,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 2.h),

                      // Tags
                      Text(
                        'Tags',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Wrap(
                        spacing: 1.w,
                        runSpacing: 0.5.h,
                        children: (content['tags'] as List).map((tag) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              tag,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // Analytics Tab
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usage Analytics',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),

                      // Analytics Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildAnalyticsCard(
                              'Total Views',
                              content['usageCount'].toString(),
                              'This month',
                              Icons.visibility,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: _buildAnalyticsCard(
                              'Completion Rate',
                              '87%',
                              'Average',
                              Icons.check_circle,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 2.h),

                      Row(
                        children: [
                          Expanded(
                            child: _buildAnalyticsCard(
                              'Avg. Score',
                              '8.2/10',
                              'User rating',
                              Icons.star,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: _buildAnalyticsCard(
                              'Time Spent',
                              '12m',
                              'Average',
                              Icons.schedule,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 3.h),

                      Text(
                        'Performance Insights',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),

                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.lightTheme.dividerColor,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• High engagement in Western Europe region',
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              '• Most accessed during morning hours',
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              '• 15% increase in usage this month',
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Settings Tab
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Content Settings',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),

                      // Deployment Controls
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.lightTheme.dividerColor,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Deployment',
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: CustomIconWidget(
                                      iconName: 'publish',
                                      color: AppTheme
                                          .lightTheme.colorScheme.onPrimary,
                                      size: 16,
                                    ),
                                    label: Text('Publish'),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: CustomIconWidget(
                                      iconName: 'archive',
                                      color: AppTheme.lightTheme.primaryColor,
                                      size: 16,
                                    ),
                                    label: Text('Archive'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 2.h),

                      // Export Options
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.lightTheme.dividerColor,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Export Options',
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            ListTile(
                              leading: CustomIconWidget(
                                iconName: 'download',
                                color: AppTheme.lightTheme.primaryColor,
                                size: 20,
                              ),
                              title: Text('Export as SCORM'),
                              subtitle: Text('Compatible with LMS systems'),
                              onTap: () {},
                            ),
                            ListTile(
                              leading: CustomIconWidget(
                                iconName: 'file_download',
                                color: AppTheme.lightTheme.primaryColor,
                                size: 20,
                              ),
                              title: Text('Export as PDF'),
                              subtitle: Text('Printable format'),
                              onTap: () {},
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
        ],
      ),
    );
  }
}
