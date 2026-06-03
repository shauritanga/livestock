import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/onboarding_page.dart';

/// Widget for displaying a single onboarding page
class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;
  
  const OnboardingPageWidget({
    super.key,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon or Image
          _buildIcon(context),
          
          SizedBox(height: 48.h),
          
          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 16.h),
          
          // Description
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildIcon(BuildContext context) {
    // Use icon if iconData is provided, otherwise use placeholder
    if (page.iconData != null) {
      IconData icon;
      switch (page.iconData) {
        case 'agriculture':
          icon = Icons.agriculture;
          break;
        case 'pets':
          icon = Icons.pets;
          break;
        case 'water_drop':
          icon = Icons.water_drop;
          break;
        case 'account_balance':
          icon = Icons.account_balance;
          break;
        case 'cloud_off':
          icon = Icons.cloud_off;
          break;
        default:
          icon = Icons.info;
      }
      
      return Container(
        width: 200.w,
        height: 200.w,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 100.sp,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
    
    // Placeholder for image (can be replaced with actual images later)
    return Container(
      width: 200.w,
      height: 200.w,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.image,
        size: 100.sp,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
