import 'package:flutter/material.dart';

/// Model representing a navigation menu item
class NavigationItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final String route;
  final Color? iconColor;

  const NavigationItem({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.route,
    this.iconColor,
  });
}
