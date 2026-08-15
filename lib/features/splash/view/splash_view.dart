import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:helpdesk/core/database/cache/cache_helper.dart';
import 'package:helpdesk/core/database/cache/cache_keys.dart';
import 'package:helpdesk/core/routing/app_routes.dart';
import 'package:helpdesk/core/utils/app_assets.dart';
import 'package:helpdesk/features/auth/view_model/auth_cubit.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _textFade;
  late Animation<double> _bottomFade;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _handleSplashNavigation();
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // 1. Logo Animation (0ms -> 700ms)
    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // 2. Text Slide & Fade (300ms -> 900ms)
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.25, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.25, 0.75, curve: Curves.easeIn),
      ),
    );

    // 3. Bottom Progress Bar & Footer (600ms -> 1200ms)
    _bottomFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _mainController.forward();
  }

  Future<void> _handleSplashNavigation() async {
    // Delay for smooth splash presentation
    await Future.delayed(const Duration(milliseconds: 2400));

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
        final authCubit = AuthCubit.get(context);
        if (authCubit.currentUser != null) {
          if (mounted) context.go(AppRoutes.tasks);
        } else {
          final user = await authCubit.checkCurrentUser();
          if (!mounted) return;
          if (user != null) {
            context.go(AppRoutes.tasks);
          } else {
            context.go(AppRoutes.login);
          }
        }
      } else {
        if (mounted) context.go(AppRoutes.login);
      }
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FE),
      body: Stack(
        children: [
          // 1. High-Res Corporate Workspace Background Illustration
          Positioned.fill(
            child: Image.asset(
              AppAssets.splashBg,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFF8FAFC),
                      Color(0xFFE2E8F0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Soft Gradient Lighting Overlay for Top Contrast
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.75),
                    Colors.white.withValues(alpha: 0.10),
                    Colors.transparent,
                    const Color(0xFF0F172A).withValues(alpha: 0.15),
                  ],
                  stops: const [0.0, 0.35, 0.65, 1.0],
                ),
              ),
            ),
          ),

          // 3. Foreground Centered Branding & Animations
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Animated App Logo (Direct without box container)
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: Image.asset(
                          AppAssets.logo,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.support_agent_rounded,
                            size: 72,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Staggered Title
                  FadeTransition(
                    opacity: _textFade,
                    child: SlideTransition(
                      position: _textSlide,
                      child: Column(
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.8,
                              ),
                              children: [
                                TextSpan(
                                  text: 'HelpDesk',
                                  style: TextStyle(color: Color(0xFF0F172A)),
                                ),
                                TextSpan(
                                  text: ' Lite',
                                  style: TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Smart Workplace & Support Hub',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                              letterSpacing: 0.1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 5),

                  // Bottom Progress Bar & Trust Badge
                  FadeTransition(
                    opacity: _bottomFade,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Sleek Loading Line Indicator
                        SizedBox(
                          width: 140,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: const LinearProgressIndicator(
                              minHeight: 3,
                              backgroundColor: Color(0x33FFFFFF),
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Security & Workspace Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Enterprise-Grade • Secure Workspace',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.9),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
