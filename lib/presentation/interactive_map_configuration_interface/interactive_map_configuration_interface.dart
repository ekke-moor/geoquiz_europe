import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import './widgets/configuration_panel_widget.dart';
import './widgets/editing_toolbar_widget.dart';
import './widgets/map_editor_panel_widget.dart';
import './widgets/performance_monitor_widget.dart';

class InteractiveMapConfigurationInterface extends StatefulWidget {
  const InteractiveMapConfigurationInterface({super.key});

  @override
  State<InteractiveMapConfigurationInterface> createState() =>
      _InteractiveMapConfigurationInterfaceState();
}

class _InteractiveMapConfigurationInterfaceState
    extends State<InteractiveMapConfigurationInterface>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isPerformanceMonitorVisible = false;
  String _selectedTool = 'select';
  Map<String, dynamic>? _selectedRegion;
  List<Map<String, dynamic>> _regions = [];
  bool _isLoading = true;

  // Mock data for European regions
  final List<Map<String, dynamic>> _mockRegions = [
    {
      "id": "western_europe",
      "name": "Western Europe",
      "type": "region",
      "difficulty": "medium",
      "contentCount": 45,
      "coordinates": [
        {"lat": 51.5074, "lng": -0.1278},
        {"lat": 48.8566, "lng": 2.3522},
        {"lat": 52.5200, "lng": 13.4050}
      ],
      "children": [
        {
          "id": "france",
          "name": "France",
          "type": "country",
          "difficulty": "easy",
          "contentCount": 15,
          "coordinates": [
            {"lat": 48.8566, "lng": 2.3522},
            {"lat": 45.7640, "lng": 4.8357}
          ],
          "children": [
            {
              "id": "normandy",
              "name": "Normandy",
              "type": "historical_territory",
              "difficulty": "hard",
              "contentCount": 8,
              "coordinates": [
                {"lat": 49.1829, "lng": -0.3707}
              ]
            }
          ]
        },
        {
          "id": "germany",
          "name": "Germany",
          "type": "country",
          "difficulty": "medium",
          "contentCount": 20,
          "coordinates": [
            {"lat": 52.5200, "lng": 13.4050},
            {"lat": 48.1351, "lng": 11.5820}
          ],
          "children": [
            {
              "id": "bavaria",
              "name": "Bavaria",
              "type": "state",
              "difficulty": "medium",
              "contentCount": 6,
              "coordinates": [
                {"lat": 48.1351, "lng": 11.5820}
              ]
            }
          ]
        }
      ]
    },
    {
      "id": "eastern_europe",
      "name": "Eastern Europe",
      "type": "region",
      "difficulty": "hard",
      "contentCount": 32,
      "coordinates": [
        {"lat": 52.2297, "lng": 21.0122},
        {"lat": 50.0755, "lng": 14.4378}
      ],
      "children": [
        {
          "id": "poland",
          "name": "Poland",
          "type": "country",
          "difficulty": "medium",
          "contentCount": 12,
          "coordinates": [
            {"lat": 52.2297, "lng": 21.0122}
          ]
        }
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRegions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadRegions() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _regions = _mockRegions;
          _isLoading = false;
        });
      }
    });
  }

  void _onToolSelected(String tool) {
    setState(() {
      _selectedTool = tool;
    });
  }

  void _onRegionSelected(Map<String, dynamic> region) {
    setState(() {
      _selectedRegion = region;
    });
  }

  void _togglePerformanceMonitor() {
    setState(() {
      _isPerformanceMonitorVisible = !_isPerformanceMonitorVisible;
    });
  }

  void _handleKeyboardShortcut(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyS &&
          event.isControlPressed) {
        _saveConfiguration();
      } else if (event.logicalKey == LogicalKeyboardKey.keyZ &&
          event.isControlPressed) {
        _undoLastAction();
      }
    }
  }

  void _saveConfiguration() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Configuration saved successfully'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _undoLastAction() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Last action undone'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: _handleKeyboardShortcut,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Interactive Map Configuration',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: _togglePerformanceMonitor,
              icon: CustomIconWidget(
                iconName: 'analytics',
                color: _isPerformanceMonitorVisible
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
              tooltip: 'Performance Monitor',
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'export':
                    _exportConfiguration();
                    break;
                  case 'import':
                    _importConfiguration();
                    break;
                  case 'validate':
                    _validateBoundaries();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'download',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text('Export Map'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'import',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'upload',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text('Import Data'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'validate',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'verified',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text('Validate Boundaries'),
                    ],
                  ),
                ),
              ],
              icon: CustomIconWidget(
                iconName: 'more_vert',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                icon: CustomIconWidget(
                  iconName: 'map',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 20,
                ),
                text: 'Map Editor',
              ),
              Tab(
                icon: CustomIconWidget(
                  iconName: 'settings',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 20,
                ),
                text: 'Configuration',
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            EditingToolbarWidget(
              selectedTool: _selectedTool,
              onToolSelected: _onToolSelected,
              onSave: _saveConfiguration,
              onUndo: _undoLastAction,
            ),
            Expanded(
              child: Stack(
                children: [
                  TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMapEditorView(),
                      _buildConfigurationView(),
                    ],
                  ),
                  if (_isPerformanceMonitorVisible)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: PerformanceMonitorWidget(
                        onClose: _togglePerformanceMonitor,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  Widget _buildMapEditorView() {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: MapEditorPanelWidget(
            selectedTool: _selectedTool,
            selectedRegion: _selectedRegion,
            regions: _regions,
            isLoading: _isLoading,
            onRegionSelected: _onRegionSelected,
          ),
        ),
        Container(
          width: 1,
          color: AppTheme.lightTheme.dividerColor,
        ),
        Expanded(
          flex: 4,
          child: ConfigurationPanelWidget(
            regions: _regions,
            selectedRegion: _selectedRegion,
            isLoading: _isLoading,
            onRegionSelected: _onRegionSelected,
          ),
        ),
      ],
    );
  }

  Widget _buildConfigurationView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Configuration',
            style: AppTheme.lightTheme.textTheme.headlineSmall,
          ),
          SizedBox(height: 24),
          _buildConfigurationSection(
            'Map Settings',
            [
              _buildConfigOption('Default Zoom Level', '8'),
              _buildConfigOption('Max Zoom Level', '18'),
              _buildConfigOption('Min Zoom Level', '3'),
              _buildConfigOption('Map Style', 'Satellite'),
            ],
          ),
          SizedBox(height: 24),
          _buildConfigurationSection(
            'Boundary Settings',
            [
              _buildConfigOption('Boundary Thickness', '2px'),
              _buildConfigOption('Selection Color', '#2C5F41'),
              _buildConfigOption('Hover Color', '#4A8B6B'),
              _buildConfigOption('Accuracy Threshold', '95%'),
            ],
          ),
          SizedBox(height: 24),
          _buildConfigurationSection(
            'Performance Settings',
            [
              _buildConfigOption('Render Quality', 'High'),
              _buildConfigOption('Cache Size', '256MB'),
              _buildConfigOption('Preload Regions', 'Enabled'),
              _buildConfigOption('Mobile Optimization', 'Enabled'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationSection(String title, List<Widget> options) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            ...options,
          ],
        ),
      ),
    );
  }

  Widget _buildConfigOption(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                  context, '/training-content-management-dashboard');
            },
            icon: CustomIconWidget(
              iconName: 'dashboard',
              color: AppTheme.lightTheme.primaryColor,
              size: 20,
            ),
            label: Text('Dashboard'),
          ),
          Spacer(),
          Text(
            'Ctrl+S: Save | Ctrl+Z: Undo',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _exportConfiguration() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting map configuration...'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _importConfiguration() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Import functionality coming soon'),
        backgroundColor: AppTheme.warningColor,
      ),
    );
  }

  void _validateBoundaries() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Boundary validation completed successfully'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
}
