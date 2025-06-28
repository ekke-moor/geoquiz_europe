import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class PerformanceMonitorWidget extends StatefulWidget {
  final VoidCallback onClose;

  const PerformanceMonitorWidget({
    super.key,
    required this.onClose,
  });

  @override
  State<PerformanceMonitorWidget> createState() =>
      _PerformanceMonitorWidgetState();
}

class _PerformanceMonitorWidgetState extends State<PerformanceMonitorWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Mock performance data
  final Map<String, dynamic> _performanceData = {
    "mapRenderTime": 45.2,
    "memoryUsage": 67.8,
    "cpuUsage": 23.5,
    "networkLatency": 120,
    "userInteractions": 1247,
    "mobileOptimization": 94.2,
    "syncStatus": "Connected",
    "lastUpdate": DateTime.now().subtract(Duration(seconds: 30)),
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: 320,
        constraints: BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow,
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildMetricsGrid(),
                    SizedBox(height: 16),
                    _buildPerformanceChart(),
                    SizedBox(height: 16),
                    _buildSystemStatus(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'analytics',
            color: AppTheme.lightTheme.primaryColor,
            size: 24,
          ),
          SizedBox(width: 8),
          Text(
            'Performance Monitor',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          IconButton(
            onPressed: widget.onClose,
            icon: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            constraints: BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildMetricCard(
          'Render Time',
          '${_performanceData["mapRenderTime"]}ms',
          'timer',
          _getPerformanceColor(_performanceData["mapRenderTime"] as double, 50),
        ),
        _buildMetricCard(
          'Memory Usage',
          '${_performanceData["memoryUsage"]}%',
          'memory',
          _getPerformanceColor(_performanceData["memoryUsage"] as double, 80),
        ),
        _buildMetricCard(
          'CPU Usage',
          '${_performanceData["cpuUsage"]}%',
          'speed',
          _getPerformanceColor(_performanceData["cpuUsage"] as double, 70),
        ),
        _buildMetricCard(
          'Network',
          '${_performanceData["networkLatency"]}ms',
          'network_check',
          _getPerformanceColor(
              _performanceData["networkLatency"] as double, 200),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, String icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: color,
            size: 24,
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
      height: 120,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
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
            'User Interactions',
            style: AppTheme.lightTheme.textTheme.titleSmall,
          ),
          SizedBox(height: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final height = (index + 1) * 10.0 + (index * 5);
                return Container(
                  width: 20,
                  height: height,
                  decoration: BoxDecoration(
                    color:
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Total: ${_performanceData["userInteractions"]} interactions',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
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
            'System Status',
            style: AppTheme.lightTheme.textTheme.titleSmall,
          ),
          SizedBox(height: 12),
          _buildStatusRow(
            'Mobile Optimization',
            '${_performanceData["mobileOptimization"]}%',
            'phone_android',
            AppTheme.successColor,
          ),
          SizedBox(height: 8),
          _buildStatusRow(
            'Sync Status',
            _performanceData["syncStatus"] as String,
            'sync',
            AppTheme.successColor,
          ),
          SizedBox(height: 8),
          _buildStatusRow(
            'Last Update',
            _formatLastUpdate(_performanceData["lastUpdate"] as DateTime),
            'update',
            AppTheme.infoColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, String icon, Color color) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: color,
          size: 16,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall,
          ),
        ),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getPerformanceColor(double value, double threshold) {
    if (value <= threshold * 0.7) {
      return AppTheme.successColor;
    } else if (value <= threshold) {
      return AppTheme.warningColor;
    } else {
      return const Color(0xFFF44336);
    }
  }

  String _formatLastUpdate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }
}
