import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class EditingToolbarWidget extends StatelessWidget {
  final String selectedTool;
  final Function(String) onToolSelected;
  final VoidCallback onSave;
  final VoidCallback onUndo;

  const EditingToolbarWidget({
    super.key,
    required this.selectedTool,
    required this.onToolSelected,
    required this.onSave,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildToolGroup('Selection Tools', [
            _ToolItem('select', 'Select', 'touch_app'),
            _ToolItem('pan', 'Pan', 'pan_tool'),
          ]),
          _buildDivider(),
          _buildToolGroup('Drawing Tools', [
            _ToolItem('polygon', 'Polygon', 'pentagon'),
            _ToolItem('boundary', 'Boundary', 'linear_scale'),
            _ToolItem('point', 'Point', 'place'),
          ]),
          _buildDivider(),
          _buildToolGroup('Edit Tools', [
            _ToolItem('edit', 'Edit', 'edit'),
            _ToolItem('delete', 'Delete', 'delete'),
          ]),
          Spacer(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildToolGroup(String title, List<_ToolItem> tools) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 4),
        Row(
          children: tools.map((tool) => _buildToolButton(tool)).toList(),
        ),
      ],
    );
  }

  Widget _buildToolButton(_ToolItem tool) {
    final isSelected = selectedTool == tool.id;

    return Padding(
      padding: EdgeInsets.only(right: 4),
      child: Tooltip(
        message: tool.tooltip,
        child: InkWell(
          onTap: () => onToolSelected(tool.id),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.primaryColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.dividerColor,
                width: 1,
              ),
            ),
            child: CustomIconWidget(
              iconName: tool.icon,
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.onPrimary
                  : AppTheme.lightTheme.colorScheme.onSurface,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      margin: EdgeInsets.symmetric(horizontal: 16),
      color: AppTheme.lightTheme.dividerColor,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildActionButton(
          'Undo',
          'undo',
          onUndo,
          AppTheme.lightTheme.colorScheme.onSurface,
        ),
        SizedBox(width: 8),
        _buildActionButton(
          'Save',
          'save',
          onSave,
          AppTheme.successColor,
        ),
        SizedBox(width: 16),
        _buildVersionControl(),
      ],
    );
  }

  Widget _buildActionButton(
      String label, String icon, VoidCallback onPressed, Color color) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: CustomIconWidget(
        iconName: icon,
        color: AppTheme.lightTheme.colorScheme.onPrimary,
        size: 16,
      ),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size(0, 36),
      ),
    );
  }

  Widget _buildVersionControl() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'history',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 16,
          ),
          SizedBox(width: 4),
          Text(
            'v2.1.3',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolItem {
  final String id;
  final String tooltip;
  final String icon;

  const _ToolItem(this.id, this.tooltip, this.icon);
}
