import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_page_widget.dart';

/// Onboarding screen shown to first-time users
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pages = ref.watch(onboardingPagesProvider);
    final currentPageIndex = ref.watch(onboardingPageIndexProvider);
    final pageController = PageController(initialPage: currentPageIndex);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => _completeOnboarding(context, ref),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            
            // Page view
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  ref.read(onboardingPageIndexProvider.notifier).setPage(index);
                },
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(page: pages[index]);
                },
              ),
            ),
            
            // Page indicators
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => _buildPageIndicator(context, index, currentPageIndex),
                ),
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  if (currentPageIndex > 0)
                    TextButton(
                      onPressed: () {
                        pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        'Back',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    )
                  else
                    const SizedBox(width: 80),
                  
                  // Next/Get Started button
                  ElevatedButton(
                    onPressed: () {
                      if (currentPageIndex < pages.length - 1) {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding(context, ref);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 16.h,
                      ),
                    ),
                    child: Text(
                      currentPageIndex < pages.length - 1
                          ? 'Next'
                          : 'Get Started',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPageIndicator(BuildContext context, int index, int currentIndex) {
    final isActive = index == currentIndex;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      width: isActive ? 24.w : 8.w,
      height: 8.h,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
  
  Future<void> _completeOnboarding(BuildContext context, WidgetRef ref) async {
    // Mark onboarding as seen
    final dataSource = ref.read(onboardingLocalDataSourceProvider);
    await dataSource.setOnboardingSeen();
    
    // Navigate to login screen
    if (context.mounted) {
      context.go('/login');
    }
  }
}
