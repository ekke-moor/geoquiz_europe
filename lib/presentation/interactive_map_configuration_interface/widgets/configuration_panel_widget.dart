import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class ConfigurationPanelWidget extends StatefulWidget {
  final List<Map<String, dynamic>> regions;
  final Map<String, dynamic>? selectedRegion;
  final bool isLoading;
  final Function(Map<String, dynamic>) onRegionSelected;

  const ConfigurationPanelWidget({
    super.key,
    required this.regions,
    this.selectedRegion,
    required this.isLoading,
    required this.onRegionSelected,
  });

  @override
  State<ConfigurationPanelWidget> createState() =>
      _ConfigurationPanelWidgetState();
}

class _ConfigurationPanelWidgetState extends State<ConfigurationPanelWidget> {
  String _searchQuery = '';
  String _filterDifficulty = 'all';
  String _filterType = 'all';
  bool _showSyncStatus = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.lightTheme.colorScheme.surface,
      child: Column(
        children: [
          _buildHeader(),
          _buildFilters(),
          Expanded(
            child:
                widget.isLoading ? _buildLoadingState() : _buildRegionsList(),
          ),
          if (widget.selectedRegion != null) _buildRegionDetails(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'settings',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Configuration Panel',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              Spacer(),
              Switch(
                value: _showSyncStatus,
                onChanged: (value) {
                  setState(() {
                    _showSyncStatus = value;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 12),
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search regions...',
              prefixIcon: Padding(
                padding: EdgeInsets.all(12),
                child: CustomIconWidget(
                  iconName: 'search',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _filterDifficulty,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _filterDifficulty = value;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Difficulty',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                DropdownMenuItem(value: 'all', child: Text('All')),
                DropdownMenuItem(value: 'easy', child: Text('Easy')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'hard', child: Text('Hard')),
              ],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _filterType,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _filterType = value;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                DropdownMenuItem(value: 'all', child: Text('All')),
                DropdownMenuItem(value: 'region', child: Text('Region')),
                DropdownMenuItem(value: 'country', child: Text('Country')),
                DropdownMenuItem(value: 'state', child: Text('State')),
                DropdownMenuItem(
                    value: 'historical_territory', child: Text('Historical')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.lightTheme.primaryColor,
          ),
          SizedBox(height: 16),
          Text(
            'Loading regions...',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildRegionsList() {
    final filteredRegions = _getFilteredRegions();

    if (filteredRegions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'No regions found',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredRegions.length,
      itemBuilder: (context, index) {
        final region = filteredRegions[index];
        return _buildRegionCard(region);
      },
    );
  }

  Widget _buildRegionCard(Map<String, dynamic> region) {
    final isSelected = widget.selectedRegion?["id"] == region["id"];
    final children = region["children"] as List? ?? [];

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
          : AppTheme.lightTheme.colorScheme.surface,
      child: ExpansionTile(
        leading: CustomIconWidget(
          iconName: _getRegionIcon(region["type"] as String),
          color: _getDifficultyColor(region["difficulty"] as String),
          size: 24,
        ),
        title: Text(
          region["name"] as String,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Row(
              children: [
                _buildChip(region["type"] as String, Colors.blue),
                SizedBox(width: 8),
                _buildChip(region["difficulty"] as String,
                    _getDifficultyColor(region["difficulty"] as String)),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'article',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  '${region["contentCount"]} items',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                if (_showSyncStatus) ...[
                  SizedBox(width: 16),
                  CustomIconWidget(
                    iconName: 'sync',
                    color: AppTheme.successColor,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Synced',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.successColor,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (children.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${children.length}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            SizedBox(width: 8),
            CustomIconWidget(
              iconName: 'expand_more',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
        onExpansionChanged: (expanded) {
          if (expanded) {
            widget.onRegionSelected(region);
          }
        },
        children:
            children.map<Widget>((child) => _buildChildRegion(child)).toList(),
      ),
    );
  }

  Widget _buildChildRegion(Map<String, dynamic> child) {
    final isSelected = widget.selectedRegion?["id"] == child["id"];

    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: ListTile(
        leading: CustomIconWidget(
          iconName: _getRegionIcon(child["type"] as String),
          color: _getDifficultyColor(child["difficulty"] as String),
          size: 20,
        ),
        title: Text(
          child["name"] as String,
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        subtitle: Row(
          children: [
            _buildChip(child["type"] as String, Colors.blue),
            SizedBox(width: 8),
            _buildChip(child["difficulty"] as String,
                _getDifficultyColor(child["difficulty"] as String)),
          ],
        ),
        trailing: Text(
          '${child["contentCount"]}',
          style: AppTheme.lightTheme.textTheme.bodySmall,
        ),
        selected: isSelected,
        selectedTileColor:
            AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
        onTap: () => widget.onRegionSelected(child),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRegionDetails() {
    final region = widget.selectedRegion!;
    final coordinates = region["coordinates"] as List;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Region Details',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              Spacer(),
              IconButton(
                onPressed: () => _editRegion(region),
                icon: CustomIconWidget(
                  iconName: 'edit',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 20,
                ),
                tooltip: 'Edit Region',
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildDetailRow('Name', region["name"] as String),
          _buildDetailRow('Type', region["type"] as String),
          _buildDetailRow('Difficulty', region["difficulty"] as String),
          _buildDetailRow('Content Count', '${region["contentCount"]}'),
          _buildDetailRow('Coordinates', '${coordinates.length} points'),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _validateRegion(region),
                  icon: CustomIconWidget(
                    iconName: 'verified',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 16,
                  ),
                  label: Text('Validate'),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _exportRegion(region),
                  icon: CustomIconWidget(
                    iconName: 'download',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 16,
                  ),
                  label: Text('Export'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredRegions() {
    List<Map<String, dynamic>> allRegions = [];

    void addRegionsRecursively(List<Map<String, dynamic>> regions) {
      for (final region in regions) {
        allRegions.add(region);
        final children = region["children"] as List? ?? [];
        if (children.isNotEmpty) {
          addRegionsRecursively(children.cast<Map<String, dynamic>>());
        }
      }
    }

    addRegionsRecursively(widget.regions);

    return allRegions.where((region) {
      final matchesSearch = _searchQuery.isEmpty ||
          (region["name"] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      final matchesDifficulty = _filterDifficulty == 'all' ||
          region["difficulty"] == _filterDifficulty;

      final matchesType = _filterType == 'all' || region["type"] == _filterType;

      return matchesSearch && matchesDifficulty && matchesType;
    }).toList();
  }

  String _getRegionIcon(String type) {
    switch (type) {
      case 'region':
        return 'public';
      case 'country':
        return 'flag';
      case 'state':
        return 'location_city';
      case 'historical_territory':
        return 'history';
      default:
        return 'place';
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return AppTheme.successColor;
      case 'medium':
        return AppTheme.warningColor;
      case 'hard':
        return const Color(0xFFF44336);
      default:
        return AppTheme.infoColor;
    }
  }

  void _editRegion(Map<String, dynamic> region) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing ${region["name"]}...'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _validateRegion(Map<String, dynamic> region) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${region["name"]} validated successfully'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _exportRegion(Map<String, dynamic> region) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting ${region["name"]}...'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }
}
