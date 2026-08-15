import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:helpdesk/core/database/cache/cache_helper.dart';
import 'package:helpdesk/core/database/cache/cache_keys.dart';
import 'package:helpdesk/core/routing/app_routes.dart';
import 'package:helpdesk/core/utils/app_assets.dart';
import 'package:helpdesk/core/utils/app_colors.dart';
import 'package:helpdesk/core/utils/app_strings.dart';
import 'package:helpdesk/core/utils/app_text_style.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _handleSplashNavigation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  Future<void> _handleSplashNavigation() async {
    // Delay for smooth splash presentation
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final bool? isVisited = CacheHelper.getBool(key: CacheKeys.isVisited);
    final bool? isLoggedIn = CacheHelper.getBool(key: CacheKeys.isLoggedIn);

    if (isVisited == null || !isVisited) {
      // First visit: Assign is_visited = true in CacheHelper
      await CacheHelper.saveData(key: CacheKeys.isVisited, value: true);
      if (mounted) context.go(AppRoutes.login);
    } else {
      // User has visited before: check login state
      if (isLoggedIn == true) {
        if (mounted) context.go(AppRoutes.tasks);
      } else {
        if (mounted) context.go(AppRoutes.login);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo
                    Container(
                      width: 140,
                      height: 140,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        AppAssets.logo,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // App Title
                    Text(
                      AppStrings.appName,
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tagline
                    Text(
                      AppStrings.splashTagline,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Modern Spinner
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
