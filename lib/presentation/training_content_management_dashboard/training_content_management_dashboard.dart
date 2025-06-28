import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/content_detail_panel_widget.dart';
import './widgets/content_grid_panel_widget.dart';
import './widgets/content_navigation_tree_widget.dart';
import './widgets/filtering_toolbar_widget.dart';

class TrainingContentManagementDashboard extends StatefulWidget {
  const TrainingContentManagementDashboard({super.key});

  @override
  State<TrainingContentManagementDashboard> createState() =>
      _TrainingContentManagementDashboardState();
}

class _TrainingContentManagementDashboardState
    extends State<TrainingContentManagementDashboard> {
  String selectedContentId = '';
  List<String> selectedFilters = [];
  List<String> selectedContentItems = [];
  bool isCollaborationMode = false;

  // Mock data for content management
  final List<Map<String, dynamic>> contentData = [
    {
      "id": "content_001",
      "title": "Treaty of Versailles Impact",
      "region": "Western Europe",
      "period": "1919-1939",
      "difficulty": "Advanced",
      "status": "Published",
      "createdDate": "2024-01-15",
      "usageCount": 245,
      "approvalStatus": "Approved",
      "description":
          "Comprehensive analysis of the Treaty of Versailles and its long-term effects on European political landscape.",
      "associatedRegions": ["France", "Germany", "Belgium"],
      "lastModified": "2024-01-20",
      "creator": "Dr. Sarah Mitchell",
      "tags": ["Treaty", "Politics", "Interwar Period"]
    },
    {
      "id": "content_002",
      "title": "Industrial Revolution in Britain",
      "region": "British Isles",
      "period": "1900-1920",
      "difficulty": "Intermediate",
      "status": "Draft",
      "createdDate": "2024-01-10",
      "usageCount": 156,
      "approvalStatus": "Pending",
      "description":
          "Exploration of industrial developments in early 20th century Britain and their social implications.",
      "associatedRegions": ["England", "Scotland", "Wales"],
      "lastModified": "2024-01-18",
      "creator": "Prof. James Wilson",
      "tags": ["Industry", "Social Change", "Technology"]
    },
    {
      "id": "content_003",
      "title": "Russian Revolution Consequences",
      "region": "Eastern Europe",
      "period": "1917-1930",
      "difficulty": "Advanced",
      "status": "Published",
      "createdDate": "2024-01-08",
      "usageCount": 312,
      "approvalStatus": "Approved",
      "description":
          "Analysis of the Russian Revolution's impact on Eastern European political structures and social systems.",
      "associatedRegions": ["Russia", "Poland", "Baltic States"],
      "lastModified": "2024-01-22",
      "creator": "Dr. Elena Petrov",
      "tags": ["Revolution", "Politics", "Social Change"]
    },
    {
      "id": "content_004",
      "title": "Mediterranean Trade Routes",
      "region": "Southern Europe",
      "period": "1920-1940",
      "difficulty": "Beginner",
      "status": "Review",
      "createdDate": "2024-01-12",
      "usageCount": 89,
      "approvalStatus": "Under Review",
      "description":
          "Study of Mediterranean commercial networks and their evolution during the interwar period.",
      "associatedRegions": ["Italy", "Spain", "Greece"],
      "lastModified": "2024-01-19",
      "creator": "Dr. Marco Rossi",
      "tags": ["Trade", "Economics", "Geography"]
    },
    {
      "id": "content_005",
      "title": "Scandinavian Neutrality Policies",
      "region": "Northern Europe",
      "period": "1930-1945",
      "difficulty": "Intermediate",
      "status": "Published",
      "createdDate": "2024-01-05",
      "usageCount": 198,
      "approvalStatus": "Approved",
      "description":
          "Examination of neutrality policies adopted by Scandinavian countries during World War II.",
      "associatedRegions": ["Sweden", "Norway", "Denmark"],
      "lastModified": "2024-01-21",
      "creator": "Dr. Lars Andersen",
      "tags": ["Neutrality", "Politics", "WWII"]
    }
  ];

  final List<Map<String, dynamic>> navigationTree = [
    {
      "title": "Western Europe",
      "count": 45,
      "children": [
        {"title": "1900-1920", "count": 12},
        {"title": "1920-1940", "count": 18},
        {"title": "1940-1960", "count": 15}
      ]
    },
    {
      "title": "Eastern Europe",
      "count": 38,
      "children": [
        {"title": "1900-1920", "count": 15},
        {"title": "1920-1940", "count": 13},
        {"title": "1940-1960", "count": 10}
      ]
    },
    {
      "title": "Northern Europe",
      "count": 29,
      "children": [
        {"title": "1900-1920", "count": 8},
        {"title": "1920-1940", "count": 12},
        {"title": "1940-1960", "count": 9}
      ]
    },
    {
      "title": "Southern Europe",
      "count": 33,
      "children": [
        {"title": "1900-1920", "count": 11},
        {"title": "1920-1940", "count": 14},
        {"title": "1940-1960", "count": 8}
      ]
    }
  ];

  void _onContentSelected(String contentId) {
    setState(() {
      selectedContentId = contentId;
    });
  }

  void _onFiltersChanged(List<String> filters) {
    setState(() {
      selectedFilters = filters;
    });
  }

  void _onBulkSelectionChanged(List<String> selectedItems) {
    setState(() {
      selectedContentItems = selectedItems;
    });
  }

  void _navigateToMapConfiguration() {
    Navigator.pushNamed(context, '/interactive-map-configuration-interface');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Training Content Management Dashboard',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        actions: [
          IconButton(
            onPressed: _navigateToMapConfiguration,
            icon: CustomIconWidget(
              iconName: 'map',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isCollaborationMode = !isCollaborationMode;
              });
            },
            icon: CustomIconWidget(
              iconName: isCollaborationMode ? 'group' : 'person',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: Column(
        children: [
          // Filtering Toolbar
          FilteringToolbarWidget(
            onFiltersChanged: _onFiltersChanged,
            selectedFilters: selectedFilters,
            onBulkAction: (action) {
              // Handle bulk actions
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Bulk action: \$action applied to ${selectedContentItems.length} items'),
                  backgroundColor: AppTheme.lightTheme.primaryColor,
                ),
              );
            },
            selectedItemsCount: selectedContentItems.length,
          ),

          // Main Content Area
          Expanded(
            child: Row(
              children: [
                // Left Navigation Panel (25%)
                Container(
                  width: 25.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.cardColor,
                    border: Border(
                      right: BorderSide(
                        color: AppTheme.lightTheme.dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: ContentNavigationTreeWidget(
                    navigationData: navigationTree,
                    onNodeSelected: (nodeTitle) {
                      // Handle navigation tree selection
                      setState(() {
                        selectedFilters = [nodeTitle];
                      });
                    },
                  ),
                ),

                // Center Content Grid Panel (50%)
                Container(
                  width: 50.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.scaffoldBackgroundColor,
                    border: Border(
                      right: BorderSide(
                        color: AppTheme.lightTheme.dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: ContentGridPanelWidget(
                    contentData: contentData,
                    selectedContentId: selectedContentId,
                    onContentSelected: _onContentSelected,
                    onBulkSelectionChanged: _onBulkSelectionChanged,
                    selectedFilters: selectedFilters,
                    isCollaborationMode: isCollaborationMode,
                  ),
                ),

                // Right Detail Panel (25%)
                Container(
                  width: 25.w,
                  color: AppTheme.lightTheme.cardColor,
                  child: ContentDetailPanelWidget(
                    selectedContentId: selectedContentId,
                    contentData: contentData,
                    onContentUpdated: (updatedContent) {
                      // Handle content updates
                      setState(() {
                        final index = contentData.indexWhere(
                          (item) => item['id'] == updatedContent['id'],
                        );
                        if (index != -1) {
                          contentData[index] = updatedContent;
                        }
                      });
                    },
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
