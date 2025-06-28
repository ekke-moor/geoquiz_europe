import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class MapEditorPanelWidget extends StatefulWidget {
  final String selectedTool;
  final Map<String, dynamic>? selectedRegion;
  final List<Map<String, dynamic>> regions;
  final bool isLoading;
  final Function(Map<String, dynamic>) onRegionSelected;

  const MapEditorPanelWidget({
    super.key,
    required this.selectedTool,
    this.selectedRegion,
    required this.regions,
    required this.isLoading,
    required this.onRegionSelected,
  });

  @override
  State<MapEditorPanelWidget> createState() => _MapEditorPanelWidgetState();
}

class _MapEditorPanelWidgetState extends State<MapEditorPanelWidget> {
  double _zoomLevel = 8.0;
  Offset _mapCenter = const Offset(0.5, 0.5);
  bool _showHistoricalOverlay = false;
  String _mapStyle = 'satellite';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.lightTheme.colorScheme.surface,
      child: Column(
        children: [
          _buildMapControls(),
          Expanded(
            child: Stack(
              children: [
                _buildMapCanvas(),
                _buildZoomControls(),
                if (widget.selectedRegion != null) _buildRegionInfo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControls() {
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
      child: Row(
        children: [
          DropdownButton<String>(
            value: _mapStyle,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _mapStyle = value;
                });
              }
            },
            items: [
              DropdownMenuItem(value: 'satellite', child: Text('Satellite')),
              DropdownMenuItem(value: 'terrain', child: Text('Terrain')),
              DropdownMenuItem(value: 'political', child: Text('Political')),
            ],
          ),
          SizedBox(width: 16),
          Switch(
            value: _showHistoricalOverlay,
            onChanged: (value) {
              setState(() {
                _showHistoricalOverlay = value;
              });
            },
          ),
          SizedBox(width: 8),
          Text(
            'Historical Overlay',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          Spacer(),
          Text(
            'Zoom: ${_zoomLevel.toStringAsFixed(1)}x',
            style: AppTheme.lightTheme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildMapCanvas() {
    if (widget.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.lightTheme.primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'Loading map data...',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTapDown: _handleMapTap,
      onPanUpdate: _handleMapPan,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF87CEEB),
              Color(0xFF4682B4),
            ],
          ),
        ),
        child: CustomPaint(
          painter: MapCanvasPainter(
            regions: widget.regions,
            selectedRegion: widget.selectedRegion,
            selectedTool: widget.selectedTool,
            zoomLevel: _zoomLevel,
            mapCenter: _mapCenter,
            showHistoricalOverlay: _showHistoricalOverlay,
          ),
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Positioned(
      top: 16,
      left: 16,
      child: Column(
        children: [
          FloatingActionButton.small(
            onPressed: _zoomIn,
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            foregroundColor: AppTheme.lightTheme.primaryColor,
            child: CustomIconWidget(
              iconName: 'add',
              color: AppTheme.lightTheme.primaryColor,
              size: 20,
            ),
          ),
          SizedBox(height: 8),
          FloatingActionButton.small(
            onPressed: _zoomOut,
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            foregroundColor: AppTheme.lightTheme.primaryColor,
            child: CustomIconWidget(
              iconName: 'remove',
              color: AppTheme.lightTheme.primaryColor,
              size: 20,
            ),
          ),
          SizedBox(height: 8),
          FloatingActionButton.small(
            onPressed: _resetView,
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            foregroundColor: AppTheme.lightTheme.primaryColor,
            child: CustomIconWidget(
              iconName: 'center_focus_strong',
              color: AppTheme.lightTheme.primaryColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionInfo() {
    final region = widget.selectedRegion!;
    return Positioned(
      bottom: 16,
      left: 16,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(maxWidth: 300),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: _getRegionIcon(region["type"] as String),
                  color: AppTheme.lightTheme.primaryColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    region["name"] as String,
                    style: AppTheme.lightTheme.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Type: ${region["type"]}',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
            Text(
              'Difficulty: ${region["difficulty"]}',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
            Text(
              'Content: ${region["contentCount"]} items',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
            if ((region["coordinates"] as List).isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                'Coordinates: ${(region["coordinates"] as List).length} points',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
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

  void _handleMapTap(TapDownDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    final relativePosition = Offset(
      localPosition.dx / renderBox.size.width,
      localPosition.dy / renderBox.size.height,
    );

    // Simulate region selection based on tap position
    if (widget.regions.isNotEmpty) {
      final region = widget.regions.first;
      widget.onRegionSelected(region);
    }
  }

  void _handleMapPan(DragUpdateDetails details) {
    setState(() {
      _mapCenter = Offset(
        (_mapCenter.dx - details.delta.dx / 1000).clamp(0.0, 1.0),
        (_mapCenter.dy - details.delta.dy / 1000).clamp(0.0, 1.0),
      );
    });
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel + 1).clamp(3.0, 18.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel - 1).clamp(3.0, 18.0);
    });
  }

  void _resetView() {
    setState(() {
      _zoomLevel = 8.0;
      _mapCenter = const Offset(0.5, 0.5);
    });
  }
}

class MapCanvasPainter extends CustomPainter {
  final List<Map<String, dynamic>> regions;
  final Map<String, dynamic>? selectedRegion;
  final String selectedTool;
  final double zoomLevel;
  final Offset mapCenter;
  final bool showHistoricalOverlay;

  MapCanvasPainter({
    required this.regions,
    this.selectedRegion,
    required this.selectedTool,
    required this.zoomLevel,
    required this.mapCenter,
    required this.showHistoricalOverlay,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw European map outline
    _drawEuropeOutline(canvas, size, paint);

    // Draw regions
    for (final region in regions) {
      _drawRegion(canvas, size, region, paint);
    }

    // Draw selected region highlight
    if (selectedRegion != null) {
      _drawSelectedRegion(canvas, size, selectedRegion!, paint);
    }

    // Draw historical overlay if enabled
    if (showHistoricalOverlay) {
      _drawHistoricalOverlay(canvas, size, paint);
    }

    // Draw tool cursor
    _drawToolCursor(canvas, size, paint);
  }

  void _drawEuropeOutline(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFF2C5F41);
    paint.strokeWidth = 3.0;

    final path = Path();
    // Simplified Europe outline
    path.moveTo(size.width * 0.1, size.height * 0.3);
    path.lineTo(size.width * 0.9, size.height * 0.3);
    path.lineTo(size.width * 0.9, size.height * 0.8);
    path.lineTo(size.width * 0.1, size.height * 0.8);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawRegion(Canvas canvas, Size size, Map<String, dynamic> region, Paint paint) {
    final coordinates = region["coordinates"] as List;
    if (coordinates.isEmpty) return;

    paint.color = _getRegionColor(region["difficulty"] as String);
    paint.strokeWidth = 2.0;

    final path = Path();
    bool first = true;

    for (final coord in coordinates) {
      final x = size.width * ((coord["lng"] as double) + 180) / 360;
      final y = size.height * (90 - (coord["lat"] as double)) / 180;

      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }

    if (coordinates.length > 2) {
      path.close();
    }

    canvas.drawPath(path, paint);

    // Draw region label
    final textPainter = TextPainter(
      text: TextSpan(
        text: region["name"] as String,
        style: TextStyle(
          color: const Color(0xFF212121),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    if (coordinates.isNotEmpty) {
      final firstCoord = coordinates.first;
      final x = size.width * ((firstCoord["lng"] as double) + 180) / 360;
      final y = size.height * (90 - (firstCoord["lat"] as double)) / 180;
      textPainter.paint(canvas, Offset(x + 5, y - 15));
    }
  }

  void _drawSelectedRegion(Canvas canvas, Size size, Map<String, dynamic> region, Paint paint) {
    paint.color = const Color(0xFF4A8B6B);
    paint.strokeWidth = 4.0;
    paint.style = PaintingStyle.stroke;

    final coordinates = region["coordinates"] as List;
    if (coordinates.isEmpty) return;

    final path = Path();
    bool first = true;

    for (final coord in coordinates) {
      final x = size.width * ((coord["lng"] as double) + 180) / 360;
      final y = size.height * (90 - (coord["lat"] as double)) / 180;

      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }

    if (coordinates.length > 2) {
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  void _drawHistoricalOverlay(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFF8B4513).withValues(alpha: 0.3);
    paint.style = PaintingStyle.fill;

    // Draw historical boundaries overlay
    final rect = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.4,
      size.width * 0.6,
      size.height * 0.3,
    );
    canvas.drawRect(rect, paint);
  }

  void _drawToolCursor(Canvas canvas, Size size, Paint paint) {
    // Visual indicator for selected tool
    paint.color = const Color(0xFFFF9800);
    paint.strokeWidth = 2.0;
    paint.style = PaintingStyle.stroke;

    switch (selectedTool) {
      case 'polygon':
        canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.1), 10, paint);
        break;
      case 'select':
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(size.width * 0.9, size.height * 0.1),
            width: 20,
            height: 20,
          ),
          paint,
        );
        break;
    }
  }

  Color _getRegionColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return const Color(0xFF4CAF50);
      case 'medium':
        return const Color(0xFFFF9800);
      case 'hard':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF2196F3);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}