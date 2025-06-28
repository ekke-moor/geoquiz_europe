import 'package:flutter/material.dart';
import '../presentation/training_content_management_dashboard/training_content_management_dashboard.dart';
import '../presentation/interactive_map_configuration_interface/interactive_map_configuration_interface.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String trainingContentManagementDashboard =
      '/training-content-management-dashboard';
  static const String interactiveMapConfigurationInterface =
      '/interactive-map-configuration-interface';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const TrainingContentManagementDashboard(),
    trainingContentManagementDashboard: (context) =>
        const TrainingContentManagementDashboard(),
    interactiveMapConfigurationInterface: (context) =>
        const InteractiveMapConfigurationInterface(),
    // TODO: Add your other routes here
  };
}
