import 'package:equatable/equatable.dart';

/// Represents a single onboarding page
class OnboardingPage extends Equatable {
  final String title;
  final String description;
  final String imagePath;
  final String? iconData; // For using icons instead of images
  
  const OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
    this.iconData,
  });
  
  @override
  List<Object?> get props => [title, description, imagePath, iconData];
}
