import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/screens/auth/login_screen.dart';
import 'package:book_reader_app/theme/app_colors.dart';
import 'package:book_reader_app/widgets/common/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: 'assets/images/Bibliophile-amico.svg',
      title: 'Discover Your Next Read',
      description:
          'Explore thousands of books across various categories and find your perfect match.',
    ),
    OnboardingPage(
      image: 'assets/images/Bibliophile-bro.svg',
      title: 'Read Anytime, Anywhere',
      description:
          'Access your favorite books on any device and continue reading from where you left off.',
    ),
    OnboardingPage(
      image: 'assets/images/Bibliophile-cuate.svg',
      title: 'Build Your Library',
      description:
          'Create your personal collection, organize books, and track your reading progress.',
    ),
    OnboardingPage(
      image: 'assets/images/Bibliophile-rafiki.svg',
      title: 'Share Your Passion',
      description:
          'Submit your own books, share reviews, and connect with fellow book lovers.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: animationDurationMedium,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isLastPage = _currentPage == _pages.length - 1;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: spacingMedium,
                vertical: spacingSmall,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Skip',
                      style: bodyMedium.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPageWidget(
                    page: _pages[index],
                    pageIndex: index,
                  );
                },
              ),
            ),

            // Page indicators and navigation
            Padding(
              padding: const EdgeInsets.all(spacingLarge),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) =>
                          _PageIndicator(isActive: index == _currentPage),
                    ),
                  ),
                  const SizedBox(height: spacingLarge),

                  // Next/Get Started button
                  PrimaryButton(
                    label: isLastPage ? 'Get Started' : 'Next',
                    onPressed: _nextPage,
                    icon: isLastPage
                        ? Icons.arrow_forward_rounded
                        : Icons.chevron_right_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;
  final int pageIndex;

  const _OnboardingPageWidget({required this.page, required this.pageIndex});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    Widget illustration = SvgPicture.asset(page.image, fit: BoxFit.contain);
    illustration = reduceMotion
        ? illustration.animate().fadeIn(duration: animationDurationMedium)
        : illustration
              .animate()
              .fadeIn(duration: animationDurationMedium)
              .scale(
                begin: const Offset(0.92, 0.92),
                end: const Offset(1, 1),
                duration: animationDurationMedium,
                curve: easeOutStrong,
              );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: spacingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(spacingLarge),
              child: illustration,
            ),
          ),

          const SizedBox(height: spacingXLarge),

          // Title
          Text(
            page.title,
            style: displayLarge.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: spacingMedium),

          // Description
          Text(
            page.description,
            style: bodyLarge.copyWith(color: colors.secondaryText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final bool isActive;

  const _PageIndicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AnimatedContainer(
      duration: animationDurationMedium,
      curve: easeOutStrong,
      margin: const EdgeInsets.symmetric(horizontal: spacingSmall / 2),
      height: spacingSmall,
      width: isActive ? spacingLarge : spacingSmall,
      decoration: BoxDecoration(
        color: isActive ? colors.primary : colors.border,
        borderRadius: BorderRadius.circular(borderRadiusSmall / 2),
      ),
    );
  }
}

class OnboardingPage {
  final String image;
  final String title;
  final String description;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
  });
}
